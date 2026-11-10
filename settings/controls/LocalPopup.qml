import QtQuick
import "../HyprK"

// A Popup that keeps its own choice: for settings with no backend yet (the shared Popup is
// controlled, so these placeholders hold what the user picked until a backend exists).
Popup {
    onActivated: i => currentIndex = i
}
