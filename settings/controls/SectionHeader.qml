import QtQuick
import ".."

// Bold group title above a card or grid.
MacText {
    leftPadding: Theme.content.rowPadding
    topPadding: Theme.content.headerTop
    font.pixelSize: Theme.font.sectionHeader
    weight: Font.Bold
}
