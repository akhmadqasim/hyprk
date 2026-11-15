import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "../../Parsers.js" as Parsers

// General > Storage (27.2.1, reference/re/MAC-ANSWERS-15.md R15.2, live/settings-r15/storage-{calculating,00,01}-*.png
// and their AX dumps; live/settings-r12 and -r13 nav-general--storage-*; window pt, the content's top at 64). The disk
// card 87.5 tall: the volume's name and "x of y used" (frames at 77), the bar at 104 (448 x 21, corners 2;
// Parsers.storageBar: a coloured part per sized category, the largest first, 1 pt apart, then grey "Calculating…"
// while a category is still being sized, else System Data and the system's part, and the available space last with
// its size in 11 pt semibold) and the legend at 131.5 (8 pt dots, 10 pt names). Then the categories by name, rows 42
// tall (pitch 43): a 20 pt tile at 10, the name at 40, and at the right a 16 pt spinner and "Calculating…" until the
// size is known, then the size and an ⓘ (17 pt, its right edge 11.5 in, the size 11.5 before it); when all are sized
// the categories with nothing in them go. A second card: Other Users & Shared and System Data (no ⓘ, the size 10 in)
// around the system's row; Help 10 below it. An ⓘ opens the category's sheet (470 x 400, as the Mac's Developer one:
// a header card, a Name / Size table of what was counted, Delete… and Done).
// The numbers are this computer's system volume (Backend.sysInfo: df; Backend.storageScan: du per category, at idle
// priority, off the UI thread; settings/FALLBACKS.md "General"). Used = size - available, as the Mac's. System Data is
// what is left of the used space. Recommendations: the Mac's card, drawn (no iCloud). Not here: the Mac's own applications' rows, the bubble
// over a hovered part of the bar.
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    property real avail: 0
    property real size: 0
    property string diskName: "Macintosh HD"     // as Finder names "/" (finder/qml/lib/files.js); the volume's label when it has one
    property string systemName: "macOS"          // the system's own name (/etc/os-release NAME)
    // { id: bytes } as Backend.storageSizes; a test sets it
    property var sizes: Backend.storageSizes
    readonly property real used: Math.max(0, size - avail)
    // the Mac's names, those this computer has something for (storage.sh); `symbol`: the tile's glyph, `app`: the
    // application's icon instead. The Mac's "Bin" (en_GB) is Trash in the app's US English.
    property var cats: [
        { id: "applications", name: "Applications", symbol: "appstore" },
        { id: "documents", name: "Documents", symbol: "doc" },
        { id: "music", name: "Music", app: "Music" },
        { id: "photos", name: "Photos", app: "Photos" },
        { id: "trash", name: "Trash", symbol: "trash" }
    ]
    readonly property var systemCats: [
        { id: "otherusers", name: "Other Users & Shared", symbol: "person.2.fill", plain: true },
        { id: "system", name: page.systemName, symbol: "display", light: true },
        { id: "systemdata", name: "System Data", symbol: "ellipsis", plain: true }
    ]
    readonly property var scanned: cats.concat(systemCats.slice(0, 2))
    readonly property bool pending: size <= 0 || scanned.some(c => sizes[c.id] === undefined)
    // bytes of a category: undefined while it is being sized, -1 when this computer has none
    function bytesOf(id) {
        if (id !== "systemdata") return sizes[id];
        if (pending) return undefined;
        return Math.max(0, used - scanned.reduce((s, c) => s + Math.max(0, sizes[c.id]), 0));
    }
    // a row is listed while anything is being sized, then only when it holds something (R15.2: "the long unsorted
    // one" while calculating; storage-00: no Bin, Books, ... row once done)
    function listed(c) { const b = bytesOf(c.id); return b === undefined ? pending : b > 0 || (c.id !== "otherusers" && pending); }
    readonly property var bar: Parsers.storageBar(cats.concat(systemCats.slice(0, 1)), sizes, pending ? undefined : Math.max(0, sizes.system), avail, size, 448)
    // the parts' colours in the bar's order, dark / light (R15.2, measured on storage-00-*.png)
    readonly property var colors: Theme.dark ? ["#EB534E", "#F09748", "#F8D849", "#68CE67", "#63D7C3", "#5FCFDD"]
                                             : ["#EB4C46", "#F09343", "#F7CE46", "#65C466", "#5AC5B3", "#58C0CD"]
    Component.onCompleted: {
        Backend.sysInfo(t => {
            try {
                const i = Parsers.parseSysInfo(t);
                if (i.size > 0) { page.avail = i.avail; page.size = i.size; }
                if (i.diskName !== "") page.diskName = i.diskName;
                if (i.osName !== "") page.systemName = i.osName;
            } catch (e) {}   // the page may be gone by then
        });
        Backend.storageScan(scanned.map(c => c.id));
    }

    Card {
        Item {
            width: parent.width; height: 67.5 + legend.height + 6
            MacText { objectName: "storageDisk"; x: 10; y: 13.5 + (16 - height) / 2; text: page.diskName }
            MacText {
                objectName: "storageUsed"
                anchors.right: parent.right; anchors.rightMargin: 10; y: 13.5 + (16 - height) / 2
                text: page.size > 0 ? Parsers.byteCount(page.used) + " of " + Parsers.byteCount(page.size) + " used" : ""
                color: Theme.secondaryLabel
            }
            Rectangle {   // the track shows in the 1 pt gaps
                id: bar
                objectName: "storageBar"
                x: 10; y: 40; width: 448; height: 21; radius: 2
                color: Theme.separator
                visible: page.size > 0
                Repeater {
                    model: page.bar.parts
                    Rectangle {
                        required property var modelData
                        required property int index
                        objectName: "storagePart-" + modelData.id
                        x: modelData.x; width: modelData.width; height: bar.height
                        topLeftRadius: index === 0 ? 2 : 0; bottomLeftRadius: index === 0 ? 2 : 0
                        color: page.colors[index % page.colors.length]
                    }
                }
                Rectangle {   // "Calculating…" (#6B6C6D / #9A9A9A on the round 12 and 13 stills), else System Data (#808080)
                    objectName: "storageRest"
                    visible: page.bar.rest.width > 0
                    x: page.bar.rest.x; width: page.bar.rest.width; height: bar.height
                    topLeftRadius: page.bar.parts.length === 0 ? 2 : 0; bottomLeftRadius: page.bar.parts.length === 0 ? 2 : 0
                    color: !page.bar.pending ? "#808080" : Theme.dark ? "#6B6C6D" : "#9A9A9A"
                }
                Rectangle {
                    objectName: "storageSystem"
                    visible: page.bar.system.width > 0
                    x: page.bar.system.x; width: page.bar.system.width; height: bar.height
                    color: "#939393"
                }
                Rectangle {
                    objectName: "storageFree"
                    x: page.bar.free.x; width: page.bar.free.width; height: bar.height
                    topRightRadius: 2; bottomRightRadius: 2
                    color: Theme.dark ? Qt.rgba(1, 1, 1, 0.135) : Qt.rgba(0, 0, 0, 0.135)
                    Text {
                        anchors.centerIn: parent
                        visible: parent.width > implicitWidth + 8
                        text: Parsers.byteCount(page.bar.free.bytes)
                        font: Typography.font(11, 590); color: Theme.dark ? "white" : "black"
                    }
                }
            }
            Flow {
                id: legend
                objectName: "storageLegend"
                x: 10; y: 67.5; width: 448; spacing: 11
                visible: page.size > 0
                Repeater {
                    model: page.bar.parts
                    LegendItem { required property var modelData; required property int index; visible: modelData.legend; dot: page.colors[index % page.colors.length]; text: modelData.name }
                }
                LegendItem {
                    visible: page.bar.rest.width > 0
                    dot: !page.bar.pending ? "#808080" : Theme.dark ? "#69696A" : "#9D9D9D"
                    text: page.bar.pending ? "Calculating…" : "System Data"
                }
            }
        }
    }
    // Recommendations (R15.2, ax-storage-00-*: the heading at 331.5, a card 468 x 80 at 357.5; storage-00-*.png): the
    // iCloud tile at 11..37 pt and 12 under the card's top, "Store in iCloud" at 48,10, its text in three 14 pt lines
    // (270 wide) and "Store in iCloud…" 123.5 x 24 at the right. No iCloud here: the button takes the press only
    // (settings/FALLBACKS.md "General")
    Card {
        objectName: "storageRecommendations"
        title: "Recommendations"
        FormRow {
            iconId: "icloud"; iconSize: 26; alignTop: true; topY: 10; iconY: 12; iconX: 11; labelGap: 11; sublabelWidth: 275
            label: "Store in iCloud"
            sublabel: "Store all messages in iCloud and save space by keeping only recent attachments on this Mac when storage space is needed."
            sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
            Button { objectName: "storageStoreInICloud"; text: "Store in iCloud…" }
        }
    }
    Card {
        visible: page.cats.some(c => page.listed(c))
        Repeater {
            model: page.cats.filter(c => page.listed(c))
            CategoryRow { required property var modelData; cat: modelData }
        }
    }
    Card {
        Repeater {
            model: page.systemCats.filter(c => page.listed(c))
            CategoryRow { required property var modelData; cat: modelData }
        }
    }
    Item {   // Help 10 below the last card, its right edge the cards'
        width: parent.width; height: 24
        HelpButton { anchors.right: parent.right; glyphSize: 16 }
    }

    // ---------- a category's ⓘ sheet ----------
    // R15.2, live/settings-r15/storage--developer-info-*.png: 470 x 400. A header card 430 x 66 at 20,20 (the tile, the
    // title "Name – size" at 48,10; the Mac's line of advice and its "Manage in …" button are that application's own
    // and not drawn), a table card 430 x 185 at 20,96 (a 28 pt header Name | Size, the sorted column semibold with a
    // chevron; rows 24 pt in 12 pt text, every second one filled: an 18 pt icon, the name at 33.5, the size ending at 413
    // in the secondary colour), Delete… 74 x 24 at 366,291 and Done. The rows are the folders storage.sh counted for the category, the
    // largest first. Nothing is deleted here: Delete… is drawn as the Mac's without a selection, disabled.
    property var sheetCat: null
    property var sheetItems: []          // Parsers.parseStorageList; a test sets it
    function openInfo(cat) {
        sheetCat = cat; sheetItems = [];
        Backend.run([Backend.root + "/settings/scripts/storage.sh", cat.id, "list"], (c, out) => {
            try { if (c === 0 && page.sheetCat === cat) page.sheetItems = Parsers.parseStorageList(out); } catch (e) {}
        });
        info.open();
    }
    SubSheet {
        id: info
        objectName: "storageInfo"
        sheetWidth: 470; sheetHeight: 400
        Rectangle {
            x: 20; y: 20; width: 430; height: 66; color: "transparent"   // no fill on the still
            Tile { x: 10; y: 19; width: 28; height: 28; cat: page.sheetCat }
            MacText {
                objectName: "storageInfoTitle"
                x: 48; anchors.verticalCenter: parent.verticalCenter
                text: page.sheetCat ? page.sheetCat.name + " \u2013 " + Parsers.byteCount(Math.max(0, page.bytesOf(page.sheetCat.id) || 0)) : ""
            }
        }
        Rectangle {
            x: 20; y: 96; width: 430; height: 185; color: "transparent"
            clip: true
            MacText { x: 10; y: 7; text: "Name"; size: 11; weight: Typography.medium }
            Rectangle { x: 347.5; y: 6; width: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); height: 16; color: Theme.separator }
            MacText { x: 380; y: 7; text: "Size"; size: 11; weight: Typography.bold }
            SfSymbol { x: 415; y: 12; name: "chevron.down"; pointSize: 8; color: Theme.secondaryLabel }
            Rectangle { y: 28; width: parent.width; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12) }
            Repeater {
                model: 7
                Rectangle {
                    required property int index
                    readonly property var entry: page.sheetItems[index]
                    objectName: "storageInfoRow" + index
                    y: 28 + index * 24; width: 430; height: 24
                    color: index % 2 === 1 ? (Theme.dark ? Qt.rgba(1, 1, 1, 0.045) : Qt.rgba(0, 0, 0, 0.04)) : "transparent"
                    Image {
                        visible: !!parent.entry
                        x: 11; y: 3; width: 18; height: 18; sourceSize: Qt.size(64, 64)
                        source: "file://" + Backend.root + "/themes/icons/system/GenericFolderIcon-128.png"
                    }
                    MacText { x: 33.5; anchors.verticalCenter: parent.verticalCenter; width: 305; elide: Text.ElideMiddle; size: 12; text: parent.entry ? parent.entry.name : "" }
                    MacText { x: 413 - width; anchors.verticalCenter: parent.verticalCenter; size: 12; text: parent.entry ? Parsers.byteCount(parent.entry.bytes) : ""; color: Theme.secondaryLabel }
                }
            }
        }
        Button { objectName: "storageInfoDelete"; x: 366; y: 291; width: 74; text: "Delete…"; enabled: false }
    }

    // a category's 20 pt tile: the application's icon, or the Mac's tile with a glyph (dark #171617 with a grey glyph;
    // the system's row a grey tile: storage-01-*.png, the same in both appearances). The Mac's own art is not extracted.
    component Tile: Item {
        id: tile
        property var cat
        readonly property string app: cat && cat.app ? Backend.appIconUrl("", "", Theme.iconLook, cat.app) : ""
        PaneIcon { visible: tile.app !== ""; anchors.centerIn: parent; size: tile.width; imageSource: tile.app }
        Rectangle {
            visible: tile.app === ""
            anchors.fill: parent; radius: width * 0.225
            color: tile.cat && tile.cat.light ? "#96979C" : "#171617"
            border.width: Theme.dark && !(tile.cat && tile.cat.light) ? 0.5 : 0; border.color: Qt.rgba(1, 1, 1, 0.1)
            SfSymbol { anchors.centerIn: parent; name: tile.cat ? tile.cat.symbol || "" : ""; pointSize: tile.width * 0.56; color: tile.cat && tile.cat.light ? "#D8D8DB" : "#C8C7CC" }
        }
    }
    component LegendItem: Row {
        property color dot
        property alias text: name.text
        spacing: 4
        Rectangle { width: 8; height: 8; radius: 4; anchors.verticalCenter: parent.verticalCenter; color: parent.dot }
        Text { id: name; height: 14; verticalAlignment: Text.AlignVCenter; font: Typography.footnote; color: Theme.secondaryLabel }   // 10 pt: "Applications" 59 pt wide on storage-00-dark.png
    }
    component CategoryRow: InfoRow {
        id: row
        property var cat
        readonly property var bytes: page.bytesOf(cat.id)
        objectName: "storageRow-" + cat.id
        rowHeight: 42; iconSize: 20
        label: cat.name
        leading: Tile { anchors.fill: parent; cat: row.cat }
        Row {
            visible: row.bytes === undefined
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4.5
            Spinner { objectName: "storageSpinner-" + row.cat.id; anchors.verticalCenter: parent.verticalCenter; running: parent.visible }
            Text { text: "Calculating…"; font: Typography.body; color: Theme.secondaryLabel }
        }
        Row {
            visible: row.bytes !== undefined
            anchors.verticalCenter: parent.verticalCenter
            spacing: 11.5
            Text { objectName: "storageSize-" + row.cat.id; anchors.verticalCenter: parent.verticalCenter; text: row.bytes !== undefined ? Parsers.byteCount(row.bytes) : ""; font: Typography.body; color: Theme.secondaryLabel }
            Item {   // none on Other Users & Shared and System Data
                visible: !row.cat.plain
                width: 18.5; height: 17
                InfoButton { x: -1; objectName: "storageInfo-" + row.cat.id; glyphSize: 16.5; anchors.verticalCenterOffset: -0.5; onClicked: page.openInfo(row.cat) }
            }
        }
    }
}
