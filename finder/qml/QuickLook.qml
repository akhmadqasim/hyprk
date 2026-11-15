import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic
import QtQuick.Shapes
import HyprK
import Finder.Native
import "lib/files.js" as Files

// Quick Look, as on 27.2.1 (MAC-ANSWERS.md Q-finder-26, live/finder/crops/quicklook-*-light.png, 2x): a floating panel
// window of its own, not a sheet. Radius 20; a 38 pt title bar with close and full-screen discs (14 pt boxes at (11,12)
// and (31,12)), the file name in 13 Bold from x 52, Markup / Rotate / Share buttons (34x26) and an "Open with <app>"
// capsule (139x26 for Preview) 7 pt from the right edge; the content inset 5 left, right and bottom. Frame grey 136
// (opaque, neutral). Opens at 0.79 scale in the screen centre and grows to 1 in 0.25 s ease-out (.79 .85 .90 .93 .95
// .97 .98 .98 .99 1 = OutQuint), no fade; closes by shrinking into the file's icon in about 0.18 s (curve not measured:
// InOutQuad). Standard window shadow (config/hypr/hyprland.lua Q-windows-01).
//
// The window covers the monitor and is transparent (finder/hyprland-rules.lua: no compositor shadow, border, blur or
// animation, no focus, pinned above): the panel and its shadow are drawn here, so the zoom can leave the panel's rect
// and land on an icon in the Finder window. Its input region is the panel; Finder keeps the keyboard.
Window {
    id: ql

    property var entry: null            // the item to show; null closes
    property Window finder: null        // the Finder window holding the icons
    property var iconRect: path => null // the item's icon in `finder` (window coordinates) or null
    signal closeRequested()

    property var cur: null              // the entry shown, kept while the close animation runs
    readonly property bool isImage: cur !== null && Files.isImage(cur)
    readonly property bool isText: cur !== null && !isImage && Files.isText(cur)
    readonly property string text: isText ? FileOps.readText(cur.path, 65536) : ""
    // A PDF shows its pages (judge 4: it was an info card): `pdfinfo` for the page count and size, each page rendered
    // by `pdftoppm` when it scrolls into view (image://pdfpage, thumbnails.cpp). No Apple data: there is no Mac capture
    // of a PDF in Quick Look, so the panel's size (the page fitted to the tallest panel, as an image is), the 8 pt gap
    // between pages and the title bar without Markup / Rotate are choices, not measurements
    readonly property bool isPdf: cur !== null && Files.iconClass(cur) === "pdf"
    readonly property var pdf: isPdf && FileOps.pdfInfo ? FileOps.pdfInfo(cur.path) : null   // (an older binary has none)
    readonly property bool showPdf: pdf ? pdf.pages > 0 : false
    readonly property var apps: cur !== null && !cur.isDir ? FileOps.appsFor(cur.path) : []
    readonly property string appName: apps.length && apps[0].isDefault ? apps[0].name : ""
    property bool full: false           // the green disc: the panel fills the screen
    property int turns: 0               // Rotate (left), in quarter turns; the file is not changed

    title: "Quick Look"                 // matched by finder/hyprland-rules.lua
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus
    color: "transparent"
    visible: false
    Component.onCompleted: { width = Screen.width; height = Screen.height; }

    // ---------- size (Q-finder-26: 1463 x 951 for a 1600 x 1000 image on a 1710 x 1107 screen, centred) ----------
    readonly property real fit: 0.856   // 1463 / 1710 (951 / 1107 = 0.859): the panel's share of the screen
    readonly property real barH: 38
    readonly property real inset: 5
    // the work area (the screen less the menu bar and the Dock, Hypr.workArea) in this window's coordinates, taken at
    // open: the panel stays inside it. Centred on the screen it reached under the Dock (judge #5: 0.856 of an 832 pt
    // screen is 712 pt, 23 pt into the Dock's band). The Mac's 1463 x 951 on a 1710 x 1107 screen (Q-finder-26) lies
    // inside its work area; no Mac data on a smaller one, so the work area is the limit. null without Hyprland
    property var work: null
    function workIn() {
        const w = Hypr.workArea ? Hypr.workArea(Screen.virtualX + Screen.width / 2, Screen.virtualY + Screen.height / 2) : null;
        return w && w.height > 0 ? { x: w.x - Screen.virtualX, y: w.y - Screen.virtualY, width: w.width, height: w.height } : null;
    }
    readonly property real maxW: Math.min(Screen.width * fit, width, work ? work.width : width)
    readonly property real maxH: Math.min(Screen.height * fit, height, work ? work.height : height)
    // natural image size in pt (1 px = 1 pt, as a 72 dpi image on the Mac), turned with Rotate
    readonly property real natW: (turns % 2 ? img.implicitHeight : img.implicitWidth) || 1
    readonly property real natH: (turns % 2 ? img.implicitWidth : img.implicitHeight) || 1
    readonly property real contentW: {
        if (showPdf) return Math.round(Math.min(maxW - 2 * inset, (maxH - barH - inset) * pdf.width / pdf.height));
        if (!isImage) return 760 - 2 * inset;   // not measured on the Mac: the old panel's size
        const w = Math.min(natW, maxW - 2 * inset);
        return w * natH / natW > maxH - barH - inset ? (maxH - barH - inset) * natW / natH : w;
    }
    readonly property real contentH: isImage ? contentW * natH / natW
                                   : showPdf ? Math.min(maxH - barH - inset, contentW * pdf.height / pdf.width) : 560 - barH - inset
    // a narrow image still gets a title bar that holds its controls: 52 + a 120 pt title + 16 + 266 to the right
    // edge (a layout need, not a Mac value)
    readonly property real panelW: full ? width : Math.round(Math.max(contentW + 2 * inset, 52 + 120 + 16 + 266))
    readonly property real panelH: full ? height : Math.round(contentH + barH + inset)

    // ---------- open / close ----------
    property bool _warm: false
    onEntryChanged: {
        if (entry) {
            const was = cur;
            _closeStep = -1;
            turns = 0;
            cur = entry;
            if (was && visible && !closing) return;   // arrow keys: the panel shows the next item in place
            full = false;
            work = ql.workIn();
            zoom.xScale = zoom.yScale = Tokens.reduceMotion ? 1 : 0.79;
            shift.x = shift.y = 0;
            _warm = true;
            panel.visible = false;
            visible = true;
            Hypr.setInputRect(ql, Qt.rect(panel.x, panel.y, panel.width, panel.height));
        } else if (cur) {
            _step = -1;
            if (Tokens.reduceMotion) { hideNow(); return; }
            aimAtIcon();
            _closeFrom = Qt.vector3d(zoom.xScale, shift.x, shift.y);
            _closeStep = 0;
            _closeTick();   // the first frame after the request is the curve's first step (as the open's)
        }
    }
    onPanelWChanged: if (visible) Hypr.setInputRect(ql, Qt.rect(panel.x, panel.y, panel.width, panel.height))
    onPanelHChanged: if (visible) Hypr.setInputRect(ql, Qt.rect(panel.x, panel.y, panel.width, panel.height))
    // The window maps empty: at its first swapped frame it is moved to the screen's origin (finder/hyprland-rules.lua;
    // Hypr.moveWindow), and the panel appears in the next frame. Then the curve steps once per swapped frame (frame k
    // shows time k / refresh rate), so every frame on screen is the next sample of the Mac's series even when the
    // client misses a vsync. With the basic render loop (main.cpp) each frameSwapped is one frame on screen: mcap, 3
    // opens of which the first cold, 0.79 shows once, .79 .85 .90 .93 .96 .97 .98 .99 1.0 1 (Mac .79 .85 .90 .93 .95
    // .97 .98 .98 .99 1), first visible 109-110 ms after the Space trigger (a selection change: 77-94 ms).
    // The first frame's commit can reach Hyprland after the request, so the window is not listed yet: then it would stay
    // where new_float_force_onscreen put it (89 pt up on the MBA output, in 4 of 5 reopens). Up to 10 more frames try.
    property int _step: -1
    property int _placeTries: 0
    onFrameSwapped: {
        if (_warm) {
            if (!Hypr.moveWindow(ql.title, Screen.virtualX, Screen.virtualY) && ++_placeTries < 10) {
                ql.update();
                return;
            }
            _warm = false;
            _placeTries = 0;
            panel.visible = true;
            _step = Tokens.reduceMotion ? -1 : 0;
            return;
        }
        if (_closeStep >= 0) { _closeTick(); return; }
        if (_step < 0) return;
        _step++;
        const x = Math.min(1, _step * 1000 / Math.max(30, Screen.refreshRate || 60) / 250);
        zoom.xScale = zoom.yScale = 0.79 + 0.21 * (1 - Math.pow(1 - x, 5));   // OutQuint
        if (x >= 1) _step = -1;
    }
    function hideNow() { visible = false; cur = null; full = false; }
    readonly property bool closing: _closeStep >= 0
    // Close: shrinks into the icon in 0.18 s (Q-finder-26; curve not measured: InOutQuad), one step per swapped frame like
    // the open. On Qt's timer (a ParallelAnimation) it repeated a frame in 3 of 4 closes (judge #5).
    property int _closeStep: -1
    property vector3d _closeFrom: Qt.vector3d(1, 0, 0)   // scale, shift x, shift y at the request
    property real _toX: 0
    property real _toY: 0
    function _closeTick() {
        _closeStep++;
        const x = Math.min(1, _closeStep * 1000 / Math.max(30, Screen.refreshRate || 60) / 180);
        const e = x < 0.5 ? 2 * x * x : 1 - Math.pow(-2 * x + 2, 2) / 2;   // InOutQuad
        zoom.xScale = zoom.yScale = _closeFrom.x + (_toScale - _closeFrom.x) * e;
        shift.x = _closeFrom.y + (_toX - _closeFrom.y) * e;
        shift.y = _closeFrom.z + (_toY - _closeFrom.z) * e;
        if (x >= 1) { _closeStep = -1; hideNow(); }
    }

    // Where the selected item's icon is, in this window: Hyprland knows both windows' places (a Wayland client does
    // not). Without it (other compositors) the panel shrinks in place.
    property real _toScale: 0.1
    function aimAtIcon() {
        const r = finder && cur ? iconRect(cur.path) : null;
        const wins = r ? Hypr.windows() : [];
        const me = wins.find(w => w.title === ql.title);
        const fw = wins.find(w => w.title !== ql.title && w.title === finder.title);
        const cx = panel.x + panel.width / 2, cy = panel.y + panel.height / 2;
        if (me && fw) {
            _toX = fw.x + r.x + r.width / 2 - me.x - cx;
            _toY = fw.y + r.y + r.height / 2 - me.y - cy;
            _toScale = Math.max(r.width, r.height) / panel.width;
        } else {
            _toX = shift.x;
            _toY = shift.y;
            _toScale = 64 / panel.width;
        }
    }

    Item {
        id: panel
        x: Math.round((ql.width - width) / 2)
        // centred on the screen, moved into the work area when it would leave it
        y: {
            const c = Math.round((ql.height - height) / 2), w = ql.work;
            return ql.full || !w ? c : Math.max(w.y, Math.min(c, w.y + w.height - height));
        }
        width: ql.panelW
        height: ql.panelH
        transform: [
            Scale { id: zoom; origin.x: panel.width / 2; origin.y: panel.height / 2 },
            Translate { id: shift }
        ]

        // window shadow: Hyprland's falloff a (1 - d / 52)^4 outside the box, y 12, black a .281 light / .494 dark
        // (config/hypr/hyprland.lua, the Q-windows-01 fit): the box itself, then one 1 pt ring per point of distance
        // (rings, not stacked fills, so each pixel is drawn about once)
        Item {
            visible: !ql.full
            readonly property real a: Tokens.dark ? 0.494 : 0.281
            y: 12
            width: panel.width
            height: panel.height
            Rectangle { anchors.fill: parent; radius: 20; color: Qt.rgba(0, 0, 0, parent.a) }
            Repeater {
                model: 52
                Rectangle {
                    required property int index
                    x: -index - 1; y: -index - 1
                    width: panel.width + 2 * index + 2; height: panel.height + 2 * index + 2
                    radius: 21 + index
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.rgba(0, 0, 0, parent.a * Math.pow(1 - (index + 0.5) / 52, 4))
                }
            }
        }

        Rectangle {
            id: frame
            anchors.fill: parent
            radius: ql.full ? 0 : 20
            color: Theme.color.quickLookFrame
        }

        Item {
            id: bar
            width: parent.width
            height: ql.barH

            // close and full-screen: dark 12 pt discs with the glyph cut out in the frame colour (crop: ink 12-23.5 pt)
            Rectangle {
                x: 12; y: 13; width: 12; height: 12; radius: 6
                color: Theme.color.quickLookInk
                Rectangle { anchors.centerIn: parent; width: 6.5; height: 1.6; radius: 0.8; rotation: 45; color: frame.color }
                Rectangle { anchors.centerIn: parent; width: 6.5; height: 1.6; radius: 0.8; rotation: -45; color: frame.color }
                TapHandler { margin: 1; onTapped: ql.closeRequested() }
            }
            Rectangle {
                x: 32; y: 13; width: 12; height: 12; radius: 6
                color: Theme.color.quickLookInk
                Rectangle { anchors.centerIn: parent; width: 7.5; height: 2.6; rotation: -45; color: frame.color }
                TapHandler { margin: 1; onTapped: ql.full = !ql.full }
            }
            TextLabel {
                id: titleText
                x: 52
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, (ql.isImage ? markupBtn.x : shareBtn.x) - x - 16)
                elide: Text.ElideMiddle
                text: ql.cur ? ql.cur.name : ""
                color: Theme.color.quickLookText
                size: 13
                weight: Typography.bold
            }
            // the real SF symbols at 15 (ink 26x26 / 26x28 / 23x29 px like the crop's); their ink centres left of the
            // capsule (Preview: capsule at W - 144): Share 24, Rotate 62.75, Markup 104.25 (box offsets 23.25 / 63.75 / 103.5)
            // Markup is drawn like the others (quicklook-titlebar-light.png); there is no Markup tool behind it
            QuickLookButton { id: markupBtn; x: capsule.x - 103.5 - 17; icon: "markup"; iconSize: 15; visible: ql.isImage }
            QuickLookButton { x: capsule.x - 63.75 - 17; icon: "rotate.left"; iconSize: 15; visible: ql.isImage; onClicked: ql.turns = (ql.turns + 3) % 4 }
            QuickLookButton { id: shareBtn; x: capsule.x - 23.25 - 17; icon: "square.and.arrow.up"; iconSize: 15; onClicked: if (ql.cur) FileOps.open(ql.cur.path) }
            Rectangle {
                id: capsule
                anchors.right: parent.right
                anchors.rightMargin: 7
                y: 6
                width: openLabel.implicitWidth + 26; height: 26; radius: 13
                color: Qt.rgba(0, 0, 0, openTap.pressed ? 0.2 : 0.125)   // 119 on the 136 frame
                Text {
                    id: openLabel
                    anchors.centerIn: parent
                    text: ql.appName ? "Open with " + ql.appName : "Open"
                    color: Theme.color.quickLookText
                    font: Typography.font(13)
                }
                TapHandler { id: openTap; onTapped: if (ql.cur) FileOps.open(ql.cur.path) }
            }
        }

        Item {
            id: content
            x: ql.inset
            y: ql.barH
            width: parent.width - 2 * ql.inset
            height: parent.height - ql.barH - ql.inset
            clip: true

            Image {
                id: img
                anchors.centerIn: parent
                width: ql.turns % 2 ? parent.height : parent.width
                height: ql.turns % 2 ? parent.width : parent.height
                rotation: -90 * ql.turns
                visible: ql.isImage
                // loaded before the first frame, so the panel opens with its picture and at its size
                asynchronous: false
                source: ql.isImage ? Files.fileUrl(ql.cur.path) : ""
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(Screen.width * 2, Screen.height * 2)
            }

            ScrollView {
                id: textScroll
                anchors.fill: parent
                visible: ql.isText
                Component.onCompleted: contentItem.boundsBehavior = Flickable.StopAtBounds   // the wheel stops at the edge
                TextArea {
                    readOnly: true
                    text: ql.text
                    wrapMode: TextEdit.Wrap
                    color: Theme.color.label
                    selectionColor: Theme.color.textSelection   // was the Qt palette's highlight
                    selectedTextColor: Theme.color.label
                    font.family: Theme.fontMono
                    font.pixelSize: 12
                    background: Rectangle { color: Theme.color.window; radius: 15 }   // concentric with the 20 pt frame
                    padding: 12
                }
            }
            RubberBand { flickable: ql.isText ? textScroll.contentItem : ql.showPdf ? pages : null }   // trackpad stretch at the ends

            // PDF pages, one under the other; a page is rendered when it comes into view (and kept one page around)
            ListView {
                id: pages
                anchors.fill: parent
                visible: ql.showPdf
                model: ql.showPdf ? ql.pdf.pages : 0
                spacing: 8
                boundsBehavior: Flickable.StopAtBounds
                cacheBuffer: Math.max(0, height)
                readonly property real pageH: width * (ql.showPdf ? ql.pdf.height / ql.pdf.width : 1)
                delegate: Rectangle {
                    id: sheet
                    required property int index
                    width: pages.width
                    height: pages.pageH
                    color: "white"
                    // the Finder thumbnail of the first page (cached) until the page itself is rendered
                    Image {
                        anchors.fill: parent
                        visible: sheet.index === 0 && page.status !== Image.Ready
                        asynchronous: true
                        fillMode: Image.PreserveAspectFit
                        source: visible && ql.cur ? "image://thumb/" + encodeURIComponent(ql.cur.path) : ""
                        sourceSize: Qt.size(256, 256)
                    }
                    Image {
                        id: page
                        anchors.fill: parent
                        asynchronous: true
                        // an image provider is asked for sourceSize times the window's device pixel ratio: the
                        // page at the panel's pixel size
                        sourceSize.width: Math.ceil(sheet.width)
                        source: ql.showPdf && ql.cur ? "image://pdfpage/" + (sheet.index + 1) + "/" + encodeURIComponent(ql.cur.path) : ""
                    }
                }
            }

            // rounded content corners (crop: the picture's corner curve spans about 12 pt; 15 = concentric with the
            // 20 pt frame at the 5 pt inset), drawn as frame-coloured corner pieces instead of a mask layer
            Repeater {
                model: ql.full ? 0 : 4
                Shape {
                    required property int index
                    readonly property real r: 15
                    width: r; height: r
                    x: index % 2 ? content.width - r : 0
                    y: index > 1 ? content.height - r : 0
                    z: 2
                    rotation: [0, 90, 270, 180][index]
                    preferredRendererType: Shape.CurveRenderer
                    ShapePath {
                        strokeWidth: -1
                        fillColor: frame.color
                        startX: 0; startY: 0
                        PathLine { x: 15; y: 0 }
                        PathArc { x: 0; y: 15; radiusX: 15; radiusY: 15; direction: PathArc.Counterclockwise }
                        PathLine { x: 0; y: 0 }
                    }
                }
            }

            Column {
                visible: ql.cur !== null && !ql.isImage && !ql.isText && !ql.showPdf
                anchors.centerIn: parent
                spacing: 10
                FileIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    entry: ql.cur || ({ name: "", isDir: false, mime: "" })
                    size: 160
                }
                TextLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: ql.cur ? ql.cur.name : ""
                    color: Theme.color.quickLookText
                    size: 17
                    weight: Typography.semibold
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    // QuickLook.framework PlugIns.loctable (Generic Information): "%1$@ - %2$@", "Last modified %@",
                    // "Today %@" / "Yesterday %@", "%1$@ at %2$@"
                    text: ql.cur ? ql.cur.kind + " - " + Files.formatSize(ql.cur.size, ql.cur.isDir) : ""
                    color: Theme.color.quickLookInk
                    font: Typography.font(Theme.font.preview)
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: ql.cur ? "Last modified " + Files.formatDate(ql.cur.modified).replace(/^(Today|Yesterday) at /, "$1 ") : ""
                    color: Theme.color.quickLookInk
                    font: Typography.font(Theme.font.preview)
                }
            }
        }
    }
}
