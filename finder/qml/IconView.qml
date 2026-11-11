import QtQuick
import HyprK
import "lib/files.js" as Files

// Icon grid (Q-finder-12/13/14): 64 pt icons in fixed 112 x 112 cells from 10 pt under the toolbar; the
// selection is a grey 72 pt plate behind the icon and an accent pill behind the label (grey with label text
// while the window is inactive); no hover. Rubber-band selection on empty space.
GridView {
    id: grid

    required property var browser
    signal contextMenu(var entry, point pos)

    readonly property int columns: Files.gridColumns(width, Theme.grid.cellWidth, Theme.grid.sidePad)

    model: browser.entries
    leftMargin: Theme.grid.sidePad
    rightMargin: Theme.grid.sidePad
    topMargin: Theme.grid.top
    cellWidth: Theme.grid.cellWidth
    cellHeight: Theme.grid.cellHeight
    interactive: false     // wheel still scrolls; drags make a rubber band instead of flicking
    boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
    RubberBand { flickable: grid }
    clip: true
    currentIndex: browser.cursor
    highlightFollowsCurrentItem: false

    // the label lays out in 1 pt more than the 104 pt ink width (advance includes the side bearings): "from the…mber.txt"
    // advances 104.05 pt and the Mac draws it, ink 101 pt
    readonly property real labelLayoutWidth: Theme.grid.labelWidth + 1
    // A name longer than two lines keeps its first line's words and loses the middle of the rest, so the extension
    // stays ("Meeting notes" / "from the…mber.txt" in icons-light.png; Qt could only cut the end: "from the plannin…")
    Text { id: labelProbe; visible: false; font: Typography.font(Theme.font.label) }   // widths as the label lays out
    readonly property QtObject labelMetrics: QtObject {
        function advanceWidth(t) { labelProbe.text = t; return labelProbe.implicitWidth; }
    }
    function labelText(name) {
        const w = labelLayoutWidth;
        if (labelMetrics.advanceWidth(name) <= w) return name;
        const words = name.split(" ");
        let first = words[0], i = 1;
        if (labelMetrics.advanceWidth(first) > w) return name;   // no word break: Qt wraps anywhere
        while (i < words.length && labelMetrics.advanceWidth(first + " " + words[i]) <= w) first += " " + words[i++];
        const rest = words.slice(i).join(" ");
        if (labelMetrics.advanceWidth(rest) <= w) return name;   // two lines are enough
        // middle elision by hand (FontMetrics.elidedText measured wider than the label draws: "from th…ber.txt", 86 pt)
        let a = Math.ceil(rest.length / 2), b = rest.length - a;
        const cut = () => rest.slice(0, a) + "\u2026" + rest.slice(rest.length - b);
        while ((a > 0 || b > 0) && labelMetrics.advanceWidth(cut()) > w) { if (a > b) a--; else b--; }
        return first + "\n" + cut();
    }

    function ensureVisible(i) { positionViewAtIndex(i, GridView.Contain); }
    // the icon of entry i, when its delegate exists (Quick Look closes into it)
    function iconItem(i) { const c = itemAtIndex(i); return c ? c.iconItem : null; }

    OverlayScrollbar {
        parent: grid
        flickable: grid
        x: grid.width - width - Tokens.scroller.inset
        y: Tokens.scroller.inset
        height: grid.height - 2 * Tokens.scroller.inset
    }

    // empty space: click clears, drag selects with a rubber band
    MouseArea {
        id: band
        z: -1
        x: -grid.leftMargin   // content x of cell i is leftMargin + col * cellWidth in these coords
        y: -grid.topMargin
        width: grid.width
        height: Math.max(grid.contentHeight + grid.topMargin, grid.height)
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
            const g = Theme.grid;
            const r = Qt.rect(area.x, area.y - grid.topMargin, area.width, area.height);
            grid.browser.setSelection(Files.gridHits(r, grid.count, grid.columns, g.cellWidth, g.sidePad, g.labelWidth,
                                                     g.iconTop, g.cellHeight - 8), base);
        }
        onReleased: area = Qt.rect(0, 0, 0, 0)

        Rectangle {   // not measured on 27.2.1
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
        readonly property Item iconItem: icon
        // set, not bound: labelText measures with a probe Text (a binding would loop on its width)
        property string labelPlain
        function relabel() { labelPlain = grid.labelText(modelData.name); }
        Component.onCompleted: relabel()
        onModelDataChanged: relabel()

        Rectangle {   // selection plate 72 x 72, r 7; also the folder drop target (Q-finder-13, -28)
            anchors.centerIn: icon
            width: Theme.grid.plate
            height: Theme.grid.plate
            radius: Theme.grid.plateRadius
            color: Theme.color.iconPlate
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

        Rectangle {   // label pill hugs the wrapped text: 17 tall for one line, r 5, about 5 pt side padding
            // (a tagged name's pill 1 pt higher and 2 narrower: Sunset.png's 808..985 x 496..529 px in icons-light.png)
            readonly property bool tagged: Files.hasTags(cell.modelData)
            visible: cell.selected && !cell.renaming
            anchors.horizontalCenter: label.horizontalCenter
            y: label.y - 0.5 - (tagged ? 1 : 0)
            width: label.contentWidth + 2 * Theme.grid.labelPad - (tagged ? 2 : 0)
            height: label.contentHeight + 1
            radius: Theme.grid.labelRadius
            color: Theme.color.labelSelection
        }
        Text {
            id: label
            visible: !cell.renaming
            anchors.horizontalCenter: parent.horizontalCenter
            y: icon.y + icon.height + Theme.grid.labelGap
            width: grid.labelLayoutWidth
            horizontalAlignment: Text.AlignHCenter
            text: Files.hasTags(cell.modelData) ? Files.styledName(cell.modelData, Theme.color.tagDotColors) : cell.labelPlain
            textFormat: Files.hasTags(cell.modelData) ? Text.StyledText : Text.PlainText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            lineHeightMode: Text.FixedHeight
            lineHeight: Theme.grid.lineHeight
            color: cell.selected ? Theme.color.selectedText : Theme.color.label
            font: Typography.font(Theme.font.label)
        }
        Loader {
            active: cell.renaming
            anchors.horizontalCenter: parent.horizontalCenter
            y: label.y - 1
            width: Theme.grid.labelWidth
            sourceComponent: RenameField {
                browser: grid.browser
                entry: cell.modelData
            }
        }

        EntryMouseArea {
            x: (parent.width - Theme.grid.labelWidth) / 2
            y: icon.y - 4
            width: Theme.grid.labelWidth
            height: label.y + label.contentHeight - y + 2
            browser: grid.browser
            entry: cell.modelData
            index: cell.index
            onContextMenu: (e, pos) => grid.contextMenu(e, pos)
        }
        FolderDrop {
            id: drop
            x: (parent.width - Theme.grid.plate) / 2
            y: icon.y - 4
            width: Theme.grid.plate
            height: Theme.grid.plate
            enabled: cell.modelData.isDir === true
            browser: grid.browser
            path: cell.modelData.path
        }
    }
}
