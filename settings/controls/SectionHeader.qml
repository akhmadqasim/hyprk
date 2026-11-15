import QtQuick
import ".."
import "../HyprK"

// Bold group title above a card or grid.
MacText {
    leftPadding: Theme.content.rowPadding
    topPadding: Theme.content.headerTop
    property bool regular: false
    font: regular ? Typography.body : Typography.headline   // 13 Bold; 13 Regular where the Mac's heading is (Card.titleRegular)
}
