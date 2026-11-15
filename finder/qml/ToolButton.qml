import QtQuick

// Icon button inside a Capsule. Hover and press show the same flat inner capsule, 28 tall and 30 wide (35.5 on
// view segments, the whole circle on Search), no animation; a disabled button gets neither (Q-finder-10).
// `pressLook` (Search, R11.5 finder-search-button clips): the held button shows `pressColor` and `pressIconColor` from
// the press frame on, and `held` (1 while down, then back to 0 over `releaseMs`) fades them out and drives the
// capsule's growth (Toolbar.qml).
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
    property real hitRight: 0                // extra hover / press width to the right, pt
    readonly property bool lit: enabled && (hover.hovered || tap.pressed)
    // in a Capsule whose HyprK light draws the hover disc (dark), the light draws hover and press; the pill is for the
    // other cases (light appearance, inactive window, capsules without the light)
    readonly property Item capsule: { let p = parent; while (p && p.lightHovers === undefined) p = p.parent; return p; }
    readonly property bool down: tap.pressed
    property bool pressLook: false
    property color pressColor: hoverColor
    property color pressIconColor: iconColor
    // the held disc's own edge (Search, light: the white disc on the 253 strip is told by its rim alone)
    property color pressRim: "transparent"
    property color pressRimSide: "transparent"
    property int releaseMs: 0
    property real held: 0
    onDownChanged: {
        release.stop();
        if (down) held = pressLook ? 1 : 0;
        else if (pressLook && releaseMs > 0 && held > 0) release.start();
        else held = 0;
    }
    NumberAnimation { id: release; target: root; property: "held"; to: 0; duration: root.releaseMs; easing.type: Easing.OutCubic }
    signal clicked()

    implicitWidth: Theme.toolbar.buttonWidth
    implicitHeight: Theme.toolbar.capsuleHeight

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(root.hoverWidth, root.width)
        height: root.hoverHeight
        radius: height / 2
        color: root.hoverColor
        visible: root.lit && !(root.capsule && root.capsule.lightHovers) && !(root.pressLook && root.down)
    }
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(root.hoverWidth, root.width)
        height: root.hoverHeight
        radius: height / 2
        color: root.pressColor
        opacity: root.held
        visible: root.pressLook && root.held > 0
        border.width: root.pressRim.a > 0 ? 0.5 : 0
        border.color: root.pressRim
        Item {    // the rim's sides, darker: the same edge clipped to the middle third (as Capsule's flat edge)
            visible: root.pressRimSide.a > 0
            y: Math.round(parent.height / 3)
            width: parent.width
            height: parent.height - 2 * y
            clip: true
            Rectangle {
                y: -parent.y
                width: parent.width
                height: parent.parent.height
                radius: height / 2
                color: "transparent"
                border.width: 0.5
                border.color: root.pressRimSide
            }
        }
    }
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
        color: !root.enabled ? Theme.color.toolbarIconDisabled : root.pressLook && root.down ? root.pressIconColor : root.iconColor
    }
    // hover and press area: the button, plus `hitRight` pt to its right (a pull-down's chevron beside the glyph: the
    // Mac's Group and view pop-up items open their menu from anywhere on the item, the chevron included)
    Item {
        width: root.width + root.hitRight
        height: root.height
        HoverHandler { id: hover; enabled: root.enabled }
        TapHandler {
            id: tap
            enabled: root.enabled
            // no long press: a button held for any time acts on the release, as AppKit's (Qt's default dropped the
            // tap after the press-and-hold interval: Search held 0.5 s and released did nothing, live)
            longPressThreshold: 0
            onTapped: root.clicked()
        }
    }
}
