import QtQuick
import Qt.labs.folderlistmodel
import ".."
import "../controls"
import "../Parsers.js" as P

// Functional: picks from themes/wallpapers, records state/wallpaper.json
// (the shell reads it) and applies with hyprpaper or swaybg when present.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    readonly property string dir: Backend.root + "/themes/wallpapers"
    readonly property string current: AppState.wallpaper
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
    property int thumbGen: 0     // bumps when thumbnails were created, to reload the grid
    Timer { id: thumbTimer; interval: 300; onTriggered: Backend.makeThumbs(pane.files, c => { if (c === 0) pane.thumbGen++; }) }
    component Walls: FolderListModel {
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Name
        onStatusChanged: if (status === FolderListModel.Ready) { pane.ready++; Qt.callLater(pane.collect); }
    }
    Walls { id: w0; folder: "file://" + pane.dir }
    Walls { id: w1; folder: "file://" + pane.dir + "/png" }

    // Current wallpaper preview row, like the macOS header
    Card {
        FormRow {
            implicitHeight: 96
            label: pane.current ? P.prettyFileName(pane.current) : "No wallpaper selected"
            sublabel: "Show on all Spaces"
            Rectangle {
                width: 128; height: 72; radius: 8; clip: true
                color: Theme.controlFill
                RoundedImage { anchors.fill: parent; radius: 8; decodeWidth: 256; path: pane.current }
            }
        }
        FormRow { label: "Show as screen saver"; MacSwitch { checked: true } }
    }

    InlineNote {
        text: pane.ready > 0 && pane.files.length === 0
            ? "No wallpapers found yet. Pictures placed in themes/wallpapers appear here."
            : pane.note
    }

    Column {
        width: parent.width
        spacing: Theme.content.headerGap
        visible: pane.files.length > 0
        SectionHeader { text: "Wallpapers"; topPadding: 0 }
        Grid {
            id: grid
            width: parent.width
            columns: 4
            spacing: 10
            readonly property real cellW: (width - (columns - 1) * spacing) / columns
            Repeater {
                model: pane.files
                Rectangle {
                    required property string modelData
                    readonly property string filePath: modelData
                    width: grid.cellW; height: Math.round(width * 0.62); radius: 8
                    color: Theme.controlFill
                    border.width: pane.current === filePath ? 3 : 0
                    border.color: Theme.accent
                    RoundedImage {
                        anchors.fill: parent; anchors.margins: parent.border.width
                        radius: 8 - parent.border.width
                        path: parent.filePath
                        generation: pane.thumbGen
                    }
                    MouseArea { anchors.fill: parent; onClicked: pane.apply(parent.filePath) }
                }
            }
        }
    }

    PaneFooter { MacButton { text: "Add Folder…" } }
}
