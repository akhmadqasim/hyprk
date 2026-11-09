pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Display brightness through brightnessctl (backlight class). Desktops with
// external monitors have no backlight: `available` stays false and the
// Display slider is shown disabled, like macOS on a non-Apple display.
Singleton {
    id: root

    property bool available: false
    property real value: 1.0

    function set(v) {
        if (!available) return;
        value = Math.max(0.01, Math.min(1, v));
        setter.command = ["brightnessctl", "-q", "-c", "backlight", "set", Math.round(value * 100) + "%"];
        setter.running = true;
    }

    Process {
        running: true
        command: ["brightnessctl", "-m", "-c", "backlight", "info"]
        stdout: StdioCollector {
            onStreamFinished: {
                // name,class,current,percent%,max
                const f = text.trim().split(",");
                if (f.length >= 5 && parseInt(f[4]) > 0) {
                    root.value = parseInt(f[2]) / parseInt(f[4]);
                    root.available = true;
                }
            }
        }
    }
    Process { id: setter }
}
