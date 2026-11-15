pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.HyprK
import "lib/state.js" as State
import "lib/sun.js" as Sun

// Single source of truth for every visual metric of the hyprk shell.
// Units are logical pixels (1pt on macOS == 1 logical px here).
// Values marked "TODO verify" are macOS 27 best guesses and must be checked
// against /mnt/code/liquid-glass-re/SPEC.md ("Layout metrics") once available.
Singleton {
    id: theme

    // ---------- appearance ----------
    // Both are read from state/appearance.json ({"dark": bool, "reduceTransparency": bool})
    // and can be flipped at runtime via `qs ipc call theme ...`.
    property bool dark: false
    // macOS "Reduce transparency": solid tinted material instead of blurred glass.
    // Also forced on when the blurred wallpaper could not be produced (no magick).
    property bool reduceTransparency: false
    // Appearance > Icon & widget style (default | dark | clear | tinted), see HyprK AppIconTile, and the style's
    // own Light / Dark / Auto choice (state/appearance.json iconStyleVariant, written by Settings)
    property string iconStyle: "default"
    property string iconStyleVariant: "auto"
    // what the app icon lookup needs (Apps.iconUrl -> MacIcons.styled): one object, so a binding on it
    // re-resolves the icon files only when the style, its variant or the mode changes
    readonly property var iconLook: ({ style: iconStyle, variant: iconStyleVariant, dark: dark })
    // style of the squircle tile under non-macOS icons: Dark + Auto is the Default style in light mode
    readonly property string iconTileStyle: iconStyle === "dark" && iconStyleVariant === "auto" && !dark ? "default" : iconStyle
    // Settings > Appearance > Liquid Glass slider (state/appearance.json `glass`, 0 clear .. 1 tinted, 0.5 = the
    // unchanged recipe like NSGlassTintAmount unset: MAC-ANSWERS PC #67 C)
    property real glassTint: 0.5
    // Appearance > Theme > Color (multicolor, graphite, red, ...). Under Multicolor the shell's own surfaces
    // have no app accent, so they get Blue #007AFF, like apps without NSAccentColorName (MAC-ANSWERS R5)
    property string accent: "multicolor"
    property string highlight: ""      // appearance.json `highlight`: text highlight colour, "" = Automatic
    property bool blurAvailable: true
    // Accessibility (same file; services/A11y.qml holds the Hyprland side). Theme cannot import
    // qs.services (the services import qs), so it reads them itself. Increase contrast also
    // drops the glass, like macOS.
    property bool reduceMotion: false
    property bool increaseContrast: false
    // a duration of `v` ms: Reduce motion swaps motion for short dissolves, at most 150 ms
    function ms(v) { return reduceMotion ? Math.min(v, 150) : v; }
    // a distance or scale delta to animate: 0 under Reduce motion (crossfade only)
    function travel(v) { return reduceMotion ? 0 : v; }
    // hairlines and separators: clearly visible with Increase contrast
    function strokeAlpha(a) { return increaseContrast ? Math.max(a, 0.45) : a; }
    function stroke(r, g, b, a) { return Qt.rgba(r, g, b, strokeAlpha(a)); }
    readonly property bool solidMaterial: reduceTransparency || increaseContrast || !blurAvailable
    // set by services/Wallpaper from the luminance of the strip behind the menu bar
    property bool menuBarOnLight: false
    // one text colour for the whole bar from the mean gamma-encoded luma of the wallpaper behind it: uniform grey
    // <= 163 white, >= 166 black, so the switch is at 164.5/255 (MAC-ANSWERS.md Q-menubar-03)
    readonly property real menuBarLumaThreshold: 0.645
    // Reduce Transparency: the bar is opaque and ignores the wallpaper, dark text on the light bar (Q-menubar-32)
    readonly property bool menuBarLight: reduceTransparency ? !dark : menuBarOnLight
    // liquidglass Hyprland plugin loaded (config/hypr/hyprland.lua exports HYPRK_GLASS=plugin);
    // Reduce transparency still wins and uses the solid QML material
    readonly property bool compositorGlass: Quickshell.env("HYPRK_GLASS") === "plugin" && !reduceTransparency && !increaseContrast
    readonly property string hyprkRoot: Quickshell.shellDir + "/.."

    // ---------- fonts ----------
    // SF Pro is extracted by the assets agent into themes/fonts; fall back to Inter/Cantarell.
    readonly property var _families: Qt.fontFamilies()
    function pickFont(list) {
        for (const f of list)
            if (_families.indexOf(f) !== -1)
                return f;
        return list[list.length - 1];
    }
    readonly property string fontText: pickFont(["SF Pro Text", "SF Pro", "System Font", ".SF NS", "Inter", "Cantarell", "Sans Serif"])
    readonly property string fontDisplay: pickFont(["SF Pro Display", "SF Pro", "System Font", ".SF NS", "Inter Display", "Inter", "Cantarell", "Sans Serif"])

    FileView {
        id: appearanceFile
        path: (Quickshell.env("HYPRK_STATE") || theme.hyprkRoot + "/state") + "/appearance.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const o = State.parse(text(), { dark: theme.dark, reduceTransparency: theme.reduceTransparency, iconStyle: theme.iconStyle,
                                            iconStyleVariant: theme.iconStyleVariant, reduceMotion: false, increaseContrast: false, accent: "multicolor", highlight: "", glass: 0.5, mode: "" });
            theme.dark = o.dark;
            theme.reduceTransparency = o.reduceTransparency;
            theme.iconStyle = o.iconStyle;
            theme.iconStyleVariant = o.iconStyleVariant;
            theme.reduceMotion = o.reduceMotion;
            theme.increaseContrast = o.increaseContrast;
            theme.accent = o.accent;
            theme.highlight = typeof o.highlight === "string" ? o.highlight : "";
            theme.glassTint = isFinite(o.glass) ? Math.min(1, Math.max(0, o.glass)) : 0.5;
            theme.mode = typeof o.mode === "string" ? o.mode : "";
            theme.autoSync();
        }
    }

    // ---------- Appearance > Auto ----------
    // Settings switches Auto only while it runs; the shell runs the same clock (lib/sun.js, the rule of
    // settings/Parsers.js: dark while the sun at the time zone's city is below -3 degrees; light when the place is
    // not known). One single-shot timer to the sun's next crossing; the zone is looked up once, the first time the mode
    // is Auto. The answer goes into appearance.json's `dark`, which Settings and Finder read.
    // A timer does not count a sleep and does not see the clock being set: the menu bar clock's own minute tick calls
    // autoCheck() (no timer of its own), which runs the rule again when the crossing's time has passed or the sun's
    // answer is no longer the appearance shown, so a wake past a crossing or a clock change is corrected within a
    // minute.
    property string mode: ""            // appearance.json `mode`: "light", "dark" or "auto" ("" in a file without it)
    property var autoPlace: null        // { lat, lon } of the zone's city
    property bool autoReady: false      // the zone lookup has answered
    property double autoFlipAt: 0       // wall-clock ms of the crossing the timer waits for, 0 = none
    function autoCheck() {
        if (mode !== "auto" || !autoReady) return;
        const now = Date.now();
        if ((autoFlipAt > 0 && now >= autoFlipAt) || (autoPlace ? Sun.autoDark(now, autoPlace.lat, autoPlace.lon) : false) !== dark) autoSync();
    }
    Process {
        id: zoneLookup
        command: ["sh", "-c", "readlink /etc/localtime || head -n 1 /etc/timezone 2>/dev/null || echo; cat /usr/share/zoneinfo/zone1970.tab /usr/share/zoneinfo/zone.tab 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const nl = text.indexOf("\n");
                theme.autoPlace = Sun.zoneCoords(text.slice(nl + 1), Sun.zoneName(text.slice(0, nl)));
                theme.autoReady = true;
                theme.autoSync();
            }
        }
    }
    Timer { id: autoTimer; onTriggered: theme.autoSync() }
    function autoSync() {
        autoTimer.stop();
        autoFlipAt = 0;
        if (mode !== "auto") return;
        if (!autoReady) { zoneLookup.running = true; return; }
        const now = Date.now();
        const d = autoPlace ? Sun.autoDark(now, autoPlace.lat, autoPlace.lon) : false;
        if (d !== dark) {
            dark = d;
            // keep every other key as it is in the file; a file that does not parse is left alone
            const t = State.appearanceText(appearanceFile.text(), d, "auto");
            if (t !== "") appearanceFile.setText(t);
        }
        const flip = autoPlace ? Sun.nextAutoFlip(now, autoPlace.lat, autoPlace.lon) : 0;
        if (flip > 0) { autoFlipAt = flip + 1000; autoTimer.interval = Math.min(flip - now + 1000, 2147483647); autoTimer.start(); }
    }

    // the glass plugin must use the same appearance as our labels, else dark-mode
    // white text can land on light glass (its default "auto" follows the backdrop)
    // On Hyprland's socket, not a spawned hyprctl: the plugin cross-fades a snapshot of each output over 0.5 s when
    // this option changes (plugin 911cbe1, AppKit's NSGlobalPreferenceTransition), which only hides the switch if the
    // option is there before the first surface draws the other appearance. A process took 10 ms or more to start.
    function syncPluginAppearance() {
        if (!compositorGlass) return;
        Hyprland.dispatch(`function() hl.config({ plugin = { liquidglass = { appearance = "${dark ? "dark" : "light"}" } } }) end`);
    }
    // Two pairs of global shortcuts. hyprk:appearance-dark / -light are a manual switch (as `qs ipc call theme setDark`,
    // Control Center's Dark Mode button, Spotlight): the shell switches and writes `dark` and `mode` together, so
    // Settings, the Finder and GTK follow (judge #5: the shortcut wrote mode light with dark true and Settings stayed
    // Light on a dark desktop). hyprk:appearance-follow-dark / -light are Settings' own: it says so before it writes
    // appearance.json itself (the file's change arrived 146 to 1063 ms after Settings had switched, past the plugin's
    // 0.5 s cross-fade), so the shell only follows and leaves the file to Settings (two writers raced: the shell's
    // stale mode could land after Settings' write and undo Auto).
    GlobalShortcut { appid: "hyprk"; name: "appearance-dark"; description: "Dark appearance"; onPressed: theme.setAppearance(true) }
    GlobalShortcut { appid: "hyprk"; name: "appearance-light"; description: "Light appearance"; onPressed: theme.setAppearance(false) }
    GlobalShortcut { appid: "hyprk"; name: "appearance-follow-dark"; description: "Dark appearance (sent by Settings)"; onPressed: theme.dark = true }
    GlobalShortcut { appid: "hyprk"; name: "appearance-follow-light"; description: "Light appearance (sent by Settings)"; onPressed: theme.dark = false }
    // a manual switch: the appearance and the file's `dark` and `mode` (lib/state.js appearanceText), every other key
    // kept; choosing Light or Dark ends Auto, as in Settings
    function setAppearance(d: bool): void {
        dark = d;
        mode = d ? "dark" : "light";
        const t = State.appearanceText(appearanceFile.text(), d, mode);
        if (t !== "") appearanceFile.setText(t);
    }
    // the Liquid Glass slider for the plugin (its live-updatable 0..1 option; Mac: NSGlassTintAmount, a running app
    // re-reads it on the coordinated notification, MAC-ANSWERS PC #67 C2 item 5)
    // plugin option tint_amount (plugin/README.md, commit 2821fa0); the eval fires no reload event, so the plugin
    // is told to redraw its glass afterwards
    readonly property string pluginGlassOption: "tint_amount"
    function syncPluginGlass() {
        if (!compositorGlass || pluginGlassOption === "") return;
        Quickshell.execDetached(["sh", "-c", `hyprctl eval 'hl.config({ plugin = { liquidglass = { ${pluginGlassOption} = ${glassTint.toFixed(4)} } } })' && hyprctl liquidglass damage`]);
    }
    // window shadow and rim densities differ in light and dark (config/hypr/hyprland.lua hyprk_appearance)
    function syncWindowChrome() {
        Hyprland.dispatch(`function() if hyprk_appearance then hyprk_appearance(${dark}) end end`);
    }
    onDarkChanged: { syncPluginAppearance(); syncWindowChrome(); appearanceSwitched(); }
    // ---------- appearance handshake (the shell's half) ----------
    // The plugin holds the old picture of every output for a fixed 0.15 s before it cross-fades (appearance_hold): on a
    // loaded host the shell's restyled frames landed 234 to 526 ms after the switch, inside the fade. AppKit waits for
    // the apps' answers instead (at most 0.5 s). The shell's answer: after a switch every shown ShellWindow reports
    // when it has committed a frame built after it (components/AppearanceAck.qml); when the last one has, or 0.4 s
    // have passed, or no window is shown, one message goes to the compositor on Hyprland's socket:
    //     hyprk_appearance_ready("dark" | "light", serial)
    // a Lua global the session's config may define (the glass plugin's side: end the hold); `serial` is a ms time
    // stamp, so no two messages are alike. Where the function does not exist nothing happens. Sent with the plugin
    // only, once per change of `dark` (also the one that reads the saved appearance at start; not after a config
    // reload, where the option is sent again and the look is not new).
    property int appearanceEpoch: 0        // counts the switches; AppearanceAck follows it
    property int appearanceWaiting: 0      // windows that have not answered this switch yet
    function appearanceWait() { appearanceWaiting++; }
    function appearanceDone(epoch) {
        if (epoch !== appearanceEpoch || appearanceWaiting <= 0) return;
        if (--appearanceWaiting === 0) appearanceReady();
    }
    function appearanceSwitched() {
        appearanceWaiting = 0;
        appearanceEpoch++;                 // every shown window calls appearanceWait() from this change
        if (appearanceWaiting === 0) appearanceReady(); else appearanceWatchdog.restart();
    }
    function appearanceReady() {
        appearanceWatchdog.stop();
        appearanceWaiting = 0;
        if (!compositorGlass) return;
        Hyprland.dispatch(`function() if hyprk_appearance_ready then hyprk_appearance_ready("${dark ? "dark" : "light"}", ${Date.now()}) end end`);
    }
    Timer { id: appearanceWatchdog; interval: 400; onTriggered: theme.appearanceReady() }   // a window that draws no frame
    onCompositorGlassChanged: { syncPluginAppearance(); syncPluginGlass(); }
    onGlassTintChanged: syncPluginGlass()
    // a config reload (Hyprland reloads by itself when a config file changes) puts every plugin option back to the
    // config's value: tint_amount went back to 0.5 and appearance to "auto" while the shell still showed the saved
    // slider value and appearance (hyprctl reload: 0.2 -> 0.5). Send both again after each reload.
    Connections {
        target: Hyprland
        function onRawEvent(event: HyprlandEvent): void {
            if (event.name !== "configreloaded") return;
            theme.syncPluginAppearance();
            theme.syncPluginGlass();
        }
    }
    Component.onCompleted: {
        syncPluginAppearance();
        syncPluginGlass();
        syncWindowChrome();
        // the shared HyprK controls and motion helpers follow this appearance
        Tokens.dark = Qt.binding(() => theme.dark);
        Tokens.reduceMotion = Qt.binding(() => theme.reduceMotion);
        Tokens.glassTint = Qt.binding(() => theme.glassTint);
        Tokens.reduceTransparency = Qt.binding(() => theme.reduceTransparency);
        Tokens.increaseContrast = Qt.binding(() => theme.increaseContrast);
        Tokens.fontText = Qt.binding(() => theme.fontText);
        Accent.name = Qt.binding(() => theme.accent);
        Accent.highlight = Qt.binding(() => theme.highlight);   // text highlight colour, "" = Automatic (follows the accent)
    }

    IpcHandler {
        target: "theme"
        function toggle(): void { theme.setAppearance(!theme.dark); }
        function setDark(on: bool): void { theme.setAppearance(on); }
        function toggleTransparency(): void { theme.reduceTransparency = !theme.reduceTransparency; }
        function fonts(): string { return theme.fontText + " / " + theme.fontDisplay; }
        function material(): string { return theme.compositorGlass ? "plugin" : theme.solidMaterial ? "solid" : "qml"; }
    }

    // Text: whole fonts from Typography (ui/HyprK, the 27.2.1 text styles with optical size, tracking and real
    // weights), e.g. font: Typography.menu. The sizes below are for Texts that still set font.pixelSize (they get
    // neither the optical size nor the tracking; see Typography.qml) and for sizes that are not a system style.
    readonly property QtObject font: QtObject {
        readonly property real menuBar: Typography.styles.body.size   // menuBarFont 13 (27.2.1)
        readonly property real menu: Typography.styles.body.size      // menuFont 13 (27.2.1)
        readonly property real clock: Typography.styles.body.size     // menuBarFont 13
        readonly property real notifTitle: 13       // TODO verify
        readonly property real notifBody: 13        // TODO verify
        readonly property real notifTime: 11        // TODO verify
        readonly property real notifApp: 11         // TODO verify
        readonly property real switcherLabel: 13    // TODO verify
        readonly property real ccTileTitle: 12      // CC toggle and slider titles: SF 12 semibold (Q-panels-06)
        readonly property real ccTileSub: 11        // CC toggle subtitle: SF 11 regular (Q-panels-06)
        readonly property real ccModuleTitle: 13    // a CC module panel's title and headers: SF 13 bold (Q-panels-12)
        readonly property real ccModuleRow: 13      // its rows ("MacBook Air Speakers", "Sound Settings…": cap 9 pt on the photo)
        readonly property real dockLabel: 14        // Dock app-name label: system 14 (27.2.1 DOCKLabelLayer, Q-dock-08)
        readonly property real missionTitle: 13     // Mission Control window title: SF 13 bold (Q-dock-29)
        readonly property real widgetBig: 34        // TODO verify
        readonly property real widgetSmall: 11      // TODO verify
        readonly property real widgetPhotoTitle: 24 // Photos widget caption
        readonly property real widgetMonth: 10      // mini month digits

        readonly property int regular: Font.Normal
        readonly property int medium: Font.Medium
        readonly property int semibold: Font.DemiBold
        // no `bold`: SF Pro is a variable font and Qt 6.10 fakes bold on top of Font.Bold. Real bold =
        // Typography.font(pt, Typography.bold) or Typography.headline / systemBold
    }

    // ---------- colors ----------
    // Label colors follow the AppKit label hierarchy (labelColor, secondaryLabelColor, ...).
    readonly property QtObject color: QtObject {
        readonly property color label: Tokens.label
        readonly property color secondaryLabel: Tokens.secondaryLabel
        readonly property color tertiaryLabel: Tokens.tertiaryLabel
        readonly property color separator: theme.dark ? theme.stroke(1, 1, 1, 0.10) : theme.stroke(0, 0, 0, 0.10)
        readonly property color accent: Tokens.accent
        readonly property color textSelection: Accent.selectedText   // selectedTextBackgroundColor (text keeps its colour)
        readonly property color textOnAccent: "#FFFFFF"
        readonly property color red: theme.dark ? "#FF453A" : "#FF3B30"
        readonly property color indigo: theme.dark ? "#5E5CE6" : "#5856D6"

        // Menu bar: no background (MAC-ANSWERS.md Q9.1: bar pixels = desktop pixels over a solid wallpaper).
        // Text follows the wallpaper behind the bar, not the appearance (white over a checker in light and
        // dark mode, measured); the switch is at menuBarLumaThreshold (Q-menubar-03).
        readonly property color menuBarText: theme.menuBarLight ? "#000000" : "#FFFFFF"   // titles opaque 0 / 255 (Q-menubar-03)
        // status glyphs and the clock are slightly translucent: black ~38 on 255, white ~230 on 0 (Q-menubar-03)
        readonly property color menuBarStatusText: theme.menuBarLight ? Qt.rgba(0, 0, 0, 0.85) : Qt.rgba(1, 1, 1, 0.9)
        // Reduce Transparency: opaque bar grey 32 dark / 218 light, pill solid 57 / 190; Increase Contrast: pill
        // solid 117 in both (Q-menubar-32)
        readonly property color menuBarFill: !theme.reduceTransparency ? "transparent" : theme.dark ? "#202020" : "#DADADA"
        readonly property color menuBarPillSolid: theme.reduceTransparency ? (theme.dark ? "#393939" : "#BEBEBE")
                                                : theme.increaseContrast ? "#757575" : theme.glass.solid
        // menu separator: black a.10 light, white a.14 dark (Q-menubar-20); an alpha, not a vibrant step, on 27.2.1
        // (VIBRANCY-REA.md: .101-.103 / .140-.144 on every channel over Tahoe Light / Dark)
        readonly property color menuSeparator: theme.dark ? theme.stroke(1, 1, 1, 0.14) : theme.stroke(0, 0, 0, 0.10)
        // Reduce Transparency menu: opaque 20 dark, light 255 over white / 250 over black (Q-menubar-32)
        readonly property color menuSolid: theme.dark ? "#141414" : Qt.rgba(1, 1, 1, 0.98)
        readonly property color menuBarPillShadow: Qt.rgba(0, 0, 0, 0.05)   // 206 -> 196 just below the pill (measured), shape guessed

        // menu highlight
        readonly property color menuSelection: accent
        readonly property color menuSelectionText: "#FFFFFF"


        readonly property real disabledOpacity: 0.4      // unavailable CC tiles, TODO verify
    }

    // ---------- glass material ----------
    // QML stand-in for Liquid Glass until the compositor plugin lands.
    readonly property QtObject glass: QtObject {
        readonly property real blurRadius: 40                 // px, magick gaussian sigma ~ radius/2, TODO verify
        // tint over the blurred wallpaper
        readonly property color tint: theme.dark ? Qt.rgba(0.11, 0.11, 0.12, 0.55) : Qt.rgba(0.98, 0.98, 0.99, 0.55)   // TODO verify
        readonly property color tintStrong: theme.dark ? Qt.rgba(0.12, 0.12, 0.13, 0.72) : Qt.rgba(0.97, 0.97, 0.98, 0.74) // menus / spotlight
        // Reduce-transparency solid materials (opaque grey-white / dark grey)
        readonly property color solid: theme.dark ? "#2A2A2C" : "#ECECEE"          // TODO verify
        readonly property color solidDock: theme.dark ? "#303032" : "#E4E4E7"      // TODO verify
        readonly property color tintClear: theme.dark ? Qt.rgba(0.16, 0.16, 0.17, 0.30) : Qt.rgba(1, 1, 1, 0.26)         // Dock: light near-neutral clear glass, TODO glass-defaults.json
        // 1px inner highlight stroke (top-lit rim)
        readonly property color rimTop: theme.dark ? theme.stroke(1, 1, 1, 0.22) : theme.stroke(1, 1, 1, 0.55)                  // specular hairline, top-lit, TODO verify
        readonly property color rimBottom: theme.dark ? theme.stroke(1, 1, 1, 0.05) : theme.stroke(1, 1, 1, 0.12)                // TODO verify
        // 0.5px outer hairline that separates glass from light backgrounds
        readonly property color hairline: theme.dark ? theme.stroke(0, 0, 0, 0.35) : theme.stroke(0, 0, 0, 0.07)                // TODO verify
        readonly property real rimWidth: 1
        // drop shadow
        readonly property color shadow: Qt.rgba(0, 0, 0, theme.dark ? 0.45 : 0.22)   // TODO verify
        readonly property real shadowRadius: 24         // px of blurMax, TODO verify
        readonly property real shadowYOffset: 8         // TODO verify
    }

    // ---------- menu bar ----------
    readonly property QtObject menuBar: QtObject {
        // 34 pt: the only 27.2.1 measurement (AXMenuBar, NSMenu.menuBarHeight, MAC-ANSWERS Q-menubar-01), on the
        // notched Air. A display without a notch was not measured (none attached), so every output uses 34;
        // the headless "MBA" test output (2560x1664@2x) is the notched 13" Air's panel, where 34 is exact.
        readonly property int height: 34
        // text baselines from the bar top, as measured in the 34 pt bar: title and clock cap ink y 11..21
        // (Q-menubar-06, -09) -> baseline 21; Apple glyph ink y 8.5..24 (Q-menubar-07), the glyph sits
        // 0.11 pt below its baseline at appleSize -> 23.9
        readonly property real titleBaseline: 21
        readonly property real appleBaseline: 23.9
        // the Apple logo is U+F8FF of SF Pro (themes/fonts): ink 0.616 x 0.757 em, so 20.75 pt gives the
        // measured 13 x 15.5 pt ink (12.8 x 15.7) centred at x 27 in the 10..44 item (Q-menubar-07)
        readonly property real appleSize: 20.75
        // 27.2.1 AX title frames (Q-menubar-05, -07): Apple item 10..44 around its 13 pt glyph, every title = text
        // + ~10.5 a side, neighbours overlap 1 pt; the clock ends 20 pt from the right edge (Q-menubar-09)
        readonly property real leftMargin: 10
        readonly property real rightMargin: 20
        readonly property real appleWidth: 13           // content width of the logo item (Apple glyph ink 13)
        readonly property real titleHPadding: 10.5
        readonly property real titleSpacing: -1
        // open title pill: capsule 4 pt outside the title frame, y 5.25..28.75 (Q-menubar-05)
        readonly property real titlePillOutset: 4
        readonly property real titlePillHeight: 23.5
        // open status item pill: 10 pt outside the item frame, y 5..29 (Q-menubar-11)
        readonly property real statusPillOutset: 10
        readonly property real statusPillHeight: 24
        // selection pill corner radius 12, continuous (MENUBAR-REA-27.2.1.md); on the 23 pt pill it is a capsule
        readonly property real titleRadius: 12
        readonly property int statusIconSize: 16         // TODO verify
        // system items 16 pt apart (Q-menubar-09); item frame = glyph + pads (Wi-Fi 16.5 in 22, CC 13.5 in 26,
        // battery and clock 0)
        readonly property real statusSpacing: 16
        readonly property real statusHPadding: 3
    }

    // ---------- menus (pull-downs and context menus, MenuDropdown.qml) ----------
    readonly property QtObject menu: QtObject {
        readonly property int radius: 12                 // SPEC 9.9.2: context menu glass radius 12
        readonly property int padding: 5                 // SPEC.md 7: menu top/bottom padding 5
        readonly property int itemHeight: 24             // SPEC.md 7: glass menu line height 24
        readonly property int itemInset: 5               // SPEC 9.9.2: selection x+5, width-10
        readonly property int itemRadius: 7              // SPEC 9.9.2: glass menu selection radius 7
        readonly property int shortcutGap: 22            // SPEC 9.9.2: gap before the key-equivalent column
        readonly property int separatorHeight: 11        // separator row 11, line at y 5..6 (Q-menubar-20)
        // a pull-down opens at title x - 5, 1 pt below the bar (Q-menubar-14)
        readonly property real offsetX: -5
        readonly property real offsetY: 1
        readonly property real screenMargin: 6           // right clamp 6 pt, bottom = visible bottom - 6 (Q-menubar-14, -27)
        // row content x from the menu's left edge (Q-menubar-15..18, -23): text 16, or 30 when some row has a
        // state; rows with an icon: icon centred at 24 / 36, text at 40 / 51; check glyph centred at 18.25
        readonly property real textX: 16
        readonly property real stateTextX: 30
        readonly property real iconX: 24
        readonly property real iconTextX: 40
        readonly property real stateIconX: 36
        readonly property real stateIconTextX: 51
        readonly property real checkX: 18.25
        // key column right edge W - 18.5, modifiers end 3 pt left of it; chevron centred at W - 23.25; a
        // plain row ends ~17 pt before the edge (single "A" menu 41 wide)
        readonly property real keyRight: 18.5
        readonly property real modifierGap: 3
        // AppKit lays the shortcut out as columns per menu: width = state/text x + widest label + 43.5 + widest
        // modifier run + 3 + widest key ink + 18.5. 43.5 fits the Finder, File, Edit and View menus of the 27.2.1
        // dump to +-1.5 pt (finder-menus-ax.txt widths 195/273/217/262; Option alternates and the row icons do not
        // count, Q-menubar-17, -25). Modifier glyphs are drawn one by one 3.5 pt apart, ink to ink (Q-menubar-18)
        readonly property real columnGap: 43.5
        readonly property real modifierSpacing: 3.5
        readonly property real chevronX: 23.25
        // every row of a menu with a submenu row ends 48 pt before the edge, the chevron in that column (Menus.rowEnd)
        readonly property real submenuTrailing: 48
        readonly property real trailing: 17
        readonly property real separatorInset: 16        // line x 16..W-16, at row y 5..6 (Q-menubar-20)
        // activation: highlight off 4 frames, on 3, then the menu fades (Q-menubar-24); the pauses end half a frame
        // before the frame they change on (MenuDropdown's blink runs on the render clock)
        readonly property int blinkOff: 58
        readonly property int blinkOn: 42
        // the Dock's menus (Dock.app's own, a menu opened above the Dock): on for 4 frames (MAC-ANSWERS-16.md R16.1)
        readonly property int blinkOnDock: 58
        // an `afterFade` item (MenuDropdown) runs this long after the fade's last frame: the Dock then moves in the
        // 22nd frame after the highlight went off, as the Mac's (mcap: 22nd in 7 of 8 runs; 20-21 without the pause, 22 / 24 with 25 ms)
        readonly property int afterFadePause: 16
        // submenu (Q-menubar-23): opens 0.22 s after its row is highlighted, complete in one frame; its frame overlaps
        // the parent's right edge by 5 pt and starts 5 pt above the row, so its first row lines up with it
        // The pause is 30 ms shorter: it ends on the 12th frame of the menu's window and the submenu's surface (mapped
        // from the start of the delay) draws on the next, the 13th (mcap session 20: 13 frames in 4 of 6, 14 in 2; on
        // Qt's 220 ms timer 14 to 15, on a 190 ms timer 13 to 15)
        readonly property int submenuDelay: 190
        readonly property real submenuOverlap: 5
    }

    // ---------- dock ----------
    // Geometry per tile size: lib/dock.js metrics() (27.2.1 AX frames, Q-dock-02..07). Colours here.
    // Tile size: state/dock.json `size` (lib/state.js dockTile, 64 when absent, Q-dock-02).
    readonly property QtObject dock: QtObject {
        // separator and running dot: vibrant plus-lighter +65/255 and +125/255 in dark (Q-dock-06, Q-dock-07),
        // drawn additively (shaders/plusfill.frag). Light is plus-darker -57/255 and -128/255, which an
        // over-blend cannot do: there it stays a black line / dot at these alphas (by eye, TODO verify)
        // (premultiplied rgba for shaders/plusfill.frag: rgb is added, alpha covers)
        readonly property vector4d separator: theme.dark ? Qt.vector4d(65 / 255, 65 / 255, 65 / 255, 0) : Qt.vector4d(0, 0, 0, theme.strokeAlpha(0.55))
        readonly property vector4d dot: theme.dark ? Qt.vector4d(125 / 255, 125 / 255, 125 / 255, 0) : Qt.vector4d(0, 0, 0, 0.55)
        // label pointer marker for the plugin (plugin/README.md "Dock label pointer"): a rect this size hung 1 pt under the
        // pill with a hole at its top-left + 1 becomes Apple's pointer (a 16 pt square turned 45 deg, corner 2.5, centre
        // 4 pt above the pill's bottom, union smoothness 25: Dock ECCartoucheGlassLayerController, REA 27.2.1 3)
        readonly property size labelPointer: Qt.size(16, 7)
        // Dock menu placement (Q-dock-10, live/dock/dock-menus.json geometry): its window x = icon centre - 40, its
        // bottom = the Dock background top, the body inset 13 in it. So the body starts 27 left of the icon centre
        // and reaches to the right, its bottom 13 above the Dock. That 13 is the tail's height (CoreUI's menu path,
        // GAPS-REA-dock.md 1): Glass.tail draws it under the body, its tip at the icon centre (lib/dock.js menuTail)
        readonly property real menuLeft: 40
        readonly property real menuInset: 13
        readonly property color labelText: theme.dark ? Qt.rgba(244 / 255, 244 / 255, 244 / 255, 1) : Qt.rgba(37 / 255, 37 / 255, 37 / 255, 1)   // Q-dock-08
        // tint over the plugin glass: none. The plugin's dock recipe alone gives the Mac's body over white, grey and
        // black in both modes (light 229/134/38, dark 176/107/12 with the probe's max luma 0.75, MAC-ANSWERS #53)
        readonly property color pluginLift: "transparent"

        // Downloads stack (modules/DockStack.qml; layout math in lib/dockstack.js). Sources: reference/re/27.2.1/
        // MOTION-REA-27.2.1.md section 3, GAPS-REA-dock.md section 4, MAC-ANSWERS.md Q-dock-12
        readonly property QtObject stack: QtObject {
            // the pile's items drawn in their decoded boxes (lib/dockstack.js pile). A picture's thumbnail is fitted to
            // 0.895 of its box: dock-dark.png, the photo behind the ZIP is 48 px wide at tile 66 px, its box 104/128 of
            // the tile. The ZIP page (themes/icons/system/ZipDocument-154.png, face 132 of 154 px) is drawn so its face is
            // 58 px tall at tile 66 px as in dock-dark.png / dock-light.png: 58 / (116/128 x 66) = 0.970 of the box
            readonly property real photoFit: 48 / (104 / 128 * 66)
            readonly property real zipScale: 58 / (116 / 128 * 66) * 154 / 132
            // open / close: the CATransaction default 0.25 s (+[CATransaction animationDuration] QuartzCore 0x18dd0a9b8
            // `fmov d8, #0.25`; of the Dock's 36 setAnimationDuration: calls none is on the stack paths or their
            // callers except Shift slow motion, 5 s: MOTION-REA Round 3, R3.1). Fan position: kCAMediaTimingFunction-
            // EaseInEaseOut (0x100064300); its rotation / size and the whole grid are implicit animations, CA's
            // "default" curve (0.25, 0.1, 0.25, 1) (QuartzCore table 0x18e119380, _CALayerCreateImplicitAnimation)
            readonly property int duration: 250
            readonly property var gridCurve: [0.25, 0.1, 0.25, 1, 1, 1]
            // fan labels (-[DOCKStackFanItemLayer layoutSublayers] 0x100042d78, _setText: 0x100042474): glass pill radius 13
            // (26 tall, as the hover label's cartouche), its right-centre 5 pt left of the 64 pt item box, SF 13
            readonly property real fanItem: 64
            readonly property real fanLabelGap: 5
            readonly property real fanLabelHeight: 26
            readonly property real itemFont: 13       // +[DOCKStackExpandedItemLayer itemFont] 0x10001f894: UI font 13
            // grid (-[DOCKStackGridLayer layout] 0x10001bfb8, ECCartoucheGlassLayerController size 2): radius 26 (Mac shot
            // "about 28" by eye), tail a 24 pt square turned 45 deg, corner 5, centre 5 above the body, in a 12 pt band;
            // non-glass radius 5 is the Mac's own fallback for a missing glass (not used: our fallback is the QML glass)
            readonly property real gridRadius: 26
            readonly property real gridTailBand: 12
            readonly property real gridTail: 24
            readonly property real gridTailCorner: 5
            readonly property real gridTailOffset: 5
            // grid cell (-[DOCKStackGridItemLayer layoutSublayers] 0x10001f44c): icon cell - 28 at (14, 6 from the top),
            // the name in the bottom 22
            readonly property real gridInset: 14
            readonly property real gridNameHeight: 22
            // grid frame: grid 17 from the sides, 30 from the top with the title (AX: group 895,613, scroll area
            // 912,643, live/dock/dock-live.json); the title's AX frame 7 below the top, 19 tall
            readonly property real gridSide: 17
            readonly property real gridTop: 30
            readonly property real titleTop: 7
            readonly property real titleHeight: 19
            readonly property real titleFont: 15        // guessed: a 19 pt AX line fits SF 15 bold (not measured)
            // the tile while a stack is open, measured (MOTION-REA Round 4, R4.1; reference/screens/27.2.1/dock/
            // stack-fan-open-dark.png, tile 31 at 2x): a dark plate 25 x 25 pt (0.806 of the tile, the icon grid), corner
            // about 5.6, centred on the icon box; over the Dock glass it reads (47,50,87) at the top to (22,24,45) at the
            // bottom, which is grey 86 at alpha .49 to grey 27 at alpha .70 over the glass's (10,16,88). On it a white
            // chevron, ink 9.75 x 5.25 pt, stroke about 1.1 pt, its centre 0.4 pt below the plate's. Both in tile units
            readonly property real chevronPlate: 25 / 31
            readonly property real chevronPlateRadius: 5.6 / 31
            readonly property color chevronPlateTop: Qt.rgba(86 / 255, 86 / 255, 86 / 255, 0.49)
            readonly property color chevronPlateBottom: Qt.rgba(27 / 255, 27 / 255, 27 / 255, 0.70)
            readonly property real chevronWidth: 9.75 / 31     // ink, stroke included
            readonly property real chevronHeight: 5.25 / 31
            readonly property real chevronStroke: 1.1 / 31
            readonly property real chevronDrop: 0.4 / 31
        }
    }

    // ---------- notifications ----------
    readonly property QtObject notif: QtObject {
        // card geometry: MAC-ANSWERS "Notification Center glass and transitions (PC #62)" 1a and the 2x crops in
        // reference/screens/27.2.1/nc (hover-off-on-dark-grey.png, stack-*.png); banners use the same card
        readonly property int width: 344                 // x 1350..1694
        readonly property int radius: 20                 // RoundedRectangle(cornerRadius: 20, style: .continuous)
        readonly property int padX: 13                   // card edge to the icon
        readonly property int padY: 12                   // 75 tall with three 17 pt lines
        readonly property int padRight: 14               // the time label's right edge
        readonly property int iconSize: 32
        readonly property int iconGap: 13                // icon to text
        readonly property int lineHeight: 17
        readonly property int marginTop: 10              // below the menu bar (top at y 44 under a 34 pt bar)
        readonly property int marginRight: 16            // 1694 on a 1710 pt screen
        readonly property int spacing: 6                 // between cards
        readonly property int timeout: 4970              // ms a banner stays (PC #62 3a)
        readonly property int leaveAfterHover: 1000      // ms a hovered banner stays after the pointer leaves (MAC-ANSWERS banners: ≈ 1 s)
        readonly property int maxBodyLines: 4
        readonly property int stackPeek: 8               // each plate of a collapsed stack shows 8 pt
        readonly property var plateInset: [17, 24]       // plate 1 and plate 2, per side
        // plates are QML strips (over black they are darker than the glass): fill k at alpha a over the dimmed
        // backdrop, fitted to plate 1 dark 129 / 88 / 15 and light 204 / 155 / 102 over white / grey / black (plate 2
        // dark 130 / 86 / 14, light 199 / 148 / 94), each with a bright 1 px top line (22 dark / 112 light over black)
        readonly property var plateFill: theme.dark ? [Qt.rgba(55 / 255, 55 / 255, 55 / 255, 0.37), Qt.rgba(52 / 255, 52 / 255, 52 / 255, 0.36)]
                                                    : [Qt.rgba(223 / 255, 223 / 255, 223 / 255, 0.46), Qt.rgba(214 / 255, 214 / 255, 214 / 255, 0.443)]
        readonly property color plateLine: theme.dark ? Qt.rgba(1, 1, 1, 0.03) : Qt.rgba(1, 1, 1, 0.065)
        // hover: x circle 20 pt at (-6, -4) from the card's top-left; "Show" capsule 64 x 22, 9.5 / 9 from the
        // bottom-right corner, crossfading with the time label
        readonly property int closeSize: 20
        readonly property point closeAt: Qt.point(-6, -4)
        readonly property size showSize: Qt.size(64, 22)
        readonly property point showInset: Qt.point(9.5, 9)
    }

    readonly property QtObject nc: QtObject {          // Notification Center (PC #62, 27.2.1)
        readonly property int width: 344                 // the card column
        readonly property int marginTop: 10
        readonly property int marginRight: 16
        readonly property int spacing: 16                // between widgets
        readonly property int widgetRadius: 22           // continuous r 22-24
        readonly property int widgetSmall: (width - spacing) / 2   // 164
        readonly property int widgetPadding: 16
        readonly property int editGap: 56                // last widget to "Edit Widgets"
        readonly property int headerHeight: 38           // app name row of an unfolded stack: the front card moves 44 pt
        readonly property int pillHeight: 24             // "Edit Widgets" and its x (r 12, padding 10)
        readonly property int pillSmall: 20              // "Show less" and a stack's x (r 10, padding 10)
        readonly property int pillGap: 6
        readonly property real upNextSplit: 0.56         // Calendar: month grid left, Up Next right
        readonly property int monthCell: 17              // mini month cell
        readonly property int monthGap: 2
        readonly property int upNextGap: 6               // date to the event list
        readonly property color onImage: "#FFFFFF"       // text over the Photos widget
        readonly property color onImageSecondary: Qt.rgba(1, 1, 1, 0.85)
        readonly property real photoScrim: 0.45          // bottom gradient behind the caption
        readonly property real photoAspect: 0.48         // Photos widget height / width, measured
        // widgets follow the "Dark" widget style in light and dark alike (PC #62 1b): the Calendar is opaque,
        // (32,31,31) at the top to 13 at the bottom, white text
        readonly property color calendarTop: Qt.rgba(32 / 255, 31 / 255, 31 / 255, 1)
        readonly property color calendarBottom: Qt.rgba(13 / 255, 13 / 255, 13 / 255, 1)
        readonly property color widgetLabel: "#FFFFFF"
        readonly property color widgetSecondary: Qt.rgba(1, 1, 1, 0.55)
        // buttons are _Glass.regular on hyprk-overlay (the plugin's regular face) with no lift; pressed: .quaternary
        readonly property color pillPress: theme.dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.1)
        readonly property color clockBg: "#1C1C1E"
        readonly property color clockFace: "#F5F5F5"
        readonly property color clockHand: "#1C1C1E"
        readonly property color clockSecond: "#FF9500"
        // Column backdrop (PC #62 1d and Static RE): NotificationsListShadowBackground, a RoundedRectangle(20,
        // continuous) with a black shadow at 0.2 x progress, radius 30, no offset, the same in light and dark. As a
        // filled shadow it reads x 0.8 under the cards; the darker x 0.71 / 0.74 in the 6 pt gaps and just outside
        // the cards is that field times the cards' own shadows, which the plugin draws around each card shape
        // (outside it), so they are not repeated here. One feathered shadow on a layer below the cards (the cards'
        // glass samples it), edge 16 pt outside the cards (the 376 pt column frame), riding with the panel.
        // Blur sigma about 3 pt inside: not done here.
        readonly property color backdropDim: Qt.rgba(0, 0, 0, 0.2)
        readonly property int backdropRadius: 20
        readonly property int backdropOutset: 16
        readonly property real backdropBlur: 50
    }

    // ---------- control center ----------
    readonly property QtObject cc: QtObject {
        // macOS 26/27 Control Center has no panel background: separate glass
        // modules float over the desktop. SPEC.md 9.9.1 (ControlCenter.app bento grid):
        // 76pt cell pitch, 12 gap, tiles 64 (1x1), 140x64 (2x1), 140x140 (2x2), 292x64 (4x1)
        readonly property int columnWidth: 140           // SPEC 9.9.1: rect2x1 width
        readonly property int gap: 12                    // SPEC 9.9.1
        readonly property int width: columnWidth * 2 + gap   // SPEC 9.9.1: 292 = rect4x1 tile span (304 grid incl. 6pt half-gaps)
        readonly property int tileHeight: 64             // SPEC 9.9.1: 1x1 height
        readonly property int tileRadius: tileHeight / 2 // capsule
        readonly property int buttonGlyph: 24            // round 64 buttons: ~24 pt symbols (Q-panels-07)
        // darkening veil over the plugin glass: white labels need ~5:1 like the reference
        // the plugin's controlcenter recipe gives the reference grey frost itself; no extra veil
        readonly property color pluginLift: "transparent"
        // the panel's dim under the tiles (MAC-ANSWERS "Glass checks (#53)"): the gap reads 0.898 x backdrop and
        // the tiles' glass samples it, so a tile is the controlcenter face over the dimmed backdrop (white 186,
        // grey 109, black 32). Feathers out over about 100 pt. Light and dark alike.
        readonly property color dim: Qt.rgba(0, 0, 0, 0.102)
        readonly property real dimFeather: 100
        readonly property color tileTint: theme.dark ? Qt.rgba(0.12, 0.12, 0.13, 0.45) : Qt.rgba(0.30, 0.28, 0.27, 0.42)   // QML material: dark neutral frost
        readonly property color tileSolid: theme.dark ? "#3A3A3C" : "#8E8E93"
        readonly property color text: "#FFFFFF"
        readonly property color toggleOnBg: "#FFFFFF"
        readonly property color toggleOnIcon: Tokens.accent   // follows the accent (Blue under Multicolor), not measured
        readonly property color toggleOffIcon: "#FFFFFF"
        // Focus on: the moon in the Do Not Disturb mode's colour, not the accent (Q-panels-02: (119,131,254) Display P3
        // at the most saturated pixel = (116,131,255) sRGB); Control Center reads the same in both appearances (Q-panels-01)
        readonly property color focusOnIcon: Qt.rgba(116 / 255, 131 / 255, 1, 1)
        // capsule toggles when off: white at 25 % over the tile, white glyph (MAC-ANSWERS #53: 203 / 146 / 88
        // over a 186 / 109 / 32 tile, all glyphs 255)
        readonly property color capsuleOffBg: Qt.rgba(1, 1, 1, 0.25)
        readonly property color capsuleOffIcon: "#FFFFFF"
        readonly property color sliderFillColor: "#FFFFFF"

        // ---- 27.2.1 measurements (MAC-ANSWERS.md Q-panels-05..-11, "Glass checks (#53)"), pt ----
        readonly property int top: 12                    // grid top 12 below the menu bar (Q-panels-05)
        readonly property int right: 14                  // grid right margin (Q-panels-05)
        // 2x1 toggle tile (Q-panels-07): circle 36 at x 14, centred; text from x 56 (ink 56.5); right pad 10;
        // with a subtitle the title baseline is 27.5 and the subtitle's 44
        readonly property int circle: 36
        readonly property int circleX: 14
        readonly property real circleGlyph: 0.5          // ~18 pt symbols in the 36 circle
        readonly property int textX: 56
        readonly property int textRight: 10
        readonly property real titleBaseline: 27.5
        readonly property real subtitleBaseline: 44
        // three lines (Mac photo 2026-11-11 23.11.21, 1.9 px/pt: AirDrop "Contacts Only" wraps; tile top 430.5 px,
        // baselines 473 / 498 / 524 px): 22.4, 35.5, 49.2 (13.1 title to subtitle, 13.7 between subtitle lines). A title
        // that wraps (Focus on: "Do Not Disturb", Q-panels-02) takes the first two of these: not measured, inferred
        readonly property var threeLineBaselines: [22.4, 35.5, 49.2]
        // labels over the tile T (#53): title = white at 85 % (245/233/221 over 186/109/32); subtitle = plus-lighter
        // T + 140 (255/249/172), drawn by shaders/plustext.frag; slider titles and glyphs 255
        readonly property color title: Qt.rgba(1, 1, 1, 0.85)
        readonly property real subtitleLift: 140 / 255
        // slider module 292 x 64, continuous r 24 (Q-panels-05, -08): title ink x 17, cap top 13.5;
        // track 4 tall, centre y 42, x 36.5..254 (Display); end glyphs centred at x 23 and 24.25 from the right;
        // fill 255, track plus-lighter T + 20
        readonly property int sliderRadius: 24
        readonly property real sliderTitleX: 16          // "D" ink at 17 (its side bearing is 1)
        readonly property real sliderTitleBaseline: 22.5 // cap top 13.5
        readonly property real trackX: 36.5
        readonly property real trackRight: 38
        readonly property real trackHeight: 4
        readonly property real trackY: 42
        readonly property real glyphLeft: 23
        readonly property real glyphRight: 24.25
        // Sound's AirPlay-audio output button inside the slider (Q-panels-04; read from screens/27.2.1/panels/
        // controlcenter-light.png: a 26 pt circle, white ~20 %, centred 26 pt from the right edge, the slider's end
        // glyph and track 37 pt further left)
        readonly property real outputButton: 26
        readonly property real outputButtonRight: 26
        readonly property real outputRoom: 37
        // "Edit Controls": capsule 93.5 x 24 (r 12), centred, 16 below the last row (Q-panels-04, -05)
        readonly property real editW: 93.5
        readonly property real editH: 24
        readonly property real editGap: 16
        readonly property real trackLift: 20 / 255
        // knob: none at rest, white 18 x 14 while the module is hovered; pressed, the shared HyprK Knob lens about
        // 24 x 20 centred on the fill end (Q-panels-08, -09; cc-sound-slider-rest-hover-drag-overdrag-dark-grey127.png:
        // hover knob 35 x 28 px at 2x). The lens's look and timing are the shared ones (Tokens.control.knobLens*,
        // Tokens.motion.sliderLiftCurve): Q-panels-09 saw it "within about 3 frames" by eye, the 120 Hz layer samples of
        // the Settings slider give 144 ms. Past an end the track and fill stretch up to about 5 pt and spring back in
        // 0.13 s
        readonly property real knobW: 18
        readonly property real knobH: 14
        // the hover knob's shadow is 0.75 of the shared knob's (R18.3, live/r18/cc-sound-*-hover.png: the module under
        // the knob, per px down from it, light over white -15 -12 -10 -9 -7 -7 -5 and dark -4 -4 -3 -2 -2 -2 -1; the
        // shared black .10 pair drew -20 -17 -13 -11 -9 -8 -7 and -5 -5 -4 -3 -3 -2 -2)
        readonly property real knobShadowScale: 0.75
        // the lens's FACE: 22 x 18, the dark 1 pt line (Knob, Tokens knobLensOutlineWidth) lies outside it. The dark
        // grey127 frame 3 (2 px/pt) has the rim line's centres 44 x 38 px apart (x 26..70 on row 366, y 341..379 on
        // the lens's middle column) with the module held at 1.009 (583 -> 588.5 px wide): 21.8 x 18.8 pt, so the face is
        // 20.8 x 17.8 and the outer edge about 23 x 20 ("about 24 x 20" in Q-panels-08 is that outer edge). A 24 x 20
        // face drew the line 24 x 20.75 pt apart, 2 pt too wide and tall (SCALING-AUDIT.md, CC lens). 22 x 18 keeps the
        // hover knob's +4 pt per axis
        // R18.3 (live/r18/cc-sound-*-{held,drag1..3}.png, lossless 2x stills of the real module, 4 backdrops): the rim
        // line's centres are 47.7 x 37.5 px apart (x 196.5 .. 244 round the fill end at 220, rows 61.5 .. 99); 22 x 18
        // drew 46.7 x 38.5 (rows 61.5 .. 100). So 22.5 x 17.5, and lensDy 0.25
        readonly property real lensW: 22.5
        readonly property real lensH: 17.5
        // the module's glass under the pointer: +7 levels while hovered; while the knob is held about 3.5 % of its own
        // level more (dark 57 -> 59, over blue 31 -> 32, light over white 193 -> 199..203 round the pointer and 193 ->
        // 194 at 100 pt from it: drawn flat, from the module's level as lensEmpty* below gives it) (R18.3,
        // ControlCenter.qml SliderModule)
        readonly property real sliderHoverLift: 7 / 255
        readonly property real sliderHeldGain: 0.035
        // the held lens's sample gain in dark: the white fill reads 254 outside the lens and 222 inside it (mean of rows
        // 356-362 between the lens's left rim and the fill end, frame 3 of the dark grey127 picture above); the shared
        // Settings fit (Tokens knobLensGain .702, haze .091) drew 187: gain (222 - .091 x 255) / (.909 x 254) = .86
        // (GLASS-HIG.md round 2). Light: no Mac frame of the held CC knob, the shared value
        readonly property real lensGain: theme.dark ? 0.86 : Tokens.control.knobLensGain
        // the held lens takes the decoded held-slider-knob stack (Knob lensDecoded; lensGain is then unused): the fill
        // inside it ramps 233 -> 197 from the left rim to the fill end (frame 3 above: 232 -> 190; the fitted gain drew
        // 218 -> 209) and its shadow is the ring term outside the glass, darkest 4-8 pt under the rim (GLASS-HIG.md
        // round 6). Light: no Mac frame, the same filter
        readonly property bool lensDecoded: true
        // its ring shadow at the dump's 0.4 (the dark frame's fill ramp and the shadow under the lens, GLASS-HIG.md round 6)
        // and the dump's dark specular rim, as the Settings slider (Tokens sliderLens*): slider-held-cc-light.png reads
        // 71 / 67 at the top over the module's 116 (tone curve 67) and 49-60 at the ends (43); dark 41-60 over 106 (60 /
        // 37). Until round 7 a flat black line, .4 of 0.5 pt in light (GLASS-HIG.md round 7)
        // Light too: slider-held-cc-light.png reads the fill inside the lens 218 (0.4: 220; the Settings slider's light
        // 0.14: 240) and the module 100 -> 87 from 2 to 8 pt under the lens (0.4: 97 -> 87; 0.14: 103 -> 100). Over the
        // module itself the lens reads 121-127 (0.4 drew 111-121): the term over an empty source is approximate
        // (LensGlass emptyLevel), not refitted (GLASS-HIG.md round 7)
        // Decoded since: ControlSliderRecipe takes 0.4 in a dark colour scheme and 0.15 in light (SliderSpecModifier,
        // GLASS-HIG.md section 19); the light frame's 0.4 says the Control Center modules draw in the dark scheme in both
        // appearances, as their white labels do (inferred: the module's environment is not traced)
        readonly property real lensRingOpacity: 0.4
        readonly property bool lensRimDecoded: true
        // the lens cannot sample the module glass under it (empty source): its terms are drawn for a backdrop of the
        // module's level next to the lens (slider-held-cc-light.png 100-116 -> .43; the dark grey127 frame 106 -> .42)
        // R18.3: the module's level follows the wallpaper under it, in both appearances alike (live/r18 idle stills: 50
        // over the flat (30,30,32), 186 over white, (24,24,255) over blue; 106 over grey 127 above): 0.125 + 0.604 x
        // the wallpaper's luma (.196 .426 .729), plus the lift under the pointer. With the fixed .42 the held lens over
        // a white wallpaper drew its rim line 111 and its upper half 10 too dark (Mac 146; ControlCenterSlider.qml)
        readonly property real lensEmptyBase: 0.125
        readonly property real lensEmptySlope: 0.604
        // no press layer on the fill: the light fill reads 255 outside the lens while held and just after release
        // (slider-held-cc-light.png, slider-released-cc-light.png); ours was 229 with the slider's black .098
        readonly property color pressOverlay: theme.dark ? Tokens.control.sliderPressOverlay : "transparent"
        // the held lens sits 0.5 pt below the track's centre: in frame 3 the fill rows are rows 15-22 of the 40 px rim
        // box (centre 18.5 against the box's 19.5); centred, ours were 16-23, a pixel deeper in the ring shadow's band,
        // fill mean 214.4 against the Mac's 221.9; moved, 217.9 (GLASS-HIG.md round 6)
        // R18.3: with the lens 17.5 pt tall, 0.25 (the rim's rows 61.5 .. 99 round the fill's 76 .. 83)
        readonly property real lensDy: 0.25
        readonly property real overdrag: 5
        readonly property int overdragBackMs: 130
        // a module opened from the grid (Q-panels-12): one glass panel of the tiles' family in the grid's place, 308 wide,
        // 6 below the menu bar (top 40 on a 34 pt bar), 8 from the right edge, continuous r 16, contents 14 in; rows
        // 32 tall, 5 in (298 wide); the hovered row a capsule +21 over grey 109 (white .144); 1 pt separators; headers
        // SF 13 bold. Separator and header colours from the Sound module photo (JPEG, rough): the line +20 over the
        // panel (white .11), "Output" at about .74 of the device names' white
        readonly property real modulePanelWidth: 308
        readonly property real modulePanelRadius: 16
        readonly property real modulePanelInset: 14
        readonly property real modulePanelTop: 6
        readonly property real modulePanelRight: 8
        readonly property color moduleHeader: Qt.rgba(1, 1, 1, 0.74)
        readonly property color moduleSeparator: Qt.rgba(1, 1, 1, 0.11)
        readonly property color moduleRowHover: Qt.rgba(1, 1, 1, 0.144)
        // the Sound module (photo 2026-11-11 23.11.22, 2.003 px/pt; modules/CcSoundPanel.qml has the readings)
        readonly property real soundTitleBaseline: 25.5
        readonly property real soundSliderY: 46.2
        readonly property real soundTrackX: 34.4
        readonly property real soundTrackW: 229.2
        readonly property real soundTrackHeight: 6
        readonly property real soundKnobW: 20
        readonly property real soundKnobH: 16
        readonly property real soundGlyphLeft: 21.2       // ink centres
        readonly property real soundGlyphRight: 280.6
        readonly property real soundSeparator1: 64.1
        readonly property real soundHeaderBaseline: 84.9
        readonly property real soundRowsTop: 92.1
        readonly property real soundRowPitch: 32
        readonly property real soundRowInset: 5
        readonly property real soundDisc: 26               // 25.5 - 26 on the photo, "about 26" (task note)
        readonly property real soundDiscX: 14.5
        readonly property real soundDeviceGlyph: 10.5      // speaker.wave.2.fill: ink 14 pt wide on the photo
        readonly property real soundTextX: 49.4
        readonly property real soundTextDrop: 4.7          // baseline under the row's middle
        readonly property real soundSeparatorGap: 5.5      // last row's bottom to the separator
        readonly property real soundFooterBaseline: 20.2   // "Sound Settings…" under that separator
        readonly property real soundFooterHeight: 32.6     // the separator to the panel's bottom (258 with four devices)
        // Now Playing 2x2 (Q-panels-11): art 40 at (14, 14), continuous r 10, white 14 %; title at y 72;
        // buttons 30 x 30 at y 96, x 15 / 55 / 95
        readonly property int npArt: 40
        readonly property int npArtXY: 14
        readonly property int npArtRadius: 10
        readonly property color npArtFill: Qt.rgba(1, 1, 1, 0.14)
        readonly property int npTitleY: 72
        readonly property int npButton: 30
        readonly property int npButtonsX: 15
        readonly property int npButtonsY: 96
        readonly property int npButtonPitch: 40
    }

    // ---------- spotlight ----------
    readonly property QtObject spotlight: QtObject {
        readonly property int maxApps: 5                 // app rows among the results

        // ---- 27.2.1 (MAC-ANSWERS.md Q-panels-14..-26, Q-dock-23..25), pt ----
        // Two glass shapes: the search capsule and, 10 below it, a results / mode list / mode panel. Drawn the
        // same in light and dark (the Mac's account, icon style Dark, showed the dark capsule and white text in
        // both; other icon styles not measured).
        readonly property int barW: 520
        readonly property int barH: 87
        // calculator answer (Q-panels-21): the bar grows to 172.5 with a result card (19 inset, 60 tall, capsule) under
        // the field, the answer inline in the field on a completion pill (Q-panels-15, -16: white ~15 %, r 6, text 203),
        // and a "Show Results" capsule 148 x 44 10 below the bar
        readonly property real calcBarH: 172.5
        readonly property real calcCardInset: 19
        readonly property real calcCardH: 60
        readonly property real calcCopy: 30
        readonly property color completionFill: Qt.rgba(1, 1, 1, 0.15)
        readonly property color completionText: Qt.rgba(203 / 255, 203 / 255, 203 / 255, 1)
        readonly property real completionRadius: 6
        // the top hit's inline completion (r17 spotlight-typed-*.png): the pill 26 tall from the end of the typed text
        // to 7 past the completion's
        readonly property real completionH: 26
        readonly property color completionRestText: Qt.rgba(178 / 255, 178 / 255, 178 / 255, 1)
        readonly property real completionPadRight: 7
        readonly property real showResultsW: 148
        readonly property real showResultsH: 44
        readonly property real barRadius: 43.5
        // the bar's centre at 26.65 % of the screen height: top 205 pt at 932 tall (spotlight-light-white-empty.png),
        // 251 at 1107 (Q-panels-17), 288 at 1243 (scaled/more-space-spotlight-close.mov); "top at 22.7 %" fitted only
        // the 1107 screen
        readonly property real barCentre: 0.2665
        readonly property int gap: 10
        readonly property real inputSize: 22             // query and placeholder: SF 22 regular
        readonly property real textX: 38                 // text start without a mode (r17: the query's ink from 38.5)
        readonly property real textDY: -1.25             // r17 spotlight-typed-*: "calc" ink 34.5 .. 51.5 of the bar's 87
        readonly property real barIcon: 32               // the top hit's icon at the right (r17: 32 x 33 ink)
        readonly property real modeTextX: 75             // text start after a mode glyph (cmd1/cmd3 shots)
        readonly property real modeGlyphX: 33            // mode glyph left (App Store "A" 26.5 x 23.5 at 32.5)
        readonly property real modeGlyph: 26
        readonly property real trailingRight: 39         // mic ink 14.5 x 21 ends 39 from the right
        readonly property real micSize: 22.6            // r17 spotlight-idle-*: the outline mic's ink 14.5 x 21, its right edge 39 from the bar's
        readonly property real micBoxPad: 4
        readonly property real ellipsisRight: 37.5       // "..." in Applications, 17.5 wide
        // the capsule's dark vertical gradient over the glass: over white 8 / 65 / 127, grey 6 / 36 / 64, black
        // 1 / 6 / 17 at top / middle / bottom. Over the plugin's spotlight glass (0.89 in + 26 here) that is a veil
        // of a .97 / .742 / .517 with k 0 / 0 / 4.4 (ours after: white 8 / 65 / 127 within 2).
        // R3.2 (spotlight-light-white-empty.png, light mode over a white window, the same 8 / 65 / 127): ours read
        // 7 levels light at 5-18 % of the height, 3 at mid; the veil (alpha x the same ratio per row) is now
        // .975 / .9325 / .754 / .579 / .517 at 0 / .14 / .5 / .87 / 1 (SPOTLIGHT-27.2.1.md "Round R3.2").
        // On the plugin its glass already carries black .205 (plugin Material.cpp SPOTLIGHT, the face clamped to 1 first, so
        // the key/fill rim is no longer clamped away over white: SPOTLIGHT-27.2.1.md "Judge #20"); the veils there are the
        // rest of these, 1 - (1 - v) / 0.795 (k x a kept), the same composite wherever the rim does not act. The QML
        // glass (no plugin, Reduce Transparency) keeps the stops as they are
        readonly property bool pluginVeil: theme.compositorGlass
        readonly property color barTopTint: pluginVeil ? Qt.rgba(0, 0, 0, 0.9686) : Qt.rgba(0, 0, 0, 0.975)
        readonly property color barUpperTint: pluginVeil ? Qt.rgba(0, 0, 0, 0.9151) : Qt.rgba(0, 0, 0, 0.9325)
        readonly property color barMidTint: pluginVeil ? Qt.rgba(0, 0, 0, 0.6906) : Qt.rgba(0, 0, 0, 0.754)
        readonly property color barLowerTint: pluginVeil ? Qt.rgba(0, 0, 0, 0.4704) : Qt.rgba(0, 0, 0, 0.579)
        readonly property color barBottomTint: pluginVeil ? Qt.rgba(0.0435, 0.0435, 0.0435, 0.3925) : Qt.rgba(0.033, 0.033, 0.033, 0.517)
        // the light rim under the top and over the bottom edge, drawn over the veil by shaders/spotrim.frag: (lift at the
        // edge 0..1, band pt, alpha at the edge), out = under x (1 - alpha s) + 255 lift s, s = (1 - depth / band) x the
        // lobe along the edge (*Fall below). Round 17 (MAC-ANSWERS-17.md R17.3 / R17.5, SPOTLIGHT-27.2.1.md "Round 17"), 2x
        // rows at the middle: the bar's top 57 / 34 / 13 over a 10 interior; the panel's top rows are .93 x the glass's
        // (the plugin's outer refraction, which sees the bar) + 53 / 31 / 9 on white, grey and black alike (results over
        // white 165 / 142 / 123, mode list 100 / 119 / 123); the bar's bottom rows 149 / 167 over white, 94 / 113 over
        // grey, of which the plugin's fill lobe under the veil draws 137 / 146. No plugin (QML glass): the same line.
        // Before round 17: flat 1 pt lines, white .13 (top) and .093 (bottom), 38 / 40 and 148 / 156 flat along x
        // *Fall: how fast the line fades along a straight edge, per unit of the ovalized normal's |n.x|: the list's
        // first row keeps .96 / .89 / .79 / .77 of its line at 50 / 100 / 150 / 200 pt from the middle, the bar's top
        // 57 55 49 43 at 0 / 50 / 100 / 150 pt
        readonly property real rimFall: 0.75
        readonly property real barRimFall: 0.96
        readonly property real barRimBottomFall: 0.6
        readonly property vector3d barRimTop: Qt.vector3d(61 / 255, 1.4, 0.08)
        readonly property vector3d barRimBottom: pluginVeil ? Qt.vector3d(25.5 / 255, 1.42, 0) : Qt.vector3d(60 / 255, 1.25, 0.14)
        readonly property vector3d panelRimTop: Qt.vector3d(67 / 255, 1.5, 0.09)
        // results / mode list panel: a black veil over the plugin glass, darker at the top. The mode list in dark over a
        // white image and over grey 127 (MAC-ANSWERS-4.md R4.4, spotlight-modelist-{white,grey}-dark.png): 121 / 68 at
        // 2 %, 134 / 74 at 11 %, 166 / 91 mid, 203 / 113 at 98 %. Our glass under it reads 256 over white and 141 over
        // grey (the same ratio as the Mac's, .555), so one veil fits both within .006: .535 / .4775 / .352 / .205 at
        // 0 / .11 / .5 / 1. Light is the same material: the light clips read 8-12 darker in the mid-tones than the stills
        // (h264; the bar 91 in spotlight-pill-hover-light.mov where spotlight-light-white-empty.png has 103), which
        // explains R3.2's light-only fit (.565 / .235, now dropped) and Q-panels-14's .45 / .38 (results, round 1).
        // On the plugin the bottom stop is in the glass (pluginVeil above): .415 / .343 / .185 / 0 here
        readonly property color panelTopVeil: pluginVeil ? Qt.rgba(0, 0, 0, 0.4151) : Qt.rgba(0, 0, 0, 0.535)
        readonly property color panelUpperVeil: pluginVeil ? Qt.rgba(0, 0, 0, 0.3428) : Qt.rgba(0, 0, 0, 0.4775)
        readonly property color panelMidVeil: pluginVeil ? Qt.rgba(0, 0, 0, 0.1849) : Qt.rgba(0, 0, 0, 0.352)
        readonly property color panelBottomVeil: pluginVeil ? Qt.rgba(0, 0, 0, 0) : Qt.rgba(0, 0, 0, 0.205)
        // completion token (a category in Applications): grey pill behind the text, 25 tall, r 8
        readonly property int tokenH: 25
        readonly property int tokenRadius: 8
        readonly property int tokenPad: 9
        readonly property color tokenFill: Qt.rgba(1, 1, 1, 0.2)
        // results and list panels: 520 wide, r 37; results at most 410 tall, Actions / Clipboard 490
        readonly property real panelRadius: 37
        readonly property real appsRadius: 38            // Apps panel: circle-equivalent 38 (continuous, extent 54.5)
        readonly property int resultsMax: 410
        readonly property int listPanelH: 490
        readonly property int pillInset: 12              // selection pill x 12 .. width - 13
        readonly property int pillRightInset: 13
        readonly property int pillRadius: 22
        readonly property int rowH: 62
        readonly property int rowIconSize: 36            // icon at x 25 from the panel edge (13 in the pill)
        readonly property int rowIconX: 13
        readonly property int rowTextX: 67               // title at x 79 from the panel edge (r17: ink from 79.5)
        readonly property real rowTitle: 17
        readonly property real rowSub: 15
        // the top hit's hint (ResultRow.hint) and the overlay scroll knob (r17 spotlight-typed-*.png: grey 124 on every
        // backdrop, 6 wide, 3 from the panel's right edge, capsule ends, from 40.5 under the panel's top)
        readonly property real hintSize: 11
        readonly property real hintRight: 12.75
        readonly property real hintGap: 7       // 8.5 between the inks: the text's last advance is wider than its ink
        readonly property real hintCapPad: 5.5
        readonly property real hintCapH: 18
        readonly property real hintCapRadius: 5.5
        readonly property real hintCapBaseline: 13
        readonly property real hintLift: 65 / 255
        readonly property real hintCapTextLift: 125 / 255
        readonly property color scrollKnob: Qt.rgba(124 / 255, 124 / 255, 124 / 255, 1)
        // the caret's halo (shaders/caretglow.frag)
        readonly property real caretGlowSigma: 3
        readonly property real caretGlowGain: 1.93
        // Files chips (lib/spotlight.js filesGrid): fill +12, text plus-lighter +125
        readonly property real fileChipLift: 12 / 255
        // list header (Actions "Suggestions", Files "Recents"): SF 12 semibold at x 20, centre y 30, a 1 pt
        // separator at y 43.5 (x 20 .. width - 20), rows from 44.5
        readonly property real headerX: 20
        readonly property real headerCY: 30
        readonly property real headerSepY: 43.5
        readonly property real listTop: 44.5
        readonly property real headerSize: 12
        // mode list: 520 x 214, rows pitch 48 from y 11, glyph centred at x 44, label x 81, shortcut 17 regular
        // right-aligned 36 from the edge
        readonly property int modeListH: 214
        readonly property int modeListPad: 11
        readonly property int modeRow: 48
        readonly property real modeListGlyphCX: 44
        readonly property real modeListGlyph: 22
        readonly property real modeListLabelX: 81
        readonly property real shortcutRight: 36
        readonly property real shortcutSize: 17
        readonly property real shortcutDigitW: 11.5
        // r17 spotlight-modelist-*: the glyphs' ink centres sit 1.25 pt under the row's, the App Store "A" is 22.5 x 20
        readonly property real modeListGlyphDY: 1
        readonly property real modeListAppsScale: 1.125
        // the panel under the bar grows out of a point 20 below its top and goes back into it (MAC-ANSWERS-3.md R3.2b,
        // spotlight-pill-hover-light.mov / -clear-light.mov, pts; fits in SPOTLIGHT-27.2.1.md "Round R3.2"):
        // - the mode list appears: x scale 0.16 -> 1 and y scale 0.03 -> 1 on Spring(0.33, bounce 0.21) (width / height
        //   RMS 0.2 % of the panel, overshoot 1.5 % at 0.27 s, settled at 0.44 s), opacity 0 -> 1 on Spring(0.25, 0)
        //   (RMS 0.018), blurred at the start (the window's contentBlurRadius 25, decoded for the open; not fitted);
        // - the results panel, emptied when the field is cleared, collapses: x scale 1 -> 0.2 and y scale 1 -> 0.045 on
        //   Spring(0.28, bounce 0.08) (RMS 0.3 % / 2.2 %), opacity 1 -> 0 linear in 0.185 s (RMS 0.022), the same blur
        readonly property real panelAnchorY: 20
        readonly property real listFromX: 0.16
        readonly property real listFromY: 0.03
        readonly property var listSpring: ({ response: 0.33, ratio: 0.79 })
        readonly property var listFadeSpring: ({ response: 0.25, ratio: 1 })
        readonly property real collapseToX: 0.2
        readonly property real collapseToY: 0.045
        readonly property var collapseSpring: ({ response: 0.28, ratio: 0.92 })
        readonly property int collapseFadeMs: 185
        readonly property real panelBlur: 25
        // the Apps panel from the bar (Cmd-1) and back (Escape), MAC-ANSWERS-17.md R17.1, apps-open-close-light.mov (60
        // fps; the grid area is blurred in the clip, so the extents are read off the panel's outline, +-10 pt):
        // - grows out of the list's anchor in 0.22 s: the fill's level .28 .47 .62 .75 .84 .89 .92 .98 1 per frame (a
        //   critically damped 0.21 s spring two frames in), the width overshoots 1.5 % 0.15 s after the first frame and
        //   is settled 0.33 s in (the list's spring at response 0.2); first frame about .62 wide and a fifth tall
        //   (from x .45, y .03);
        // - Escape: the grid and the chips go in one frame, the empty panel shrinks into the anchor: width .85 .75 .63
        //   .51 .40 of the panel per frame, gone on the sixth (the results panel's collapse spring, fade 0.11 s)
        // Judge #25: the clip re-read with one measure for both sides (scripts/motion-capture/apps-view.py --mac: the
        // fill's level in a band 50..64 pt under the panel's top, the width at half of that level, the bottom edge at
        // half level; per frame from 2.917 s): level .46 .62 .74 .76 .83 .88 .92 .97 1, width .45 .62 .76 .78 .84 .88
        // .93 1 of the settled one, bottom .48 .66 .72 .72 .86 .92 .97 1. The panel's top edge is in place from the
        // first frame: it grows about its top middle (appsAnchorY 0), not the list's anchor 20 under it, and starts a
        // third tall (from y .03 about the anchor ours read 108 206 392 478 pt tall, level .24 .49 .61 .72). This
        // replaces the values of the round 17 note above (x .45, y .03, response 0.2, fade two frames in).
        // Escape, from 5.217 s (the grid goes at 5.083 s): level .95 .89 .79 .70 .60 .44 .38 .24 .13 .07 .02, width
        // .90 .80 .67 .54 .43 .31, again about the top edge: a critically damped 0.23 s spring to x .1, y .05, fade
        // 0.215 s (the glass goes with it, so the level falls faster than the fade alone)
        readonly property real appsAnchorY: 0
        readonly property real appsFromX: 0.25
        readonly property real appsFromY: 0.30
        readonly property var appsSpring: ({ response: 0.26, ratio: 0.78 })
        readonly property real appsFirstAt: 0.04
        readonly property var appsFadeSpring: ({ response: 0.21, ratio: 1 })
        readonly property real appsFadeFirstAt: 0.05
        readonly property real appsCollapseToX: 0.1
        readonly property real appsCollapseToY: 0.05
        readonly property var appsCollapseSpring: ({ response: 0.23, ratio: 1 })
        readonly property int appsCollapseFadeMs: 215
        // colours over the panels (white over the dark glass; alpha fitted to the grey readings on a ~79 panel /
        // ~25 bar): secondary 153, placeholder and mic 165, shortcut 143, selection pill +11
        readonly property color text: "#FFFFFF"
        readonly property color secondary: Qt.rgba(1, 1, 1, 0.42)
        readonly property color placeholder: Qt.rgba(1, 1, 1, 0.6)
        // the mode list's "⌘1".."⌘4": plus-lighter, the panel + 67 whatever is under it (R4.4: over white 139 -> 207,
        // 157 -> 224, 174 -> 241; over grey 76 -> 143, 86 -> 152, 105 -> 171; Q-panels-22's 143 on 79 is +64), drawn
        // by shaders/plustext.frag (a white alpha .36 read +40 over white and +64 over grey)
        readonly property real shortcutLift: 67 / 255
        readonly property color pill: Qt.rgba(1, 1, 1, 0.0625)
        // Apps panel chips: +9 over the panel, text grey ~210 (SF 15 regular), 26 tall r 13, padding 10;
        // separator under the suggestions +35 (plus-lighter)
        readonly property real chipLift: 9 / 255
        readonly property color chipText: Qt.rgba(1, 1, 1, 0.73)
        readonly property real chipSize: 15
        readonly property int chipPad: 10
        readonly property real separatorLift: 35 / 255
        // keyboard focus in the Apps grid: accent ring 69 pt, about 3.5 thick; the first search hit: a grey 68 pt
        // plate (fill not measured)
        readonly property color plate: Qt.rgba(1, 1, 1, 0.12)
    }

    // ---------- app switcher ----------
    readonly property QtObject switcher: QtObject {
        // 27.2.1 Cmd-Tab (Q-dock-19..21, AX + pixels): one row of 128 pt icons, pitch 134 (gap 6), 24 pt padding on all
        // sides (8 apps: 1114 x 176 at the screen centre); with many apps the icons shrink (16 apps: 94, pitch 100) to keep
        // the panel 34 pt from the screen sides. Corner ~58 pt circle-equivalent (concentric: selection 34 + padding 24)
        readonly property int iconSize: 128
        readonly property int gap: 6
        readonly property int padding: 24
        readonly property int screenMargin: 34
        readonly property int radius: 58
        // selection: a 120 x 120 squircle on a 128 icon (circle-equivalent 34), flat. The Mac blends it plus-darker
        // -57 levels (light) / plus-lighter +65 (dark) with the glass under it (cmdtab-*.png: panel 41,134,220 -> tile
        // 0,78,161; 26,61,179 -> 90,124,240). With the plugin the tile is that fill (a cut in the panel's glass
        // region, `cut_fills`); `selection` is only the QML fallback without the plugin, a plain
        // alpha: black 0.30 takes 57 off a 190 backdrop (light glass), white 0.33 adds 65 to a 60 one (dark glass)
        readonly property real selectionSize: 120
        readonly property int selectionRadius: 34
        readonly property color selection: theme.dark ? Qt.rgba(1, 1, 1, 0.33) : Qt.rgba(0, 0, 0, 0.30)
        // the selected app's name: SF 13 semibold, its ink (cap top) 2.5 pt below the 128 frame, inside the bottom padding
        // (R17.2 cmdtab-7apps-*.png "TextEdit": ink rows 309..328 px below the panel's top, 104 px wide; the text
        // box's top is then at the frame's bottom edge. Bold at +2.5 sat 2.5 pt low and 1.04x as wide)
        readonly property real labelTop: 0
        // its colour: labelColor in light (ink 17..20 over 135); in dark nearly opaque white, no shadow (ink 244..246
        // over 50, the rows under the text unchanged; labelColor's white .85 read 233)
        readonly property color labelColor: theme.dark ? Qt.rgba(1, 1, 1, 0.95) : Tokens.label
        readonly property int minIconSize: 32            // floor when very many apps are open (no Mac data below 94)
        // the panel is on screen 180 ms after Tab, complete in one frame; releasing Cmd before that switches without it
        // (R17.2 cmdtab-step-cancel-dark.mov: Tab 1.137 s, panel 1.317 s; Q-dock-22 had about 0.19 s). Counted from
        // the key (Panels.switcherAt), not from the window's load. `showLag` is what follows the timer here: the
        // frame's render and the compositor's next refresh (scripts/motion-capture/cmd-tab.py reads the sum)
        readonly property int showDelay: 180
        readonly property int showLag: 60
    }

    // ---------- app icons ----------
    readonly property QtObject appIcon: QtObject {
        readonly property real body: 0.8047             // icon body: 824 of 1024 (legacy inset 100/1024, SPEC.md App icons)
        readonly property real inner: 0.70              // non-squircle art body inside its tile
    }

    // ---------- alert dialog ----------
    readonly property QtObject alert: QtObject {
        // size and layout: HyprK panels.js alertLayout (shared with the apps' AlertPanel)
        readonly property int radius: 26                 // SPEC.md 7: alert window corner radius 26
        // motion decoded from AppKit 27.2.1 (re/27.2.1/MOTION-AUDIT.md "Alert, Round R3.1"; curves in HyprK panels.js):
        // show = NSWindowTransformAnimationPopIn, 0.4 s of linear progress v, alpha = v, scale amount 0.2 (peak 1.2
        // at 0.24 s; the R3.1 clips over grey fit at rms .0019 / .0009). Dismiss with Cancel / Esc =
        // ScaleDownAndOut: a spring (perceptual 0.1812 s, bounce 0, initial velocity 13) run for 0.25 s, alpha 1 - p,
        // scale 1 -> 0.98; any other button: no animation (NSAlert sets order-out type 2). Was in-quad / out-quad to
        // 1.17 at alpha 1 and a 154 ms out-cubic fade for every button
        readonly property int popIn: 400
        readonly property real popAmount: 0.2
        readonly property int cancelOut: 250
        readonly property real cancelDuration: 0.1812
        readonly property real cancelVelocity: 13
        readonly property real cancelScale: 0.98
        // ScaleDownAndOut's third value, 5 p (block 0x18af87704): the whole window (glass, content, shadow) blurred by 5 p pt
        // while it fades (the dark R3.1 clip's dismiss frame is blurred; MOTION-AUDIT.md "dismiss blur / shadow")
        readonly property real cancelBlur: 5
        // where on the spring the first dismiss frame lands, in frames after the press (FrameAnim draws frame k at k + 1):
        // the dark R3.1 clip's one dismiss frame is alpha .83-.86 (body .840, text .828, edge .856) blurred 0.78-0.80 pt,
        // so p .15-.16 = 11 ms on the decoded spring = 2/3 of a 60 Hz frame. At k + 1 (16.7 ms, p .24) ours showed alpha
        // .74 blurred 1.15-1.25 pt (agent-fx / JUDGE-95-20)
        readonly property real cancelPhase: 2 / 3
        // the plain button: two layers a .047 + a .03 (Q-settings-15: white in dark, black in light), together a .0756:
        // 71 on the 55 dark body as measured (Q-panels-33), 236 on white (#ECECEC). Pressed: one more a .098 layer
        // (dark 71 -> 89 measured; black in light, Q-settings-15)
        readonly property color buttonBg: theme.dark ? Qt.rgba(1, 1, 1, 0.0756) : Qt.rgba(0, 0, 0, 0.0756)
        readonly property color buttonPressed: theme.dark ? Qt.rgba(1, 1, 1, 0.098) : Qt.rgba(0, 0, 0, 0.098)
    }

    // ---------- Emoji & Symbols picker (modules/EmojiPicker.qml) ----------
    // Measured on reference/screens/27.2.1/panels/emoji-picker-dark.png (2 px per pt, body top-left at 72, 89 px).
    // Points from the body's top-left. No light shot: the light colours are guessed.
    readonly property QtObject emoji: QtObject {
        readonly property real width: 320               // body 72..711 px
        readonly property real height: 445              // body 89..978 px
        readonly property real radius: 20               // corner profile fits r 40 px
        readonly property real arrowHeight: 10.5        // tip at 68 px, body top 89
        readonly property real arrowWidth: 26           // base 366..418 px, tip on the body's centre
        readonly property real margin: 8                // from the screen edges (the NSPopover's, HyprK panels.js)
        readonly property color fill: theme.dark ? "#1F1F1F" : "#F6F6F6"   // 31 31 31 measured; light guessed
        readonly property color rimOuter: theme.dark ? Qt.rgba(0, 0, 0, 0.68) : Qt.rgba(0, 0, 0, 0.18)   // 1 px a 173
        readonly property color rimInner: theme.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.6)    // 56 on 31
        // search field: inside the 3 pt focus ring 86..697 x 105..172 px; text at 150 px (28.5 in), 13 pt
        readonly property real searchX: 10.5
        readonly property real searchY: 10.75
        readonly property real searchW: 299
        readonly property real searchH: 27.5
        readonly property real searchTextX: 28.5
        readonly property real searchGlyphX: 15         // magnifier ink 111..135 px, centre 15 pt in the field
        // grid: 6 columns, emoji centres 137.5, 239, 340.5, 442, 542.5, 644 px (pitch 50.67 = 304 / 6), rows 88 px
        readonly property int cols: 6
        readonly property real side: 8
        readonly property real cellH: 44
        readonly property real gridTop: 47.25           // first row's top: its centre at 227.5 px = 69.25 pt
        readonly property real glyphSize: 24.8          // yellow ink 54 px wide on the Mac shot in all 18 faces of rows 1-3;
                                                        // at 31.6 ours measured 52 px (judge #13: 51-52 against 54), so 32.8
                                                        // with the old font; the emoji font now draws 1.3 x the pixel size
                                                        // (40 px strike over a 31 px line, was 41): 32.8 x 31 / 41 = 24.8 is
                                                        // the same 0.8 scale of the same strike (reference/re/27.2.1/EMOJI-TEXT.md)
        readonly property real glyphOffsetY: 1          // centred on its line box the face sat 1 pt above the Mac's
        readonly property real glyphOffsetX: 1.25       // the font's tracking (EMOJI-TEXT.md) widens the advance unevenly:
                                                        // centred on it the faces sat 2.5 px left of the cells (1023.5 / 1026)
        readonly property real highlightW: 56           // 83..194 px
        readonly property real highlightH: 41           // 187..268 px
        readonly property real highlightRadius: 20
        readonly property color highlight: theme.dark ? Qt.rgba(1, 1, 1, 0.28) : Qt.rgba(0, 0, 0, 0.10)   // 86..102 on 31
        // category bar: hairline at 889 px, 45 tall, content scrolls under it (blurred emoji show through)
        readonly property real barTop: 400
        readonly property real barCenterY: 22.25        // icons 921..946 px
        readonly property real tabX: 23.75              // first tab's centre (119.5 px)
        readonly property real tabPitch: 31.75          // 63.5 px
        readonly property real chevronX: 303            // 678 px
        readonly property real tabCircle: 24            // the selected tab's disc 159..207 px
        readonly property real tabGlyph: 16             // glyph box; ink 13 pt tall (921..946 px)
        // SF Symbols at 13 pt regular (alpha rms on the shot: clock .068, the selected face .018, apple .076, car .047,
        // lightbulb .048, heart .081, flag .070; 12.5 and 13.5 pt fit worse); the ">" chevron semibold (.071)
        readonly property real tabPointSize: 13
        readonly property string chevronWeight: "semibold"
        readonly property color tabSelected: theme.dark ? Qt.rgba(1, 1, 1, 0.33) : Qt.rgba(0, 0, 0, 0.12)   // 113 on 42
        readonly property color tabColor: theme.dark ? "#FFFFFF" : Qt.rgba(0, 0, 0, 0.85)               // 255 measured
        readonly property color barHairline: theme.dark ? Qt.rgba(1, 1, 1, 0.07) : Qt.rgba(0, 0, 0, 0.08)   // 48 on 32
        readonly property color barFill: theme.dark ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(1, 1, 1, 0.5)      // 40 where nothing is behind
        readonly property real underOpacity: 0.45       // blurred emoji under the bar / field (eyeballed on the shot)
        readonly property int recents: 18               // Frequently Used: 3 rows (guessed)
    }

    // ---------- mission control ----------
    readonly property QtObject mission: QtObject {
        readonly property int spacesTop: 16
        readonly property int spaceThumbWidth: 150       // TODO verify
        readonly property int spaceRadius: 8
        readonly property int margin: 60                 // around the window grid, TODO verify
        readonly property int gap: 40                    // between window thumbnails, TODO verify
        readonly property int thumbRadius: 10            // TODO verify
        readonly property real maxScale: 0.8             // windows only shrink in Mission Control, TODO verify
        readonly property int spaceSpacing: 18           // between Space thumbnails
        readonly property int spaceLabelGap: 6
        readonly property int placeholderIcon: 64
        readonly property int hoverBorder: 3
        readonly property real hoverScale: 1.03
        readonly property color text: "#FFFFFF"
        readonly property real labelSize: 12
        // window title on hover, centred on the window (Q-dock-29): capsule 30 pt, padding 14.5, black on grey 106
        readonly property real titleHeight: 30
        readonly property real titlePadding: 14.5
        readonly property color titleFill: Qt.rgba(106 / 255, 106 / 255, 106 / 255, 1)   // read over dark content: its opacity is not known
        readonly property color titleText: "#000000"
    }

    // ---------- animation ----------
    readonly property QtObject anim: QtObject {
        // SPEC 9.9.4: SwiftUI Animation.default = spring(response 0.5, dampingFraction 1.0),
        // critically damped: x(t) = 1 - (1 + wt) e^-wt, w = 2pi / 0.5. It starts with zero velocity
        // and is at 99.5 % after 0.6 s. `spring` is a cubic bezier fitted to it over `normal`
        // (max error 1.5 %; the old 350 ms OutCubic jumped 14 % in the first frame, the spring 2 %).
        // Use with easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring.
        // SPEC 9.9.5: window ScaleUpAndIn 0.5 s, ScaleDownAndOut 0.25 s (Solarium).
        readonly property int fast: 120                  // hover / press
        readonly property int normal: theme.ms(600)                // panels open (spring 0.5 critically damped)
        readonly property var spring: [0.25, 0.248, 0.1, 1.0, 1, 1]
        readonly property int close: theme.ms(250)                 // panels close (ScaleDownAndOut)
        readonly property int easing: Easing.OutCubic

        // Liquid Glass motion (materialize, press, Reduce motion crossfade): Tokens.motion
        // a menu opens at once and fades out on CoreAnimation's "default" curve (0.25, 0.1, 0.25, 1) over 236 ms: the
        // probe's 120 Hz window alpha (re/27.2.1/live/menu-motion-{dark,light}.json: .8605 .7115 .5532 .4154 .305
        // .2188 .1521 .1013 .0631 .0355 .0167 .0053 .0004 0) fits it at rms .0004 (out-quad 185 ms .012; on screen
        // .0155, three frames short); the Q-menubar-24 row series fits it too (rms .003). MOTION-AUDIT.md
        readonly property int menuFadeOut: theme.ms(236)
        readonly property var menuFadeCurve: [0.25, 0.1, 0.25, 1, 1, 1]
        // a growing or shrinking glass (Spotlight results): SwiftUI .snappy, bounce 0.15 (by eye)
        readonly property real resizeResponse: 0.5
        readonly property real resizeDamping: 0.85
        // Dock autohide (Q-dock-16, 60 fps): a pure slide on the Dock's cosine ease in-out (DockFloatAnimatedProperty,
        // REA 27.2.1 side notes), fitted to the per-frame top edge: 210 ms (rms 0.016 show, 0.022 hide), starting
        // 200 ms after the pointer reaches the bottom edge and 30 ms after it leaves the Dock
        readonly property int dockSlide: 210
        // full screen enter/exit: the Dock leaves and returns on the Space slide, 0.5 - 0.5 cos(pi t / 0.5 s) (Dock
        // FUN_1000c60f8, MOTION-PLUGIN.md "Full screen REA"); the menu bar comes back over the same 0.5 s from the
        // start of the exit (AppKit startMenuBarAnimation:) and leaves on enter over NSMenuBarPresentationInstance's
        // default 0.15 s (inferred, not traced)
        readonly property int fullscreenSlide: 500
        readonly property int menuBarFullscreenIn: 500
        readonly property int menuBarFullscreenOut: 150
        // full screen on a notched output (the window below the black 34 pt strip): the pointer at the top edge shows
        // the titles and status items in place on the black, roughly linear over 0.15 s; leaving the bar takes them
        // away over 0.17 s; no dwell either way (Q-menubar-33, 60 fps clip)
        readonly property int menuBarPeekIn: 150
        readonly property int menuBarPeekOut: 170
        readonly property int dockRevealDelay: 200
        readonly property int dockHideDelay: 30
        // a click on a slider track springs the shown value to the click point, then drags follow 1:1
        readonly property real sliderJumpResponse: 0.3   // CC's knobless slider; Settings' NSSlider uses Tokens.motion.sliderJumpResponse 0.25
    }
}
