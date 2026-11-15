import QtQuick
import "../../../HyprK"

// A Slider that keeps its own value (the shared one is controlled).
Slider {
    onMoved: v => value = v
    onCommitted: v => value = v
}
