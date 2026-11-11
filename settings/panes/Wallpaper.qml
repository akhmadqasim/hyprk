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
    readonly property string current: AppState.wallpaperImage
    property string note: ""

    function apply(path) {
        note = "";
        AppState.setWallpaper(path);
        Backend.run([Backend.root + "/settings/scripts/set-wallpaper.sh", path], (c, o) => {
            if (c === 3) note = "Saved. Install hyprpaper or swaybg to also change the desktop picture outside the hyprk shell.";
            else if (c !== 0 && c !== 127) note = "The wallpaper was saved but could not be applied right now.";
        });
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
    Item {
        width: parent.width
        height: 193 - 64 + 21.5          // to the divider (window y 193; the pane starts at 64), then to the first heading
        Rectangle { // preview, 160 x 100
            x: -4; y: 4; width: 160; height: 100; radius: 5
            color: Theme.controlFill
            RoundedImage { anchors.fill: parent; radius: 5; decodeWidth: 320; path: pane.current; generation: pane.thumbGen }
        }
        Card {
            x: 166; y: 4; width: 306
            FormRow {
                label: pane.currentTile ? pane.currentTile.name : pane.current ? P.prettyFileName(pane.current) : "No wallpaper selected"
                LocalPopup { model: ["Fill Screen", "Fit to Screen", "Stretch to Fill Screen", "Centre Image", "Tile"] }
            }
            FormRow { label: "Show on all Spaces"; LocalSwitch { checked: false } }
        }
        Row {
            x: 472 - width; y: 89            // window y 153, right edge 724
            spacing: 8.5
            Button { text: "Screen Saver…" }
            Button { text: "Clock Appearance…" }
        }
        Rectangle {
            x: -Theme.content.padding; y: 193 - 64
            width: parent.width + 2 * Theme.content.padding; height: 1
            color: Theme.dark ? "#343539" : "#E6E6E6"
        }
    }

    InlineNote {
        visible: text !== ""
        text: pane.ready > 0 && pane.files.length === 0
            ? "No wallpapers found yet. Pictures placed in themes/wallpapers appear here."
            : pane.note
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
                            MacText {
                                width: 107.5; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                                text: tile.modelData.name
                            }
                        }
                    }
                }
            }
        }
    }
    Item { width: 1; height: 20 }
}
