import QtQuick

// Icon button inside a Capsule. Hover and press show the same flat inner capsule, 28 tall and 30 wide (35.5 on
// view segments, the whole circle on Search), no animation; a disabled button gets neither (Q-finder-10).
Item {
    id: root

    property string icon
    property real iconSize: Theme.toolbar.iconSize
    property string iconWeight: "regular"
    property string iconScale: ""
    property real iconPointSize: 0           // 0 = the default for the size
    property real hoverWidth: Theme.toolbar.hoverWidth
    property real hoverHeight: Theme.toolbar.hoverHeight
    property color hoverColor: Theme.color.toolbarHover
    property color iconColor: Theme.color.toolbarIcon
    property real iconDx: 0                  // glyph nudge from the centre, pt
    property real iconDy: 0
    readonly property bool lit: enabled && (hover.hovered || tap.pressed)
    // in a Capsule whose HyprK light draws the hover disc (dark), the light draws hover and press; the pill is for the
    // other cases (light appearance, inactive window, capsules without the light)
    readonly property Item capsule: { let p = parent; while (p && p.lightHovers === undefined) p = p.parent; return p; }
    signal clicked()

    implicitWidth: Theme.toolbar.buttonWidth
    implicitHeight: Theme.toolbar.capsuleHeight

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(root.hoverWidth, root.width)
        height: root.hoverHeight
        radius: height / 2
        color: root.hoverColor
        visible: root.lit && !(root.capsule && root.capsule.lightHovers)
    }
    HoverHandler { id: hover; enabled: root.enabled }
    Symbol {
        id: glyph
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.iconDx
        anchors.verticalCenterOffset: root.iconDy
        name: root.icon
        size: root.iconSize
        weight: root.iconWeight
        scale: root.iconScale
        pointSize: root.iconPointSize > 0 ? root.iconPointSize : glyph.defaultPointSize
        color: root.enabled ? root.iconColor : Theme.color.toolbarIconDisabled
    }
    TapHandler {
        id: tap
        enabled: root.enabled
        onTapped: root.clicked()
    }
}
