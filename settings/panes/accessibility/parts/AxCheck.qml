import QtQuick
import "../../../HyprK"

// A Checkbox that keeps its own state (the shared one is controlled).
Checkbox {
    onToggled: on => checked = on
}
