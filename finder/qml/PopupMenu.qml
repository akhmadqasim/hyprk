import QtQuick
import HyprK
import QtQuick.Controls.Basic

// Finder menu (context menus, Group and Action pull-downs): rows 24, padding 5, r 12, the accent highlight inset
// 5 with r 7 and white text, moving in one frame; text at x 16, or 28 when an item has a checkmark; closes with a
// 0.2 s fade (MAC-ANSWERS.md Q-finder-24, Q-menubar-12/22/24). Drawn flat with the shared menu fill.
// items: [{ text, shortcut, checked, enabled, action }], { separator: true }, or
// { tagRow: true, action(tagName) } for Finder's row of tag color dots.
Popup {
    id: root

    property var items: []

    padding: 5
    width: Math.max(200, list.implicitWidth + 2 * padding)
    implicitHeight: list.implicitHeight + 2 * padding
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    readonly property bool hasChecks: items.some(i => i.checked !== undefined)
    enter: Transition { NumberAnimation { property: "opacity"; to: 1; duration: 0 } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.OutQuad } }

    background: Rectangle {
        radius: Tokens.control.menuRadius
        color: Tokens.control.menuFill
        border.width: 1
        border.color: Tokens.control.menuStroke
    }

    contentItem: Column {
        id: list
        Repeater {
            model: root.items
            Item {
                id: it
                required property var modelData
                readonly property bool sep: !!modelData.separator
                readonly property bool tagRow: !!modelData.tagRow
                readonly property bool plain: !sep && !tagRow
                readonly property bool on: modelData.enabled !== false
                width: root.width - 2 * root.padding
                height: sep ? 11 : tagRow ? 30 : 24
                implicitWidth: !plain ? 0 : label.implicitWidth + shortcutText.implicitWidth + 64

                Rectangle {
                    visible: it.sep
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: 1
                    color: Theme.color.separator
                }
                Rectangle {
                    visible: it.plain && it.on && hover.hovered
                    anchors.fill: parent
                    radius: 7
                    color: Theme.color.accent
                }
                Text {
                    visible: it.plain && !!it.modelData.checked
                    x: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "✓"
                    color: hover.hovered ? "white" : Theme.color.label
                    font: Typography.body
                }
                Text {
                    id: label
                    visible: it.plain
                    x: root.hasChecks ? 23 : 11
                    anchors.verticalCenter: parent.verticalCenter
                    text: it.modelData.text || ""
                    color: !it.on ? Theme.color.tertiaryLabel : hover.hovered ? "white" : Theme.color.label
                    font: Typography.body
                }
                Text {
                    id: shortcutText
                    visible: it.plain
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: it.modelData.shortcut || ""
                    color: hover.hovered && it.on ? "white" : Theme.color.secondaryLabel
                    font: Typography.body
                }
                HoverHandler { id: hover; enabled: it.plain }
                Row {
                    visible: it.tagRow
                    x: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 9
                    Repeater {
                        model: it.tagRow ? Theme.color.tags : []
                        Rectangle {
                            required property var modelData
                            width: 15; height: 15; radius: 7.5
                            color: modelData.color
                            scale: dotHover.hovered ? 1.2 : 1
                            HoverHandler { id: dotHover }
                            TapHandler {
                                onTapped: {
                                    root.close();
                                    it.modelData.action(parent.modelData.name);
                                }
                            }
                        }
                    }
                }
                TapHandler {
                    enabled: it.plain && it.on
                    onTapped: {
                        root.close();
                        if (it.modelData.action) it.modelData.action();
                    }
                }
            }
        }
    }
}
