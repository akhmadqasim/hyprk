pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// System sounds. All playback goes through scripts/sound.sh, which reads
// state/sound.json (alertSound, alertVolume, uiSounds, volumeFeedback) so the
// shell, Hyprland binds and the Settings app share one behavior. See SOUNDS.md.
Singleton {
    id: root

    readonly property string script: Quickshell.shellDir + "/scripts/sound.sh"

    function play(event) {
        Quickshell.execDetached([script, event]);
    }

    // volume pop once the slider settles, not on every drag step
    function volumeChanged() { volumeDebounce.restart(); }
    Timer { id: volumeDebounce; interval: 180; onTriggered: root.play("volume") }

    IpcHandler {
        target: "sounds"
        function play(event: string): void { root.play(event); }
    }
}
