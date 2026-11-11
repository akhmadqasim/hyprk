import QtQuick
import Quickshell
import qs
import qs.HyprK
import qs.components
import "../../lib/spotlight.js" as SL

// The mode list that drops under the empty Spotlight bar once the pointer enters it (macOS 27.2.1, MAC-ANSWERS.md
// Q-panels-22, -23): 520 x 214, four rows of 48 from y 11: the mode glyph centred at x 44, the name in SF 17 regular
// at x 81, the shortcut "⌘1".."⌘4" in SF 14 regular grey right-aligned 38 from the edge. Rows are shortcuts: no
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
                name: row.modelData.symbol
                size: Theme.spotlight.modeListGlyph
                color: Theme.spotlight.text
            }
            Text {
                x: Theme.spotlight.modeListLabelX
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.title
                font: Typography.font(Theme.spotlight.rowTitle)
                color: Theme.spotlight.text
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: Theme.spotlight.shortcutRight
                anchors.verticalCenter: parent.verticalCenter
                // the key that works here: in a nested session (HYPRK_NESTED, dist/try-nested.sh) the host keeps Super and
                // Ctrl+1..4 are Hyprland's Space binds, so only Option (Alt) + 1..4 reach Spotlight (SPOTLIGHT-27.2.1.md 6)
                text: (list.nested ? "⌥" : "⌘") + (row.index + 1)
                font: Typography.font(Theme.spotlight.shortcutSize)
                color: Theme.spotlight.shortcut
            }
            MouseArea { anchors.fill: parent; onClicked: list.picked(row.modelData.id) }
        }
    }
}
