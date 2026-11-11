import QtQuick
import HyprK

// Finder tab bar, 27.2.1 (MAC-ANSWERS.md Q-finder-32, live/finder/crops/tabbar-*.png, 2x): shown with two or more
// tabs, a 28 pt capsule track under the toolbar from 7.5 pt right of the sidebar, light 232 with a 220 rim, dark
// (56,56,63) / (72,72,78); the tabs share its width. The selected tab is an inner capsule 2 pt in (24 tall, r 12),
// light 253 text 75, dark (61,61,69) text 235; the others have no fill, text light 181 / dark 132. Hovering an
// unselected tab darkens it (light 220, dark (66,66,73)) and shows a close x 18x18 at its x + 4. Titles 11 pt,
// centred. Right of the track, 4 pt away, a 28 pt round platter with a plus (new tab); in a 920 pt window
// the track spans 167..879.5 (8 pt right of the sidebar), the plus ends 8.5 pt from the window edge.
// Inactive window (light crop): selected tab 240, texts 177 / 171, plus 164 on 240; dark inactive was not captured.
Item {
    id: root

    property var titles: []         // one per tab
    property int current: 0
    signal selected(int index)
    signal closeRequested(int index)
    signal newTabRequested()

    implicitHeight: 28

    readonly property bool lightInactive: !Theme.dark && !Theme.active

    Rectangle {
        id: track
        width: root.width - 4 - plus.width
        height: root.height
        radius: height / 2
        color: Theme.dark ? "#38383F" : "#E8E8E8"
        border.width: 1
        border.color: Theme.dark ? "#48484E" : "#DCDCDC"

        Row {
            anchors.fill: parent
            anchors.margins: 2
            Repeater {
                model: root.titles
                Item {
                    id: tab
                    required property int index
                    required property string modelData
                    readonly property bool sel: index === root.current
                    width: (track.width - 4) / Math.max(1, root.titles.length)
                    height: parent.height

                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2
                        visible: tab.sel || hover.hovered
                        color: tab.sel ? (Theme.dark ? "#3D3D45" : root.lightInactive ? "#F0F0F0" : "#FDFDFD")
                                       : (Theme.dark ? "#424249" : "#DCDCDC")
                    }
                    TextLabel {
                        anchors.centerIn: parent
                        width: Math.min(implicitWidth, parent.width - 48)
                        elide: Text.ElideMiddle
                        text: tab.modelData
                        size: 11
                        color: Theme.dark ? (tab.sel ? "#EBEBEC" : "#84848B")
                             : root.lightInactive ? (tab.sel ? "#B1B1B1" : "#ABABAB")
                             : (tab.sel ? "#4B4B4B" : "#B5B5B5")
                    }
                    HoverHandler { id: hover }
                    TapHandler { onTapped: root.selected(tab.index) }
                    Item {   // close: x 18x18 at the tab's x + 4, only on a hovered unselected tab
                        x: 4
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18; height: 18
                        visible: hover.hovered && !tab.sel
                        Symbol {
                            anchors.centerIn: parent
                            size: 11   // glyph 7.5 pt like the crop's
                            name: parent.visible ? "xmark" : ""
                            color: Theme.dark ? "#A9A9AC" : "#6E6E6E"
                        }
                        TapHandler { onTapped: root.closeRequested(tab.index) }
                    }
                }
            }
        }
    }

    Item {
        id: plus
        anchors.right: parent.right
        width: 28; height: 28
        ToolbarPlatter { anchors.fill: parent }
        Rectangle {   // inactive window: the platter darkens like the toolbar capsules (Q-finder-29)
            anchors.fill: parent
            radius: height / 2
            visible: !Theme.active
            color: Theme.color.capsuleInactive
        }
        Symbol {
            anchors.centerIn: parent
            size: 14   // glyph 10 pt like the crop's
            name: "plus"
            color: Theme.color.toolbarIcon
        }
        TapHandler { onTapped: root.newTabRequested() }
    }
}
