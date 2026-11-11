pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// System sounds. All playback goes through scripts/sound.sh, which reads
// state/sound.json (alertSound, alertVolume, uiSounds, volumeFeedback) so the
// shell, Hyprland binds and the Settings app share one behavior. See SOUNDS.md.
Singleton {
    id: root

    readonly property string script: Quickshell.shellDir + "/scripts/sound.sh"

    // event names: scripts/sound.sh; arg: a notification's sound name or file
    function play(event, arg) {
        Quickshell.execDetached(arg ? [script, event, arg] : [script, event]);
    }

    // the volume pop when a Sound slider is let go, not while it is dragged; Shift held inverts "Play feedback when
    // volume is changed" (ControlCenter 27.2.1 playAudioVolumeFeedback(onSliderEditingChanged:) 0x1000e3814: only
    // when editing ends, then beepFeedback != Shift). The volume keys: scripts/volume-key.sh.
    function volumeReleased(modifiers) { play("volume", (modifiers & Qt.ShiftModifier) ? "negate" : ""); }

    // power connected: PowerChime's connect_power chime when a laptop goes from battery to the charger
    // (MAC-ANSWERS "Sounds": PowerChime chimeOnAttach). Desktops have no battery device: nothing changes.
    readonly property bool onPower: UPower.displayDevice.isLaptopBattery && UPower.displayDevice.state !== UPowerDeviceState.Discharging
    property bool wasOnPower: onPower
    onOnPowerChanged: {
        if (onPower && !wasOnPower && UPower.displayDevice.ready) play("power");
        wasOnPower = onPower;
    }

    IpcHandler {
        target: "sounds"
        function play(event: string): void { root.play(event); }
    }
}
