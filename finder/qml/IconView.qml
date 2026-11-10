import QtQuick
import HyprK
import QtQuick.Controls.Basic
import "lib/files.js" as Files

// Icon grid. Columns stretch to fill the width; rubber-band selection on empty space.
GridView {
    id: grid

    required property var browser
    signal contextMenu(var entry, point pos)

    readonly property int columns: Math.max(1, Math.floor((width - 2 * Theme.grid.sidePad) / Theme.grid.cellWidth))

    model: browser.entries
    leftMargin: Theme.grid.sidePad
    rightMargin: Theme.grid.sidePad
    cellWidth: Math.floor((width - 2 * Theme.grid.sidePad) / columns)
    cellHeight: Theme.grid.cellHeight
    interactive: false     // wheel still scrolls; drags make a rubber band instead of flicking
    boundsBehavior: Flickable.StopAtBounds
    clip: true
    currentIndex: browser.cursor
    highlightFollowsCurrentItem: false
    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

    function ensureVisible(i) { positionViewAtIndex(i, GridView.Contain); }

    // empty space: click clears, drag selects with a rubber band
    MouseArea {
        id: band
        z: -1
        x: -grid.leftMargin   // content x of cell i is leftMargin + col * cellWidth in these coords
        width: grid.width
        height: Math.max(grid.contentHeight, grid.height)
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        property point start
        property var base: ({})   // selection before the drag; Ctrl/Shift drags add to it
        property rect area: Qt.rect(0, 0, 0, 0)
        onPressed: mouse => {
            grid.forceActiveFocus();
            if (mouse.button === Qt.RightButton) {
                grid.browser.clearSelection();
                grid.contextMenu(null, mapToItem(null, mouse.x, mouse.y));
                return;
            }
            if (!(mouse.modifiers & (Qt.ControlModifier | Qt.ShiftModifier))) grid.browser.clearSelection();
            base = grid.browser.selected;
            start = Qt.point(mouse.x, mouse.y);
            area = Qt.rect(mouse.x, mouse.y, 0, 0);
        }
        onPositionChanged: mouse => {
            area = Qt.rect(Math.min(start.x, mouse.x), Math.min(start.y, mouse.y),
                           Math.abs(mouse.x - start.x), Math.abs(mouse.y - start.y));
            const hits = [];
            for (let i = 0; i < grid.count; i++) {
                const cx = grid.leftMargin + (i % grid.columns) * grid.cellWidth + (grid.cellWidth - Theme.grid.labelWidth) / 2;
                const cy = Math.floor(i / grid.columns) * grid.cellHeight + Theme.grid.iconTop - 8;
                if (cx < area.x + area.width && cx + Theme.grid.labelWidth > area.x
                    && cy < area.y + area.height && cy + grid.cellHeight - 12 > area.y)
                    hits.push(i);
            }
            grid.browser.setSelection(hits, base);
        }
        onReleased: area = Qt.rect(0, 0, 0, 0)

        Rectangle {
            visible: band.pressed && band.area.width > 2
            x: band.area.x
            y: band.area.y
            width: band.area.width
            height: band.area.height
            color: Theme.color.rubberBand
            border.width: 1
            border.color: Theme.color.rubberBandBorder
        }
    }

    delegate: Item {
        id: cell
        required property var modelData
        required property int index
        readonly property bool selected: grid.browser.isSelected(modelData.path)
        readonly property bool renaming: grid.browser.renamingPath === modelData.path
        width: grid.cellWidth
        height: grid.cellHeight

        Rectangle {   // icon selection plate
            anchors.centerIn: icon
            width: Theme.grid.iconSize + 12
            height: Theme.grid.iconSize + 12
            radius: Theme.grid.selectionRadius
            color: Theme.color.iconSelection
            visible: cell.selected || drop.hovered
        }
        FileIcon {
            id: icon
            entry: cell.modelData
            size: Theme.grid.iconSize
            thumbScale: Theme.grid.thumbScale
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.grid.iconTop
        }

        Rectangle {   // label highlight hugs the wrapped text
            visible: cell.selected && !cell.renaming
            anchors.horizontalCenter: label.horizontalCenter
            y: label.y - 1
            width: label.contentWidth + 10
            height: label.contentHeight + 2
            radius: Theme.grid.labelRadius
            color: Theme.color.labelSelection
        }
        Text {
            id: label
            visible: !cell.renaming
            anchors.horizontalCenter: parent.horizontalCenter
            y: icon.y + icon.height + Theme.grid.labelGap
            width: Theme.grid.labelWidth
            horizontalAlignment: Text.AlignHCenter
            text: Files.hasTags(cell.modelData) ? Files.styledName(cell.modelData, Theme.color.tagColors) : cell.modelData.name
            textFormat: Files.hasTags(cell.modelData) ? Text.StyledText : Text.PlainText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            lineHeight: 1.12
            color: cell.selected ? "white" : Theme.color.label
            font: Typography.font(Theme.font.label)
        }
        Loader {
            active: cell.renaming
            anchors.horizontalCenter: parent.horizontalCenter
            y: label.y - 2
            width: Theme.grid.labelWidth + 8
            sourceComponent: RenameField {
                browser: grid.browser
                entry: cell.modelData
            }
        }

        EntryMouseArea {
            x: (parent.width - Theme.grid.labelWidth) / 2
            y: icon.y - 6
            width: Theme.grid.labelWidth
            height: label.y + label.contentHeight - y + 4
            browser: grid.browser
            entry: cell.modelData
            index: cell.index
            onContextMenu: (e, pos) => grid.contextMenu(e, pos)
        }
        FolderDrop {
            id: drop
            x: (parent.width - Theme.grid.labelWidth) / 2
            y: icon.y - 6
            width: Theme.grid.labelWidth
            height: icon.height + 12
            enabled: cell.modelData.isDir === true
            browser: grid.browser
            path: cell.modelData.path
        }
    }
}
