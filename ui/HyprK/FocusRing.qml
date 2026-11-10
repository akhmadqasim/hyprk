import QtQuick

// Keyboard focus ring (MAC-ANSWERS.md Q-settings-24): 3 pt wide, directly outside the control (gap 0), following
// its shape (radius + 3), keyboardFocusIndicatorColor a.5 (Accent.focusRing). It appears without animation.
// Put it inside the shape it rings (anchors follow the parent); set `radius` when the parent is not a Rectangle.
Rectangle {
    property real shapeRadius: parent && parent.radius !== undefined ? parent.radius : 0
    anchors.fill: parent
    anchors.margins: -Tokens.control.focusRingWidth
    radius: shapeRadius + Tokens.control.focusRingWidth
    color: "transparent"
    border.width: Tokens.control.focusRingWidth
    border.color: Accent.focusRing
}
