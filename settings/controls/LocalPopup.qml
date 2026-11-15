import QtQuick
import "../HyprK"

// A Popup that keeps its own choice: for settings with no backend yet (the shared Popup is
// controlled, so these placeholders hold what the user picked until a backend exists).
Popup {
    // items that act instead of being chosen (the Mac's "Customize…", "Choose Color…"): no panel behind them here, so
    // they leave the choice as it was
    property var actions: []
    onActivated: i => { if (actions.indexOf(i) === -1) currentIndex = i; }
}
