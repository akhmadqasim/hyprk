pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pam
import qs
import qs.services
import "lock.js" as L

// The hyprk lock screen (ext-session-lock through Quickshell, PAM through PamContext).
// Locks only on an explicit request: lock() from Power.lock (Apple menu, Spotlight, idle), the
// `lock` IPC target (lockscreen/lock.sh, the Ctrl+Cmd+Q bind). Never on load or reload.
//
// Phases: ""      unlocked, nothing loaded but this object
//         "in"    a layer surface per screen fades the lock in over the live desktop (keyboard grabbed),
//                 then the session lock engages with the same picture
//         "locked" session lock surfaces (LockSurface.qml), password UI on `mainScreen`
//         "out"   PAM said yes: a layer surface per screen shows the lock picture, the session lock is
//                 released under it, and it animates away to reveal the desktop
// Failure to get the session lock (compositor without ext-session-lock, or another locker active)
// falls back to lockscreen/hyprk-lock.sh (hyprlock).
Singleton {
    id: root

    // RELOAD SAFETY: these two must stay the first two children of this Singleton. A Quickshell reload
    // pairs a Singleton's children with the old ones by position; the persisted `locked` must be restored
    // before the WlSessionLock takes over the old lock object, or a reload would drop or double the lock.
    // File watching is also switched off while locked (see below), so a save elsewhere in shell/ cannot
    // reload the shell under a lock in the first place.
    PersistentProperties {
        id: persist
        reloadableId: "hyprkLockState"
        property bool locked: false
        property double since: 0
        property string screen: ""
        property bool watchFiles: true
    }
    WlSessionLock {
        id: session
        locked: persist.locked
        LockSurface {}
    }

    // ---------- state read by the surfaces ----------
    property string phase: persist.locked ? "locked" : ""
    readonly property bool secure: session.secure
    readonly property string mainScreen: persist.screen
    property string buffer: ""             // typed password, only while locked
    property bool busy: false              // PAM is checking
    property int failures: 0
    property int failTick: 0               // +1 per wrong password; the field shakes on change
    // length of the last wrong password: its dots stay, shown selected, until the next key (27.2.1 B2).
    // Only the count is kept, never the characters.
    property int selected: 0
    property int activity: 0               // +1 per key; the caret stays on 0.6 s after it
    property string message: ""            // a PAM error or the lockout text (the Mac shows no wrong-password text)
    property bool showHint: false          // the "?" button shows the password hint in the line
    readonly property string line: showHint ? hint : message !== "" ? message : LockTheme.lineText
    property var kb: null                  // L.keyboard(): layouts, index, capsLock
    readonly property bool capsLock: kb ? kb.capsLock : false
    readonly property string layoutLabel: kb ? L.layoutLabel(kb) : ""
    property string userName: Quickshell.env("USER") || ""
    readonly property string userLogin: Quickshell.env("USER") || ""
    readonly property string home: Quickshell.env("HOME") || ""
    readonly property double since: persist.since
    readonly property string hint: (Prefs.lock && Prefs.lock.hint) ? String(Prefs.lock.hint) : LockTheme.hintFallback

    // HYPRK_LOCK_TEST=1 with HYPRK_LOCK_PAMDIR: PAM reads its "login" service from that directory
    // instead of /etc/pam.d (the headless test session points it at a test double). Never set in a
    // normal session; the shell logs a warning when it is on.
    readonly property bool testMode: Quickshell.env("HYPRK_LOCK_TEST") === "1" && (Quickshell.env("HYPRK_LOCK_PAMDIR") || "") !== ""

    // ---------- requests ----------
    function lock(): string {
        if (phase !== "") return phase;
        const fm = Hyprland.focusedMonitor;
        persist.screen = fm ? fm.name : (Panels.screen ? Panels.screen.name : "");
        buffer = ""; message = ""; failures = 0; busy = false; selected = 0; showHint = false;
        persist.since = Date.now();
        // no hot reload while the lock is up (a save in shell/ by an editor or agent)
        persist.watchFiles = Quickshell.watchFiles;
        Quickshell.watchFiles = false;
        readKeyboard();
        phase = "in";
        inGuard.restart();
        return "ok";
    }

    // the lock-in overlay finished fading (or the guard fired): take the session lock
    function engage(): void {
        if (phase !== "in") return;
        inGuard.stop();
        phase = "locked";
        persist.locked = true;
        secureGuard.restart();
    }

    function submit(): void {
        if (phase !== "locked" || busy || buffer === "") return;
        busy = true;
        message = "";
        showHint = false;
        pending = buffer;
        if (!pam.start()) { pending = null; busy = false; fail(""); }
    }
    property var pending: null

    function fail(text: string): void {
        failures++;
        selected = buffer.length;
        buffer = "";
        message = text;
        failTick++;
    }
    function toggleHint(): void {
        if (phase === "locked" && !busy) showHint = !showHint;
    }

    function unlockNow(): void {
        ready = 0;
        mapped = 0;
        released = false;
        phase = "out";
        outGuard.restart();
    }
    // reveal overlays report their first frame, Hyprland reports each one mapped ("openlayer"); once every screen
    // has one under the lock, release it. The client's frame alone was not enough: in 3 of 10 unlocks Hyprland's first
    // unlocked frame showed the bare desktop, the overlay not mapped yet (mcap)
    property int ready: 0
    property int mapped: 0
    property bool released: false
    function overlayReady(): void {
        if (phase !== "out") return;
        ready++;
        checkReady();
    }
    function checkReady(): void {
        const n = Quickshell.screens.length;
        if (ready >= n && mapped >= n) release();
    }
    function release(): void {
        if (phase !== "out" || released) return;
        outGuard.stop();
        released = true;
        persist.locked = false;
        finishGuard.restart();
    }
    // the reveal finished: unload everything
    function finish(): void {
        if (phase !== "out") return;
        finishGuard.stop();
        persist.locked = false;
        buffer = ""; message = ""; failures = 0; busy = false; kb = null; released = false; selected = 0; showHint = false;
        phase = "";
        Quickshell.watchFiles = persist.watchFiles;
    }

    // the screen that gets the user and the field: the focused one at lock time, else the first
    function isMain(screen): bool {
        if (!screen) return false;
        const all = Quickshell.screens;
        if (all.some(x => x.name === mainScreen)) return screen.name === mainScreen;
        return all.length > 0 && screen.name === all[0].name;
    }

    // keys from any lock surface (focus can sit on a screen without the field)
    function key(event): bool {
        if (phase !== "locked") return false;
        activity++;
        showHint = false;
        const ctrl = (event.modifiers & Qt.ControlModifier) !== 0;
        const alt = (event.modifiers & Qt.AltModifier) !== 0;     // Ctrl+Alt can be AltGr: still text
        const meta = (event.modifiers & Qt.MetaModifier) !== 0;
        switch (event.key) {
        case Qt.Key_Return: case Qt.Key_Enter: submit(); return true;
        case Qt.Key_Escape: if (!busy) { buffer = ""; selected = 0; } return true;
        case Qt.Key_Backspace:
            // with the wrong password selected, Backspace deletes the selection
            if (!busy) { buffer = ctrl ? "" : buffer.slice(0, -1); selected = 0; }
            return true;
        case Qt.Key_CapsLock: return true;      // state is read on release
        case Qt.Key_Space:
            // Ctrl+Space: next input source (macOS "Select the previous input source")
            if (ctrl) { nextLayout(); return true; }
            break;
        case Qt.Key_U:
            if (ctrl) { if (!busy) { buffer = ""; selected = 0; } return true; }
            break;
        }
        if ((ctrl && !alt) || meta || busy) return true;
        const t = event.text;
        if (t && t.length > 0 && t.charCodeAt(0) >= 32 && t.charCodeAt(0) !== 127 && buffer.length < 512) {
            selected = 0;           // the next key replaces the selected wrong password
            buffer += t;
        }
        return true;
    }
    // Caps Lock: read the state on release and once more a moment later (Hyprland may apply the
    // modifier after the key event, e.g. from a virtual keyboard)
    function keyReleased(event): void {
        if (event.key === Qt.Key_CapsLock) { readKeyboard(); capsRead.restart(); }
    }
    Timer { id: capsRead; interval: 150; onTriggered: root.readKeyboard() }

    function nextLayout(): void {
        Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"]);
    }

    // ---------- PAM ----------
    PamContext {
        id: pam
        config: "login"
        configDirectory: root.testMode ? Quickshell.env("HYPRK_LOCK_PAMDIR") : "/etc/pam.d"
        onResponseRequiredChanged: {
            if (!responseRequired) return;
            if (root.pending !== null) { respond(root.pending); root.pending = null; }
            else abort();                       // a second prompt (expired password...): not handled here
        }
        onPamMessage: if (messageIsError && message) root.message = message
        onError: error => console.warn("hyprk lock: PAM error", PamError.toString(error))
        onCompleted: result => {
            root.busy = false;
            root.pending = null;
            if (result === PamResult.Success) root.unlockNow();
            else root.fail(result === PamResult.MaxTries ? LockTheme.lockoutText : "");
        }
    }

    // ---------- helpers ----------
    // keyboard layouts and Caps Lock from Hyprland, read on lock, Caps Lock release and layout change
    function readKeyboard(): void { kbProc.running = false; kbProc.running = true; }
    Process {
        id: kbProc
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector { onStreamFinished: root.kb = L.keyboard(text) }
    }
    Connections {
        target: Hyprland
        enabled: root.phase !== ""
        function onRawEvent(event: HyprlandEvent): void {
            if (event.name === "activelayout") root.readKeyboard();
            else if (event.name === "openlayer" && event.data === "hyprk-lock" && root.phase === "out") {
                root.mapped++;
                root.checkReady();
            }
        }
    }

    // full name from passwd (once)
    Process {
        running: root.userLogin !== ""
        command: ["getent", "passwd", root.userLogin]
        stdout: StdioCollector { onStreamFinished: root.userName = L.fullName(text, root.userLogin) }
    }

    // user picture: ~/.face, else the AccountsService icon (once; "" = initials)
    property string avatar: ""
    Process {
        running: true
        command: ["sh", "-c", 'for f in "$HOME/.face" "/var/lib/AccountsService/icons/$USER"; do [ -r "$f" ] && [ -s "$f" ] && { echo "$f"; break; }; done']
        stdout: StdioCollector { onStreamFinished: root.avatar = text.trim() }
    }

    function fallback(): void {
        console.warn("hyprk lock: no session lock, falling back to hyprlock");
        const script = Quickshell.shellDir + "/../lockscreen/hyprk-lock.sh";
        Quickshell.execDetached(["sh", "-c", `[ -x "${script}" ] && exec "${script}"${Theme.dark ? " --dark" : ""}`]);
    }

    // the lock was refused or lost without an unlock from here (another locker, no protocol):
    // Hyprland confirms a lock within 5 s at the latest (SessionLockManager.cpp), so check after that
    function checkLost(): void {
        if (session.locked || !persist.locked || phase === "out") return;
        persist.locked = false;
        phase = "";
        Quickshell.watchFiles = persist.watchFiles;
        fallback();
    }
    Connections {
        target: session
        function onLockStateChanged() { root.checkLost(); }
    }
    Timer { id: secureGuard; interval: 6000; onTriggered: if (!session.secure) root.checkLost() }

    // the overlays never report (window failed to map): lock or unlock anyway
    Timer { id: inGuard; interval: LockTheme.lockIn + 600; onTriggered: root.engage() }
    Timer { id: outGuard; interval: 1500; onTriggered: root.release() }
    Timer { id: finishGuard; interval: LockTheme.unlockOut + 1000; onTriggered: root.finish() }

    // ---------- transition overlays (only while they run) ----------
    LazyLoader {
        // "in" stays until the compositor confirms the lock, so no desktop frame shows in between
        active: root.phase === "in" || (root.phase === "locked" && !session.secure)
        Variants {
            model: Quickshell.screens
            LockOverlay { mode: "in" }
        }
    }
    LazyLoader {
        active: root.phase === "out"
        Variants {
            model: Quickshell.screens
            LockOverlay { mode: "out" }
        }
    }

    Component.onCompleted: {
        Power.locker = root;
        if (testMode) console.warn("hyprk lock: TEST MODE, PAM service from", Quickshell.env("HYPRK_LOCK_PAMDIR"));
    }

    IpcHandler {
        target: "lock"
        function lock(): string { return root.lock(); }
        function state(): string {
            return JSON.stringify({ phase: root.phase, locked: session.locked, secure: session.secure,
                                    failures: root.failures, busy: root.busy, message: root.message,
                                    screen: root.mainScreen, layout: root.layoutLabel, capsLock: root.capsLock,
                                    test: root.testMode });
        }
    }
}
