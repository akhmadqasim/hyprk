import QtQuick
import Quickshell
import qs
import qs.HyprK
import qs.components
import "../../lib/spotlight.js" as SL

// The mode list under the empty Spotlight bar once the pointer moves (macOS 27.2.1, MAC-ANSWERS.md Q-panels-22, -23;
// MAC-ANSWERS-3.md R3.2b; its motion: Spotlight.qml panelMotion): 520 x 214, four rows of 48 from y 11: the mode glyph centred at x 44, the name in SF 17 regular
// at x 81, the shortcut "⌘1".."⌘4" in SF 17 regular grey right-aligned 36 from the edge. Rows are shortcuts: no
// active state and no hover fill. A click picks the mode.
Item {
    id: list
    signal picked(string mode)
    readonly property bool nested: Quickshell.env("HYPRK_NESTED") === "1"

    Repeater {
        model: SL.modes()
        Item {
            id: row
            required property var modelData
            required property int index
            y: Theme.spotlight.modeListPad + index * Theme.spotlight.modeRow
            width: list.width
            height: Theme.spotlight.modeRow
            Symbol {
                x: Theme.spotlight.modeListGlyphCX - width / 2
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: Theme.spotlight.modeListGlyphDY
                name: row.modelData.symbol
                // the App Store "A" is drawn larger than the others (r17: ink 22.5 x 20, ours at 22 read 20 x 18)
                size: Theme.spotlight.modeListGlyph * (row.modelData.symbol === "appstore" ? Theme.spotlight.modeListAppsScale : 1)
                color: Theme.spotlight.text
            }
            Text {
                x: Theme.spotlight.modeListLabelX
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.title
                font: Typography.font(Theme.spotlight.rowTitle)
                color: Theme.spotlight.text
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.spotlight.shortcutRight
                anchors.verticalCenter: parent.verticalCenter
                // the key that works here: in a nested session (HYPRK_NESTED, dist/try-nested.sh) the host keeps Super and
                // Ctrl+1..4 are Hyprland's Space binds, so only Option (Alt) + 1..4 reach Spotlight (SPOTLIGHT-27.2.1.md 6)
                // SF 17 (r17 spotlight-modelist-*: the digit's ink is 12.5 pt tall, the ⌘ 12.5 x 13; at 14 ours read 10 and
                // 11 x 10.5). The four ⌘ start at one x (489 of the 520) and "1" sits in the middle of the others' width:
                // the digit in a slot of its monospaced advance (10.5 at 17)
                Text {
                    text: list.nested ? "⌥" : "⌘"
                    font: Typography.font(Theme.spotlight.shortcutSize)
                    color: "#FFFFFF"
                }
                Text {
                    width: Theme.spotlight.shortcutDigitW
                    horizontalAlignment: Text.AlignHCenter
                    text: row.index + 1
                    font: Typography.font(Theme.spotlight.shortcutSize)
                    color: "#FFFFFF"
                }
                // plus-lighter: only the coverage is used, the panel + Theme.spotlight.shortcutLift under it
                layer.enabled: visible
                layer.effect: ShaderEffect {
                    property real lift: Theme.spotlight.shortcutLift
                    fragmentShader: Qt.resolvedUrl("../../shaders/plustext.frag.qsb")
                }
            }
            MouseArea { anchors.fill: parent; onClicked: list.picked(row.modelData.id) }
        }
    }
}
