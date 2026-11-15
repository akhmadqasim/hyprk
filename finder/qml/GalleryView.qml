import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import Finder.Native
import HyprK
import "lib/files.js" as Files

// Gallery view, 27.2.1 (reference/re/MAC-ANSWERS-9.md R9.1-R9.4; stills screens/27.2.1/finder/gallery, AX
// re/27.2.1/live/finder/gallery). The gallery area is the view less the 240 pt inspector; the path bar runs under the
// area only, the inspector goes down to the window's foot. In the area: the focused item's preview in a frame inset
// 32 pt left / right / top (aspect fit, centred, 6 pt corners, a 0.5 pt black / white .10 hairline), 32 pt under it
// the strip of 48 pt thumbs at a 59 pt pitch, 5 pt from the area's left and bottom edges and left-aligned. The
// selected thumb sits on a flat 54 pt plate, r 7, no glass (R9.3). Keys move the plate in one frame and the preview
// cuts over with no fade (retainWhileLoading: the old picture stays until the new one is decoded, never a blank
// frame); the strip jumps by the least amount that keeps the plate 8 pt inside (Files.galleryScroll).
// View > Hide Preview drops the inspector and its bar; the area takes the full width (R9.4).
Item {
    id: root

    required property var browser
    property bool showPreview: true
    property real bottomInset: 0          // the path bar under the area
    signal contextMenu(var entry, point pos)
    signal tagRequested(Item anchor)
    readonly property int columns: 1

    function ensureVisible(i) { strip.reveal(i); }

    // The Mac's gallery opens on a folder with its first item selected (plate, preview and path bar on Alpine.jpg,
    // judge #22): on load, on a folder change, and once an async listing arrives, when nothing is selected yet.
    // A selection made before (Main's --select, Up's folder) is kept
    function selectFirst() {
        if (browser.selectedCount === 0 && browser.cursor < 0 && browser.entries.length > 0)
            browser.click(0, Qt.NoModifier);
    }
    Component.onCompleted: selectFirst()
    Connections {
        target: root.browser
        function onEntriesChanged() { Qt.callLater(root.selectFirst); }
    }
    function iconItem(i) { const t = strip.itemAtIndex(i); return t ? t.iconItem : null; }

    readonly property var focused: {
        const i = browser.cursor >= 0 ? browser.cursor : 0;
        return browser.entries.length > i ? browser.entries[i] : null;
    }
    readonly property var none: ({ name: "", isDir: false, mime: "" })

    readonly property real areaWidth: showPreview ? width - Theme.gallery.paneWidth : width
    readonly property real areaHeight: height - bottomInset

    readonly property bool focusImage: focused !== null && Files.isImage(focused)
    readonly property bool focusPdf: focused !== null && !focused.isDir && Files.iconClass(focused) === "pdf"
    readonly property bool focusText: focused !== null && !focusImage && Files.isText(focused)
    readonly property var pdf: focusPdf && FileOps.pdfInfo ? FileOps.pdfInfo(focused.path) : null
    readonly property bool showPdf: pdf ? pdf.pages > 0 : false
    readonly property size pixels: focusImage && FileOps.imageSize ? FileOps.imageSize(focused.path) : Qt.size(-1, -1)

    // The gallery area's content, the preview and the strip, as one item: drawn sharp inside the area (this clip), and
    // captured whole, the strip's run under the inspector included, for the inspector's material (paneGlass)
    Item {
        width: root.areaWidth
        height: root.areaHeight
        clip: true
    Item {
        id: content
        width: root.width
        height: root.areaHeight

    // ---------- preview frame ----------
    Item {
        id: stage
        x: Theme.gallery.pad
        y: Theme.gallery.pad
        width: Math.max(0, root.areaWidth - 2 * Theme.gallery.pad)
        height: Math.max(0, root.areaHeight - Theme.gallery.stripInset - Theme.gallery.plate - 2 * Theme.gallery.pad)

        // what is shown, aspect-fitted and centred (AX: Alpine 1600x1067 -> 537x358 at y +69 in the 497 frame);
        // whole points so the corners and the hairline sit on the picture's edge
        readonly property real aspect: root.focusImage ? (root.pixels.width > 0 ? root.pixels.width / root.pixels.height
                                                          : picture.implicitHeight > 0 ? picture.implicitWidth / picture.implicitHeight : 0)
                                     : root.showPdf ? root.pdf.width / root.pdf.height
                                     : root.focusText && height > 0 ? width / height : 0
        Item {
            id: fit
            visible: stage.aspect > 0
            width: visible ? Math.round(Math.min(stage.width, stage.height * stage.aspect)) : 0
            height: visible ? Math.round(width / stage.aspect) : 0
            x: Math.floor((stage.width - width) / 2)
            y: Math.floor((stage.height - height) / 2)

            Image {
                id: picture
                anchors.fill: parent
                visible: root.focusImage
                source: visible ? Files.fileUrl(root.focused.path) : ""
                fillMode: Image.Stretch      // the box already has the picture's aspect (to the rounded point)
                asynchronous: true
                retainWhileLoading: true
                sourceSize: Qt.size(stage.width * 2, stage.height * 2)
            }

            // a PDF's first page on white (the cached thumbnail until the page is rendered)
            Rectangle {
                anchors.fill: parent
                visible: root.showPdf
                color: "white"
                Image {
                    anchors.fill: parent
                    visible: pageImage.status !== Image.Ready
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    source: root.showPdf ? "image://thumb/" + encodeURIComponent(root.focused.path) : ""
                    sourceSize: Qt.size(256, 256)
                }
                Image {
                    id: pageImage
                    anchors.fill: parent
                    asynchronous: true
                    retainWhileLoading: true
                    sourceSize.width: Math.ceil(fit.width)   // the provider multiplies by the device pixel ratio
                    source: root.showPdf ? "image://pdfpage/1/" + encodeURIComponent(root.focused.path) : ""
                }
            }

            // a text file: the whole frame is the text view, Menlo 11 on a 13 pt line (R9.2 fonts)
            Flickable {
                id: textView
                visible: root.focusText
                anchors.fill: parent
                clip: true
                contentHeight: textBody.height
                boundsBehavior: Flickable.StopAtBounds
                Text {
                    id: textBody
                    width: textView.width
                    leftPadding: 8
                    rightPadding: 8
                    topPadding: 3
                    bottomPadding: 3
                    text: textView.visible ? FileOps.readText(root.focused.path, 65536) : ""
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    color: Theme.color.label
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 13
                }
            }

            // 6 pt corners: window-coloured corner pieces (no mask layer), then the 0.5 pt hairline. px on the
            // stills: image 119 -> 107 at the edge in light (black .10), -> 132 in dark (white .10); pdf and text
            // frames the same (230 on white, (52,53,57) on (30,31,36))
            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                readonly property real r: Theme.gallery.previewRadius
                readonly property real w: fit.width
                readonly property real h: fit.height
                ShapePath {
                    strokeWidth: -1
                    fillColor: Theme.color.window
                    fillRule: ShapePath.OddEvenFill
                    // the outer box, then the rounded rectangle cut out of it
                    PathRectangle { x: 0; y: 0; width: fit.width; height: fit.height }
                    PathRectangle { x: 0; y: 0; width: fit.width; height: fit.height; radius: Theme.gallery.previewRadius }
                }
            }
            Rectangle {
                anchors.fill: parent
                radius: Theme.gallery.previewRadius
                color: "transparent"
                border.width: Pixel.stroke(0.5, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
                border.color: Theme.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.10)
            }
        }

        // folders and everything else: the icon. Fitted to two stills (generic folder, blue ink 429 x 345 pt in the
        // 537 x 497 frame at 1000x700, 469 x 377 in 937 x 697 at 1400x900): this art at 0.944 of the frame height,
        // at most 512 pt; the Mac's own rule is not known
        FileIcon {
            visible: root.focused !== null && !root.focusImage && !root.showPdf && !root.focusText
            anchors.centerIn: parent
            entry: root.focused || root.none
            size: Math.max(16, Math.min(parent.width, parent.height * 0.944, 512))
        }

        EntryMouseArea {
            anchors.fill: parent
            browser: root.browser
            entry: root.focused
            index: Math.max(0, root.browser.cursor)
            onContextMenu: (e, pos) => root.contextMenu(e, pos)
        }
    }

    // ---------- thumbnail strip ----------
    // The strip runs on under the inspector (R9.3, R11.1): the ListView spans the view, drawn sharp over the gallery
    // area only (the clip above); what is under the inspector shows through its material (paneGlass). The scroll
    // range is the area's: the last thumb ends 5 pt inside the area (AX at 715: content 477 in 316)
    ListView {
        id: strip
        objectName: "galleryStrip"
        x: 0
        y: root.areaHeight - Theme.gallery.stripInset - height
        width: root.width
        height: Theme.gallery.plate
        orientation: ListView.Horizontal
        clip: true
        spacing: Theme.gallery.pitch - Theme.gallery.plate
        leftMargin: Theme.gallery.stripInset
        rightMargin: Theme.gallery.stripInset + root.width - root.areaWidth
        model: root.browser.entries
        boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
        RubberBand { flickable: strip }
        currentIndex: root.browser.cursor
        highlightFollowsCurrentItem: false
        onCurrentIndexChanged: if (currentIndex >= 0) reveal(currentIndex)

        readonly property real minX: originX - leftMargin
        readonly property real maxX: Math.max(minX, originX + contentWidth + rightMargin - width)
        function scrollBy(d) { contentX = Math.max(minX, Math.min(maxX, contentX + d)); }

        // R9.3: one-frame jump, no animated scroll
        function reveal(i) {
            if (i < 0 || i >= count) return;
            contentX = Files.galleryScroll(contentX - originX, i, root.areaWidth, -leftMargin,
                                           contentWidth + rightMargin - width, Theme.gallery.pitch,
                                           Theme.gallery.plate, Theme.gallery.scrollMargin) + originX;
        }

        delegate: Item {
            id: thumb
            required property var modelData
            required property int index
            readonly property bool selected: root.browser.isSelected(modelData.path)
            width: Theme.gallery.plate
            height: Theme.gallery.plate
            Rectangle {
                anchors.fill: parent
                radius: Theme.gallery.plateRadius
                visible: thumb.selected
                color: Theme.color.galleryPlate
            }
            readonly property Item iconItem: thumbIcon
            FileIcon {
                id: thumbIcon
                anchors.centerIn: parent
                entry: thumb.modelData
                size: Theme.gallery.thumb
                // R9.1 (gallery-1000x700-first-jpg-*): a thumbnail fills the 48 pt square (Bloom.png 96 px at 2x)
                // with its hairline and no shadow
                thumbScale: 1
                thumbShadow: false
            }
            EntryMouseArea {
                anchors.fill: parent
                browser: root.browser
                entry: thumb.modelData
                index: thumb.index
                onContextMenu: (e, pos) => root.contextMenu(e, pos)
            }
        }
    }
    }
    }
    // Mouse wheel (R11.2, wheel-notch-timing.txt, line events): a vertical notch does not scroll the strip, over the
    // strip or over the preview (it does not change the selection either); a horizontal notch, or Shift + a vertical
    // one, moves the strip 10 pt, in one frame with no animation, in both places, and stops at the ends. Over
    // everything in the area so the strip's own Flickable never sees a notch (it would animate, and by its own step).
    // A trackpad (a scroll phase) goes on to the views; so does a vertical notch over a text preview, which scrolls
    // its text here (the Mac's notch over a text preview was not captured)
    MouseArea {
        width: root.areaWidth
        height: root.areaHeight
        acceptedButtons: Qt.NoButton
        onWheel: w => {
            if (w.phase !== Qt.NoScrollPhase) { w.accepted = false; return; }
            const shift = (w.modifiers & Qt.ShiftModifier) && w.angleDelta.x === 0;
            const d = shift ? w.angleDelta.y : w.angleDelta.x;
            if (d !== 0) { strip.scrollBy(-d / 120 * Theme.gallery.wheelStep); return; }
            const p = mapToItem(textView, w.x, w.y);
            w.accepted = !(textView.visible && textView.contentHeight > textView.height && textView.contains(p));
        }
    }

    // ---------- inspector (previewPaneScrollView, 240 pt) ----------
    // Frames from ax-1000x700-*.jsonl, relative to the column: icon 9,19 50x50; name x 68, centre 34.5; kind x 67,
    // centre 55.5; Information centre 96, rows from 109 at a 23 pt pitch, text from x 9 to 231; Tags 20 pt under the
    // last row; the tag field 13 pt under the Tags centre, 222 x 35.
    Rectangle {
        id: pane
        visible: root.showPreview
        x: root.width - width
        width: Theme.gallery.paneWidth
        height: root.height
        color: Theme.blur ? Theme.color.sidebarGlass : Theme.color.galleryPane
        // The column's material (R11.1, R11.3; shaders/inspector.frag): the gallery content behind and beside the
        // column shows as two blurred, saturated copies over the plain colour, sigma 10 pt (R11.3's own estimate is
        // 10-12 pt) and 80 pt. So of the strip under the column no thumb edge is left, only a glow that reaches
        // some 40 pt up, and the big preview tints the column's left side. It ends at the quick-action bar: the bar
        // is the opaque window background and hides the strip from 14 pt under the thumbs' top edge (R11.1).
        // Blurred in points (the textures are 1 texel per 2 pt and per 16 pt), so it is the same at any scale
        Item {
            id: paneGlass
            objectName: "galleryPaneGlass"
            visible: root.showPreview && !Tokens.reduceTransparency
            width: parent.width
            height: parent.height - Theme.gallery.barHeight
            readonly property size nearSize: Qt.size(Math.max(1, Math.ceil(root.width / 2)), Math.max(1, Math.ceil(root.height / 2)))
            readonly property size farSize: Qt.size(Math.max(1, Math.ceil(root.width / 16)), Math.max(1, Math.ceil(root.height / 16)))
            readonly property url gauss: Qt.resolvedUrl("shaders/gauss.frag.qsb")
            ShaderEffectSource {
                id: backdrop
                visible: false
                live: paneGlass.visible
                sourceItem: content
                sourceRect: Qt.rect(0, 0, 2 * paneGlass.nearSize.width, 2 * paneGlass.nearSize.height)
                textureSize: paneGlass.nearSize
                smooth: true
            }
            ShaderEffect {
                id: nearH
                visible: false
                width: paneGlass.nearSize.width; height: paneGlass.nearSize.height
                layer.enabled: paneGlass.visible; layer.smooth: true; layer.textureSize: paneGlass.nearSize
                layer.format: ShaderEffectSource.RGBA16F
                fragmentShader: paneGlass.gauss
                property var src: backdrop
                property point dir: Qt.point(1 / width, 0)
                property real sigma: Theme.gallery.paneBlurNear / 2
            }
            ShaderEffect {
                id: nearBlur
                visible: false
                width: nearH.width; height: nearH.height
                layer.enabled: paneGlass.visible; layer.smooth: true; layer.textureSize: paneGlass.nearSize
                layer.format: ShaderEffectSource.RGBA16F
                fragmentShader: paneGlass.gauss
                property var src: nearH
                property point dir: Qt.point(0, 1 / height)
                property real sigma: nearH.sigma
            }
            // the wide copy: the near one at an eighth of its size, blurred by what is missing to sigma 80 pt
            ShaderEffectSource {
                id: nearSmall
                visible: false
                live: paneGlass.visible
                sourceItem: nearBlur
                textureSize: paneGlass.farSize
                format: ShaderEffectSource.RGBA16F
                smooth: true
            }
            ShaderEffect {
                id: farH
                visible: false
                width: paneGlass.farSize.width; height: paneGlass.farSize.height
                layer.enabled: paneGlass.visible; layer.smooth: true; layer.textureSize: paneGlass.farSize
                layer.format: ShaderEffectSource.RGBA16F
                fragmentShader: paneGlass.gauss
                property var src: nearSmall
                property point dir: Qt.point(1 / width, 0)
                property real sigma: Math.sqrt(Theme.gallery.paneBlurFar * Theme.gallery.paneBlurFar
                                               - Theme.gallery.paneBlurNear * Theme.gallery.paneBlurNear) / 16
            }
            ShaderEffect {
                id: farBlur
                visible: false
                width: farH.width; height: farH.height
                layer.enabled: paneGlass.visible; layer.smooth: true; layer.textureSize: paneGlass.farSize
                layer.format: ShaderEffectSource.RGBA16F
                fragmentShader: paneGlass.gauss
                property var src: farH
                property point dir: Qt.point(0, 1 / height)
                property real sigma: farH.sigma
            }
            ShaderEffect {
                anchors.fill: parent
                fragmentShader: Qt.resolvedUrl("shaders/inspector.frag.qsb")
                property var near: nearBlur
                property var far: farBlur
                property size size: Qt.size(width, height)
                property point origin: Qt.point(pane.x, 0)
                property size sceneSize: Qt.size(2 * paneGlass.nearSize.width, 2 * paneGlass.nearSize.height)
                property point nearGain: Theme.gallery.paneNearGain
                property point farGain: Theme.gallery.paneFarGain
                property color windowColor: Theme.color.window
                property color fill: pane.color
            }
        }
        Rectangle { width: Pixel.stroke(0.5, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); height: parent.height; color: Theme.color.separator }

        Item {
            visible: root.focused !== null
            anchors.fill: parent

            FileIcon {
                x: 9
                y: 19
                entry: root.focused || root.none
                size: Theme.gallery.paneIcon
                // R9.1: in the 50 pt previewPaneIcon a thumbnail is 42 pt (Alpine.jpg 84 px wide, Notes.txt 84 px
                // tall at 2x) with its soft shadow; folders and documents are the 50 pt icon (folder ink 46 pt)
                thumbScale: 0.84
            }
            // name: AX gives no font; about 16 pt from the ink (R9.2)
            TextLabel {
                x: 68
                y: 34.5 - height / 2
                width: 231 - x
                elide: Text.ElideMiddle
                text: EmojiText.opaque(root.focused ? root.focused.name : "", color)   // OPEN-FIXES.md 16
                textFormat: EmojiText.has(root.focused ? root.focused.name : "") ? Text.StyledText : Text.PlainText
                size: 16
            }
            // sizeAndKind: SF Regular 13, secondary label
            TextLabel {
                x: 68
                y: 55.5 - height / 2
                width: 231 - x
                elide: Text.ElideRight
                text: root.focused ? root.focused.kind + " - " + Files.formatSize(root.focused.size, root.focused.isDir) : ""
                color: Theme.color.secondaryLabel
                size: Theme.font.preview
            }
            InfoRows {
                id: rows
                x: 10                  // the AXGroup rows, 970 w 220; titles ink from 10, values to 230
                y: 96 - 11
                width: 220
                entry: root.focused
                showMore: Files.galleryShowMore(root.focused)
                dimensions: Files.formatDimensions(root.pixels.width, root.pixels.height)
                titleWeight: Typography.medium
            }
            TextLabel {
                id: tagsTitle
                x: 10
                y: rows.y + rows.height + 20 - height / 2
                text: "Tags"
                size: Theme.font.preview
                weight: Typography.semibold
            }
            // the tag editor (AXTextField "tag editor"): the content background; empty: the "Add Tags…" placeholder
            // in the tertiary label (189 light / (86,86,90) dark on the stills). Tags: each a 14 pt token in its
            // colour (fill 0.27 dark / 0.13 light, dashed rim 0.47 / 0.24) and "Add Tag" in the accent (Q-finder-20)
            Rectangle {
                id: tagField
                x: 9
                y: tagsTitle.y + tagsTitle.height / 2 + 13
                width: 222
                height: 35
                color: Theme.color.window
                readonly property var tags: root.focused && root.focused.tags ? root.focused.tags : []
                TapHandler { onTapped: root.tagRequested(tagField) }
                TextLabel {
                    visible: tagField.tags.length === 0
                    x: 1
                    y: 9.5 - height / 2
                    text: "Add Tags…"
                    color: Theme.color.tertiaryLabel
                    size: Theme.font.preview
                }
                Row {
                    visible: tagField.tags.length > 0
                    x: 1
                    y: 2
                    spacing: 4
                    Repeater {
                        model: tagField.tags
                        Item {
                            id: token
                            required property string modelData
                            readonly property color tag: Theme.color.tagColors[modelData] || Theme.color.secondaryLabel
                            width: tokenText.implicitWidth + 9
                            height: 14
                            Rectangle {
                                anchors.fill: parent
                                radius: 3
                                color: Qt.rgba(token.tag.r, token.tag.g, token.tag.b, Theme.dark ? 0.27 : 0.13)
                            }
                            Canvas {      // the dashed rim (a Rectangle border cannot dash)
                                anchors.fill: parent
                                readonly property color ink: Qt.rgba(token.tag.r, token.tag.g, token.tag.b, Theme.dark ? 0.47 : 0.24)
                                onInkChanged: requestPaint()
                                onPaint: {
                                    const ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    ctx.strokeStyle = ink;
                                    ctx.lineWidth = 1;
                                    ctx.setLineDash([2, 1.5]);
                                    ctx.beginPath();
                                    ctx.roundedRect(0.5, 0.5, width - 1, height - 1, 3, 3);
                                    ctx.stroke();
                                }
                            }
                            TextLabel {
                                id: tokenText
                                anchors.centerIn: parent
                                text: token.modelData
                                size: Theme.font.small
                            }
                        }
                    }
                    Item { width: 2; height: 1 }
                    TextLabel {
                        height: 14
                        verticalAlignment: Text.AlignVCenter
                        text: "Add Tag"
                        color: Theme.color.accent   // the shot's (53,120,246) is a Display P3 reading of #007AFF
                        size: Theme.font.small
                    }
                }
            }
        }

        // quick actions: plain borderless buttons, a 14 pt glyph over an 11 pt label, one grey (R9.3)
        PreviewBar {
            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.gallery.barHeight
            entry: root.focused
            ink: Theme.dark ? Qt.rgba(142 / 255, 143 / 255, 145 / 255, 1) : Qt.rgba(128 / 255, 128 / 255, 128 / 255, 1)
            text: ink
            onMore: pos => { if (root.focused) root.contextMenu(root.focused, pos); }
        }
    }
}
