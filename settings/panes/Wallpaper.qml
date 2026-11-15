import QtQuick
import Qt.labs.folderlistmodel
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P

// Functional: picks from themes/wallpapers, records state/wallpaper.json
// (the shell reads it) and applies with hyprpaper or swaybg when present.
// Layout: the 27.2.1 pane (settings/wallpaper-{light,dark}.png, 2x; window coordinates in pt): a header without a
// card (preview 160 x 100 r5 at 248,68; a card 306 wide at 418,68 with the name + "Fill Screen" pop-up and "Show on
// all Spaces"; "Screen Saver…" and "Clock Appearance…" right-aligned at y 153), a 1 pt divider #E6E6E6 / #343539
// across the content at y 193, then one section per category: 13 Bold heading (21.5 below the divider, 31 between
// sections) with a grey "Show All (n)" at the right, tiles 107.5 x 71 r3 at a 117.5 pitch in a row that scrolls
// sideways past the window edge, captions 13 pt under them. The current picture has a 2 pt grey ring (#DCDCDC /
// #464646) 0.5 pt outside it. Categories: the Mac's names where our pictures are Apple's (Dynamic Wallpapers,
// Landscape); the Mac/iMac colour pictures are under "Pictures" (the Mac section further down was not captured).
// "Your Photos" is left out: there is no photo library to add from.
Column {
    id: pane
    spacing: 0

    readonly property string dir: Backend.root + "/themes/wallpapers"
    // nothing chosen yet: the picture the shell shows, its default pick (shell/scripts/wallpaper.sh: the first by
    // path whose name has "tahoe" and the mode, else the mode, else any), as the Mac shows its default selected
    readonly property string current: AppState.wallpaperImage || defaultPick
    readonly property string defaultPick: {
        const mode = Theme.dark ? "dark" : "light";
        const all = files.slice().sort();
        const name = f => base(f).toLowerCase();
        return all.find(f => name(f).includes("tahoe") && name(f).includes(mode)) || all.find(f => name(f).includes(mode)) || all[0] || "";
    }
    function apply(path) {
        AppState.setWallpaper(path);
        Backend.run([Backend.root + "/settings/scripts/set-wallpaper.sh", path]);
    }

    // The assets agent sorts pictures into subfolders; scan the root and its image folders.
    property var files: []
    property int ready: 0
    function collect() {
        const out = [];
        for (const m of [w0, w1])
            for (let i = 0; i < m.count; i++) out.push(String(m.get(i, "filePath")));
        files = out;
        if (out.length) thumbTimer.restart();  // debounces both folder models
    }
    property int thumbGen: 0     // bumps when thumbnails were created, to reload the tiles
    Timer { id: thumbTimer; interval: 300; onTriggered: Backend.makeThumbs(pane.files, c => { if (c === 0) pane.thumbGen++; }) }
    component Walls: FolderListModel {
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Name
        onStatusChanged: if (status === FolderListModel.Ready) { pane.ready++; Qt.callLater(pane.collect); }
    }
    Walls { id: w0; folder: "file://" + pane.dir }
    Walls { id: w1; folder: "file://" + pane.dir + "/png" }

    // tiles per section: a light/dark pair (TahoeLight + TahoeDark, Sonoma-0 + Sonoma-1) is one dynamic tile
    function base(p) { return String(p).replace(/^.*\//, "").replace(/\.[^.]+$/, ""); }
    readonly property var sections: {
        const pairs = {}, single = [];
        for (const f of files) {
            const b = base(f), m = b.match(/^(.*?)(Light|Dark|-0|-1)$/);
            if (m) { const k = m[1]; pairs[k] = pairs[k] || { name: k, light: "", dark: "" };
                     pairs[k][m[2] === "Light" || m[2] === "-0" ? "light" : "dark"] = f; }
            else single.push(f);
        }
        const dyn = Object.values(pairs).map(p => ({ name: p.name, light: p.light || p.dark, dark: p.dark || p.light }));
        const land = [], pics = [];
        for (const f of single) {
            const t = { name: P.prettyFileName(f), light: f, dark: f };
            (/^(Mac|iMac|Radial) /.test(base(f)) ? pics : land).push(t);
        }
        return [{ title: "Dynamic Wallpapers", tiles: dyn }, { title: "Landscape", tiles: land }, { title: "Pictures", tiles: pics }]
            .filter(s => s.tiles.length > 0);
    }
    function pick(t) { return Theme.dark ? t.dark : t.light; }
    function isCurrent(t) { return current !== "" && (current === t.light || current === t.dark); }
    readonly property var currentTile: {
        for (const s of sections) for (const t of s.tiles) if (isCurrent(t)) return t;
        return null;
    }

    // ---------- header ----------
    // Pinned (27.2.1 wallpaper-{00..04}-light.png, ax-wallpaper-light.jsonl: the header stays, the ScrollArea
    // "Wallpapers" starts at y 142 under the divider and its sections scroll under it): the header moves with the content
    // view's offset (`flick`, SettingsApp's scroll view, the Loader's context) over the window colour down to the divider
    readonly property bool pinnedHeader: true
    Item {
        z: 1
        transform: Translate { y: typeof flick !== "undefined" ? Math.max(0, flick.contentY) : 0 }
        width: parent.width
        height: 193 - 64 + 21.5          // to the divider (window y 193; the pane starts at 64), then to the first heading
        Rectangle {   // the sections pass under this, from the toolbar's bottom to the divider
            x: -Theme.content.padding; y: -Theme.content.top
            width: parent.width + 2 * Theme.content.padding; height: 193 - 64 + Theme.content.top
            color: Theme.windowBg
        }
        Rectangle { // preview, 160 x 100
            x: -4; y: 4; width: 160; height: 100; radius: 5
            color: Theme.controlFill
            RoundedImage { anchors.fill: parent; radius: 5; decodeWidth: 320; path: pane.current; generation: pane.thumbGen }
        }
        Card {
            x: 166; y: 4; width: 306
            FormRow {
                label: pane.currentTile ? pane.currentTile.name : pane.current ? P.prettyFileName(pane.current) : ""
                LocalPopup { model: ["Fill Screen", "Fit to Screen", "Stretch to Fill Screen", "Center", "Tile"]; objectName: "wallpaperFill" }
            }
            FormRow { label: "Show on all Spaces"; LocalSwitch { checked: false } }
        }
        Row {
            x: 472 - width; y: 89            // window y 153, right edge 724
            spacing: 8.5
            Button { objectName: "wallpaperScreenSaverButton"; text: "Screen Saver…"; onClicked: saver.open() }
            Button { id: clockButton; objectName: "wallpaperClockButton"; text: "Clock Appearance…"; onClicked: clock.show(clockButton) }
        }
        Rectangle {
            x: -Theme.content.padding; y: 193 - 64
            width: parent.width + 2 * Theme.content.padding; height: 1
            color: Theme.dark ? "#343539" : "#E6E6E6"
        }
    }

    // ---------- sections ----------
    Repeater {
        model: pane.sections
        Column {
            id: sec
            required property var modelData
            required property int index
            property bool all: false             // "Show All": the row wraps into a grid
            width: pane.width
            topPadding: index > 0 ? 31 : 0
            spacing: 9.5
            Item {
                width: parent.width; height: 16
                MacText { text: sec.modelData.title; font: Typography.headline; anchors.verticalCenter: parent.verticalCenter }
                MacText {
                    visible: sec.modelData.tiles.length > 4
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    text: sec.all ? "Show Less" : "Show All (" + sec.modelData.tiles.length + ")"
                    // 11 pt: "Show All (35)" is 69 pt wide on wallpaper-00-light.png (R3.8b; AX button 70.5 x 14), ours
                    // was 79 at 13 pt
                    size: 11
                    color: Theme.secondaryLabel
                    MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: sec.all = !sec.all }
                }
            }
            Flickable {
                id: strip
                // the row runs past the content margin to the window edge (the 5th tile peeks in)
                width: sec.all ? parent.width : parent.width + Theme.content.padding
                height: flow.height
                contentWidth: flow.width
                contentHeight: height
                clip: true
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
                interactive: !sec.all
                acceptedButtons: Qt.NoButton                  // no mouse-drag scrolling (AppKit)
                RubberBand { flickable: strip }
                Flow {
                    id: flow
                    width: sec.all ? strip.width : sec.modelData.tiles.length * 117.5 - 10
                    spacing: 10
                    Repeater {
                        model: sec.modelData.tiles
                        Column {
                            id: tile
                            required property var modelData
                            spacing: 2
                            Item {
                                width: 107.5; height: 71
                                Rectangle { // the current picture: 2 pt grey ring 0.5 pt outside the tile
                                    visible: pane.isCurrent(tile.modelData)
                                    anchors.fill: parent; anchors.margins: -2.5
                                    radius: 5.5; color: "transparent"
                                    border.width: 2; border.color: Theme.dark ? "#464646" : "#DCDCDC"
                                }
                                Rectangle { anchors.fill: parent; radius: 3; color: Theme.controlFill }
                                // a light/dark pair shows both halves (light left, as the Mac's dynamic tiles)
                                RoundedImage {
                                    anchors.fill: parent; radius: 3; decodeWidth: 216
                                    path: tile.modelData.light; generation: pane.thumbGen
                                }
                                Item {
                                    visible: tile.modelData.dark !== tile.modelData.light
                                    x: parent.width / 2; width: parent.width / 2; height: parent.height; clip: true
                                    RoundedImage {
                                        x: -parent.x; width: 107.5; height: 71; radius: 3; decodeWidth: 216
                                        path: tile.modelData.dark; generation: pane.thumbGen
                                    }
                                }
                                MouseArea { anchors.fill: parent; onClicked: pane.apply(pane.pick(tile.modelData)) }
                            }
                            MacText {   // 10 pt: "Tahoe" is 56 px of ink on wallpaper-00-light.png, ours 71 at 13 pt
                                width: 107.5; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                                size: 10
                                text: tile.modelData.name
                            }
                        }
                    }
                }
            }
        }
    }
    Item { width: 1; height: 20 }

    // ---------- Screen Saver… (MAC-ANSWERS-13.md R13.1, live/settings-r13/dest-wallpaper--screen-saver-*.png, ax-dest-...) ----------
    // A sheet 500 x 548 at y 52: the chosen saver's picture 160 x 100, a card (Start Screen Saver… pop-up "Never", Use
    // Screen Saver: Automatic / Custom, the saver's name), a divider, then the savers by section in a scroll area (the
    // pane's tiles at a 117.5 pitch, 145.5 per section), Done. hyprk has no screen savers: the sections are the pane's
    // pictures, a click only marks the tile, nothing is stored (settings/FALLBACKS.md "Sheets").
    SubSheet {
        id: saver
        objectName: "wallpaperScreenSaver"
        sheetWidth: 500; sheetHeight: 548; sheetTop: 52
        property var chosen: null
        property int use: 1
        readonly property var tile: chosen || pane.currentTile
        RoundedImage { x: 170; y: 20; width: 160; height: 100; radius: 5; decodeWidth: 320; path: saver.tile ? pane.pick(saver.tile) : pane.current; generation: pane.thumbGen }
        Column {
            x: 20; y: 140; width: 460
            Card {
                FormRow { label: "Start Screen Saver…"; LocalPopup { objectName: "saverStart"; model: ["Never"] } }
                FormRow {
                    label: "Use Screen Saver"
                    Row {
                        spacing: 16
                        Checkbox { radio: true; text: "Automatic"; checked: saver.use === 0; onToggled: saver.use = 0 }
                        Checkbox { objectName: "saverCustom"; radio: true; text: "Custom"; checked: saver.use === 1; onToggled: saver.use = 1 }
                    }
                }
                FormRow { objectName: "saverName"; label: saver.tile ? saver.tile.name : "" }
            }
        }
        Rectangle { y: 272; width: parent.width; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
        Flickable {
            id: saverFlick
            y: 273; width: parent.width; height: 210
            clip: true
            contentHeight: saverList.height + 20
            boundsBehavior: Flickable.StopAtBounds
            acceptedButtons: Qt.NoButton
            Column {
                id: saverList
                x: 20; y: 20; width: parent.width - 20
                spacing: 31
                Repeater {
                    model: pane.sections
                    Column {
                        id: ssec
                        required property var modelData
                        width: saverList.width
                        spacing: 9.5
                        Item {
                            width: 460; height: 16
                            MacText { text: ssec.modelData.title === "Dynamic Wallpapers" ? "macOS" : ssec.modelData.title; font: Typography.headline; anchors.verticalCenter: parent.verticalCenter }
                            MacText { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: "Show All (" + ssec.modelData.tiles.length + ")"; size: 11; color: Theme.secondaryLabel }
                        }
                        Row {
                            spacing: 10
                            Repeater {
                                model: ssec.modelData.tiles.slice(0, 5)
                                Column {
                                    id: stile
                                    required property var modelData
                                    required property int index
                                    spacing: 2
                                    Item {
                                        width: 107.5; height: 71
                                        Rectangle {
                                            visible: saver.tile === stile.modelData || (saver.tile && saver.tile.light === stile.modelData.light)
                                            anchors.fill: parent; anchors.margins: -2.5
                                            radius: 5.5; color: "transparent"
                                            border.width: 2; border.color: Theme.dark ? "#464646" : "#DCDCDC"
                                        }
                                        RoundedImage { anchors.fill: parent; radius: 3; decodeWidth: 216; path: pane.pick(stile.modelData); generation: pane.thumbGen }
                                        MouseArea { anchors.fill: parent; onClicked: saver.chosen = stile.modelData }
                                    }
                                    MacText { width: 107.5; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; size: 10; text: stile.modelData.name }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------- Clock Appearance… (R13.1, dest-wallpaper--clock-appearance-*.png, ax-dest-...) ----------
    // A popover under the button (the Mac's bubble 404 x 161, its arrow on the button's centre): one card 384 x
    // 141.5 with "Show large clock" (pop-up "On Lock Screen"), six "12" faces (Soft, Rounded, Stencil, New York, Slab,
    // Rail: 38 pt boxes 62 apart, the chosen one ringed) and a Weight slider 200 wide. The Mac's popover is its own
    // window and reaches 126 pt past the window's right edge; here it stays inside the window. The faces are drawn in
    // the system font (the Mac's clock faces are not in the repo). Nothing is stored (settings/FALLBACKS.md "Sheets").
    Item {
        visible: false; width: 0; height: 0
        Popover {
            id: clock
            objectName: "wallpaperClockPopover"
            bodyWidth: 404; bodyHeight: 161      // ax: the popover's scroll area 404 x 161 at 449,190.5, the card 10 pt inside
            inset: 10
            anchorGap: 4.5                      // the bubble's top 13.5 under the button (9 of it the arrow)
            z: 1000
            property int face: 0
            function show(button) {
                let p = pane;
                while (p.parent) p = p.parent;
                parent = p; width = p.width; height = p.height;
                openAt(button);
            }
            Rectangle {
                width: 384; height: 141.5
                radius: Theme.content.cardRadius; color: Theme.cardFill; border.color: Theme.cardStroke
                MacText { x: 10; y: 10; text: "Show large clock" }
                LocalPopup { objectName: "clockShow"; anchors.right: parent.right; anchors.rightMargin: 10; y: 6.5; model: ["On Lock Screen"] }
                Rectangle { x: 10; y: 37.5; width: parent.width - 20; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
                Repeater {
                    model: ["Soft", "Rounded", "Stencil", "New York", "Slab", "Rail"]
                    Rectangle {
                        required property string modelData
                        required property int index
                        objectName: "clockFace" + index
                        x: 18 + index * 62; y: 52.5; width: 38; height: 38; radius: 8
                        color: "transparent"
                        border.width: clock.face === index ? 2 : 0; border.color: Theme.accent
                        Text { anchors.centerIn: parent; text: "12"; font: Typography.font(22, 700); color: Theme.label }
                        MouseArea { anchors.fill: parent; onClicked: clock.face = index }
                    }
                }
                Rectangle { x: 10; y: 104; width: parent.width - 20; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
                MacText { x: 10; y: 115.5; text: "Weight" }
                Slider { objectName: "clockWeight"; x: 174; y: 115; width: 200; value: 0.7067; onMoved: v => value = v }
            }
        }
    }
}
