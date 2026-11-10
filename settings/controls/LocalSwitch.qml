import QtQuick
import "../HyprK"

// A Switch that keeps its own state: for settings with no backend yet (the shared Switch is
// controlled, so these placeholders hold what the user picked until a backend exists).
Switch {
    onToggled: on => checked = on
}
