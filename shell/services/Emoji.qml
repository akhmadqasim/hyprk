pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs
import "../lib/emoji.js" as EM
import "../lib/emojidata.js" as Data

// Emoji & Symbols picker (modules/EmojiPicker.qml): Frequently Used and putting the picked emoji into the focused app.
//
// Frequently Used: $HYPRK_STATE/emoji.json {"used": {"😀": [count, lastUsedMs]}}, the most used first.
// Inserting: a Wayland client cannot type into another app without a virtual-keyboard tool (no wtype here), so the
// emoji is pasted: scripts/emoji-insert.sh saves the clipboard (text only, never a password manager's secret copy)
// and copies the emoji, the app gets its paste key through Hyprland (send_shortcut to the active window: Ctrl+V,
// Ctrl+Shift+V in a terminal, lib/emoji.js pasteMods), and the saved text goes back on the clipboard after
// restoreDelay. An app that does not paste on that key gets nothing; the emoji is then still on the clipboard.
Singleton {
    id: root

    readonly property var sections: Data.sections()
    readonly property var known: EM.names(sections)
    property var used: ({})
    readonly property var frequent: EM.frequent(used, Theme.emoji.recents, known)

    FileView {
        id: file
        path: Prefs.dir + "emoji.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.used = EM.parseState(text())
        onLoadFailed: root.used = ({})
    }
    function recordUse(e) {
        used = EM.recordUse(used, e, Date.now(), 60);
        file.setText(JSON.stringify({ used: used }) + "\n");
    }

    // the paste goes out once the picker's layer has given the keyboard back (it unmaps on close)
    readonly property int pasteDelay: 90       // guessed: a few frames for the layer to unmap
    readonly property int restoreDelay: 700    // guessed: apps read the clipboard at once on paste
    property string pending: ""
    property string pasteMods: "CTRL"
    readonly property string script: Quickshell.shellDir + "/scripts/emoji-insert.sh"

    function insert(e) {
        if (!e) return;
        recordUse(e);
        pending = e;
        pasteMods = EM.pasteMods(Apps.appIdOf(Apps.activeToplevel));
        restoreTimer.stop();
        copyProc.command = ["bash", script, "copy", e];
        copyProc.running = true;
    }
    Process {
        id: copyProc
        // exit 2: no wl-clipboard; nothing to paste
        onExited: code => { if (code === 0) pasteTimer.restart(); else root.pending = ""; }
    }
    Timer {
        id: pasteTimer
        interval: root.pasteDelay
        onTriggered: {
            if (!Apps.activeToplevel) { root.pending = ""; return; }   // the desktop has the keyboard: leave it copied
            Hyprland.dispatch(`hl.dsp.send_shortcut({ mods = "${root.pasteMods}", key = "v", window = "activewindow" })`);
            restoreTimer.restart();
        }
    }
    Timer {
        id: restoreTimer
        interval: root.restoreDelay
        onTriggered: {
            root.pending = "";
            restoreProc.command = ["bash", root.script, "restore"];
            restoreProc.running = true;
        }
    }
    Process { id: restoreProc }

    // `qs -p shell ipc call emoji insert "😀"`: the picker's insertion without the picker (scripted checks)
    IpcHandler {
        target: "emoji"
        function insert(text: string): void { root.insert(text); }
        function frequent(): string { return root.frequent.map(i => i[0]).join(""); }
    }
}
