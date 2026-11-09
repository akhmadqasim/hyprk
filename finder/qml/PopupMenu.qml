import QtQuick
import QtQuick.Controls.Basic

// macOS 26 style menu: rounded translucent panel, blue rounded highlight.
// items: [{ text, shortcut, checked, enabled, action }] or { separator: true }.
Popup {
    id: root

    property var items: []

    padding: 5
    width: Math.max(200, list.implicitWidth + 2 * padding)
    implicitHeight: list.implicitHeight + 2 * padding
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        radius: 12
        color: Theme.dark ? Qt.rgba(0.16, 0.16, 0.17, 0.98) : Qt.rgba(0.97, 0.97, 0.97, 0.98)
        border.width: 1
        border.color: Theme.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.12)
    }

    contentItem: Column {
        id: list
        Repeater {
            model: root.items
            Item {
                id: it
                required property var modelData
                readonly property bool sep: !!modelData.separator
                readonly property bool on: modelData.enabled !== false
                width: root.width - 2 * root.padding
                height: sep ? 11 : 24
                implicitWidth: sep ? 0 : label.implicitWidth + shortcutText.implicitWidth + 64

                Rectangle {
                    visible: it.sep
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: 1
                    color: Theme.color.separator
                }
                Rectangle {
                    visible: !it.sep && it.on && hover.hovered
                    anchors.fill: parent
                    radius: 6
                    color: Theme.color.accent
                }
                Text {
                    visible: !it.sep && !!it.modelData.checked
                    x: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "✓"
                    color: hover.hovered ? "white" : Theme.color.label
                    font.family: Theme.fontText
                    font.pixelSize: 13
                }
                Text {
                    id: label
                    visible: !it.sep
                    x: 24
                    anchors.verticalCenter: parent.verticalCenter
                    text: it.modelData.text || ""
                    color: !it.on ? Theme.color.tertiaryLabel : hover.hovered ? "white" : Theme.color.label
                    font.family: Theme.fontText
                    font.pixelSize: 13
                }
                Text {
                    id: shortcutText
                    visible: !it.sep
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: it.modelData.shortcut || ""
                    color: hover.hovered && it.on ? "white" : Theme.color.secondaryLabel
                    font.family: Theme.fontText
                    font.pixelSize: 13
                }
                HoverHandler { id: hover; enabled: !it.sep }
                TapHandler {
                    enabled: !it.sep && it.on
                    onTapped: {
                        root.close();
                        if (it.modelData.action) it.modelData.action();
                    }
                }
            }
        }
    }
}
