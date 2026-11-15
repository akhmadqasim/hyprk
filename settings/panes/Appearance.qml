import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P

// Functional: writes mode/dark/accent/glass/icon style to state/appearance.json (read by the shell).
// Layout: macOS 27.2.1 (MAC-ANSWERS.md PC #60 section 1, re/27.2.1/live/settings/appearance/layout.json). Row
// heights below include the 1 pt separator above every row but the first: cards 319, 100, 145.5 (129 with
// Default), 75, 189; headings 30 below a card, 16 tall, 10 above theirs; button row 20 below the last card.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    // Picker tile used by the Appearance mode and icon style rows (MAC-ANSWERS.md Q-settings-26, -27): the
    // content (w x h, radius r), a 3 pt accent ring `gap` outside it when selected, caption 11 pt, bold when selected.
    component Choice: Column {
        id: ch
        property string caption
        property bool selected
        property real w: 67
        property real h: 44
        property real r: 6
        property real gap: 0.5
        default property alias inner: content.data
        signal picked()
        spacing: 2
        Rectangle {
            id: frame
            anchors.horizontalCenter: parent.horizontalCenter
            width: ch.w + 2 * (3 + ch.gap); height: ch.h + 2 * (3 + ch.gap); radius: ch.r + 3 + ch.gap
            border.width: ch.selected ? 3 : 0
            border.color: Tokens.control.accentOn
            color: "transparent"
            Item {
                id: content
                anchors.fill: parent; anchors.margins: 3 + ch.gap
            }
            MouseArea { anchors.fill: parent; z: 10; onClicked: ch.picked() }
        }
        MacText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: ch.caption
            size: 11
            weight: ch.selected ? Typography.bold : Typography.regular
            color: ch.selected ? Theme.label : Theme.secondaryLabel
        }
    }
    component MiniWindow: Item {
        property bool darkWin
        anchors.fill: parent
        // the wallpaper art in each thumbnail (27.2.1 appearance-light.png shows the Mac's wallpaper, darker in Dark);
        // here the user's wallpaper, else the shell's default pair (AppState.desktopPicture)
        Rectangle { // until the wallpaper thumbnail loads (or without one)
            width: 67; height: 44; radius: 6
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "#8DB6F2" }
                GradientStop { position: 1; color: "#3D6BD8" }
            }
        }
        RoundedImage {
            width: 67; height: 44; radius: 6; decodeWidth: 140
            path: AppState.desktopPicture(darkWin)
        }
        // a chosen picture has one look: darkened for the Dark thumbnail (the default is a light / dark pair)
        Rectangle { width: 67; height: 44; radius: 6; visible: darkWin && AppState.wallpaperImage !== ""; color: Qt.rgba(0.02, 0.03, 0.12, 0.55) }
        Rectangle { x: 6; y: 8; width: parent.width - 12; height: 6; radius: 2; color: darkWin ? "#2E57D6" : "#3F7BF0" }
        Rectangle {
            x: parent.width * 0.3; y: parent.height * 0.5; width: parent.width * 0.62; height: parent.height * 0.42; radius: 4
            color: darkWin ? "#1C1C1E" : "#F2F2F4"
            Row {
                x: 5; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                Repeater { model: [Theme.lights.close, Theme.lights.minimize, Theme.lights.zoom]; Rectangle { required property color modelData; width: 5; height: 5; radius: 2.5; color: modelData } }
            }
        }
    }

    // Liquid Glass end buttons: the SF Symbols the Mac's view names (AppearancePreferencesFramework
    // GlassStylePreviewView: capsule.on.rectangle.liquid.glass and capsule.on.rectangle with the fill variant), at the
    // body size: their ink boxes are 16.25 x 13 and 17.1 x 13.8 pt (AX 16 x 13 and 17 x 13.5). Ink 124 on 247 light,
    // 157 on 37 dark (liquidglass-slider-zoom4x-*.png). Pressed: the label colour.
    // A drag that brings the knob onto an end bounces that end's glyph (SF Symbols .bounce by layer: the capsule, then
    // the rectangle 0.05 s later, 1.25 / 0.90 about the ink centre; the 23.09.23 recording frames 2228-2262 at 0 and
    // 2488-2527 at 1, INTERACTIVE-GLASS-REA.md 8). The end buttons' clicks do not track, so they do not bounce it.
    component GlassEndIcon: SfSymbol {
        property bool filled
        readonly property bool down: parent && parent.pressed === true
        name: filled ? "capsule.on.rectangle.fill" : "capsule.on.rectangle.liquid.glass"
        pointSize: 13
        color: down ? Theme.label : Theme.secondaryLabel
        layerScales: (filled ? glassTintedBounce : glassClearBounce).scales
    }
    SymbolBounce { id: glassClearBounce; objectName: "glassClearBounce"; name: "capsule.on.rectangle.liquid.glass" }
    SymbolBounce { id: glassTintedBounce; objectName: "glassTintedBounce"; name: "capsule.on.rectangle.fill" }
    Component { id: glassClear; GlassEndIcon { filled: false } }
    Component { id: glassTinted; GlassEndIcon { filled: true } }

    Card {
        FormRow {
            label: "Appearance"
            alignTop: true
            implicitHeight: 86
            Row {
                y: -1        // AX 74 x 66 at 10 below the row top
                spacing: 8   // AX 74 x 66 each, pitch 82
                Repeater {
                    model: [{ m: "light", t: "Light" }, { m: "dark", t: "Dark" }, { m: "auto", t: "Auto" }]
                    Choice {
                        required property var modelData
                        caption: modelData.t
                        selected: AppState.appearance.mode === modelData.m
                        onPicked: AppState.set("appearance", { mode: modelData.m })
                        MiniWindow { visible: modelData.m !== "auto"; darkWin: modelData.m === "dark" }
                        Item { // auto: light left half, dark right half
                            visible: modelData.m === "auto"; anchors.fill: parent
                            Item { width: parent.width / 2; height: parent.height; clip: true; MiniWindow { width: 67; height: 44; anchors.fill: undefined } }
                            Item { x: parent.width / 2; width: parent.width / 2; height: parent.height; clip: true; MiniWindow { x: -33.5; width: 67; height: 44; anchors.fill: undefined; darkWin: true } }
                        }
                    }
                }
            }
        }
        FormRow {
            label: "Liquid Glass"
            alignTop: true
            implicitHeight: 233   // 1 + 232: preview 268 x 180 at 10 below the row, slider row 13 under it, 13 to the end
            Column {
                spacing: 13
                Item { // preview: an article scrolling under glass toolbar capsules (Q-settings-26: a scroll view 268 x 180)
                    id: glassPreview
                    width: 268; height: 180
                    // the capsules follow the slider while it is dragged, the stored value otherwise. The 23.09.23
                    // recording (dark, 60 fps): the Search capsule over the pond darkens frame by frame with the knob
                    // (93,129,106 at 0.5 -> 66,82,75 at 1, frames 2529-2640, the knob held) and jumps in one frame when a
                    // click sets the value (frame 2786) while the knob still slides. Before: the stored value only,
                    // which NSGlassTintAmount gets on mouse-up
                    property real dragTint: -1
                    readonly property real tint: dragTint >= 0 ? dragTint : AppState.appearance.glass
                    // The view's appear sequence (GlassStylePreviewView's .task, APPEARANCE-PREVIEW-REA.md): photoOpacity
                    // starts at 0 and is set to 1 after 0.08 s, shown through .opacity on the whole clipped preview with
                    // .animation(.spring(response: 0.7, dampingFraction: 0.65), value: photoOpacity); after 1.3 s
                    // demoScrollOffset = -52 (the article slides up under the capsules), after 3.5 s back to 0. Reduce
                    // Motion: photoOpacity 1 at once and no demo. Once per view (the code skips it when photoOpacity != 0).
                    opacity: fadeIn.value
                    Spring { id: fadeIn; response: 0.7; damping: 0.65; target: 0 }
                    Timer { id: fadeTimer; interval: 80; onTriggered: fadeIn.target = 1 }
                    Timer { id: demoDown; interval: 1300; onTriggered: demoOffset.target = -52 }
                    Timer { id: demoBack; interval: 3500; onTriggered: demoOffset.target = 0 }
                    Component.onCompleted: {
                        if (Theme.reduceMotion) { fadeIn.target = 1; fadeIn.snap(); return; }
                        fadeTimer.start(); demoDown.start(); demoBack.start();
                    }
                    // rounded corners for the scrolling article (Rectangle.clip only clips to the bounding box)
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: true; maskSource: previewMask
                        maskThresholdMin: 0.5; maskSpreadAtMin: 1.0
                    }
                    Rectangle { id: previewMask; anchors.fill: parent; radius: 16; visible: false; layer.enabled: true }
                    // what the capsules see: the scrolling article and its soft top edge
                    Item {
                        id: articleView
                        anchors.fill: parent
                    Rectangle { anchors.fill: parent; color: Theme.previewCard }
                    // ._scrollInputForwardingBehavior(.never, axes: .vertical) on the preview: a vertical wheel the article
                    // cannot use (at its top or end) stops here. Before, it scrolled the whole pane once the article
                    // reached its end. Under the Flickable, so it only gets what the Flickable leaves
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        onWheel: w => w.accepted = Math.abs(w.angleDelta.y) + Math.abs(w.pixelDelta.y) >= Math.abs(w.angleDelta.x) + Math.abs(w.pixelDelta.x)
                    }
                    Flickable {
                        id: article
                        anchors.fill: parent
                        contentHeight: articleBody.height
                        boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
                        acceptedButtons: Qt.NoButton   // the Mac's preview scrolls by wheel / trackpad only, not by a mouse drag
                        RubberBand { flickable: article }
                        // The Mac's own article: AppearancePreferencesFramework 27.2.1, GlassStylePreviewView
                        // (reference/re/27.2.1/APPEARANCE-PREVIEW-REA.md has the chain and addresses). Text from its
                        // Localizable.loctable ("en"; the Mac in the R3.7 shots runs en_GB, hence "emphasise" there),
                        // photos from its Assets.car (settings/assets/glass-preview at the Mac's 2x size), layout from
                        // the view's code, checked on the R3.7 AX dumps (ax-preview-article-{top,end}-*.jsonl: content
                        // 268 x 1257.5; title y 167.9, subtitle 190.9, text 221.9, photos 294 / 590.5 / 871, headings
                        // 475.6 / 772 / 1158.6, last line ends 1233.6): the hero fills a 268 x 152 frame and is clipped
                        // to it, then padding(.bottom, -8); the text VStack (default spacing 8) has padding 16; title and
                        // headings title3 (15 pt, 19 pt lines), body 13 pt on 16 pt lines; photos 236 wide, r 16,
                        // padding(.vertical, 16). The end: Spacer().frame(height: ORLocked ? 32 : 8) at 0 spacing, so
                        // 16 + 8 below the last line (1257.5; was 16 + 8 + 8 = 1265.5). ORLocked is false on the Mac (no
                        // extra view in the AX dumps). The card is the view's own colour (Theme.previewCard).
                        Item {
                            id: articleBody
                            width: article.width
                            height: articleText.y + articleText.height + 16 + 8
                            // the view's appear demo: .offset(y: demoScrollOffset) on the article, animated by
                            // .spring(response: 2, dampingFraction: 0.82); -52 at 1.3 s, 0 at 3.5 s (the Timers on glassPreview)
                            transform: Translate { y: demoOffset.value }
                            Spring { id: demoOffset; response: 2.0; damping: 0.82; epsilon: 0.3; target: 0 }
                            Rectangle { anchors.fill: parent; color: Theme.previewCard }
                            // hero: Image("apple-park").resizable().aspectRatio(contentMode: .fill).frame(268, 152)
                            // .clipShape(Rectangle()): 1620 x 1080 filled to 268 x 178.5, centred, at -13.5 (AX end
                            // dumps; -27.2 px fitted on preview-article-scroll-00-light.png)
                            Item {
                                width: parent.width; height: 152
                                clip: true
                                Image {
                                    y: -13.5; width: parent.width; height: 178.5
                                    source: Qt.resolvedUrl("../assets/glass-preview/apple-park.jpg")
                                    sourceSize.width: 536
                                    asynchronous: true
                                }
                            }
                            Column {
                                id: articleText
                                x: 16; y: 152 - 8 + 8 + 16; width: parent.width - 32; spacing: 8
                                component Line: MacText {
                                    width: parent.width; wrapMode: Text.WordWrap
                                    lineHeightMode: Text.FixedHeight; lineHeight: size >= 15 ? 19 : 16
                                }
                                Item { width: parent.width; height: 19 - 4; Line { text: "Welcome to Apple Park"; size: 15; weight: Typography.semibold } }
                                Item { width: parent.width; height: 19 + 4; Line { text: "Cupertino, California"; size: 15; color: Theme.secondaryLabel } }
                                Line { text: "Learn about the design and history of Apple Park, and discover its unique nature and beauty." }
                                Repeater {
                                    model: [
                                        { img: "architecture.jpg", h: 157.5, t: "The Architecture", b: "Apple Park was made for walking and exploring. The innovative design elements emphasize openness and connection to nature." },
                                        { img: "pond.jpg", h: 157.5, t: "The Pond", b: "With gently lapping waves and a surrounding of trees, it\u2019s one of the most serene spots on campus." },
                                        // a PNG: the catalog's rainbow.png has a transparent 1-3 px rim the card shows through
                                        { img: "rainbow.png", h: 263.5, t: "The Rainbow", b: "One of the most iconic features of Apple Park, the Rainbow brings much joy to all who experience it." }]
                                    Column {
                                        id: section
                                        required property var modelData
                                        width: articleText.width; spacing: 8
                                        Item {
                                            width: parent.width; height: section.modelData.h + 32
                                            RoundedImage {
                                                y: 16; width: parent.width; height: section.modelData.h; radius: 16; decodeWidth: 472
                                                source: Qt.resolvedUrl("../assets/glass-preview/" + section.modelData.img)
                                            }
                                        }
                                        Line { text: section.modelData.t; size: 15; weight: Typography.bold }
                                        Line { text: section.modelData.b }
                                    }
                                }
                            }
                        }
                    }
                    // The view sets scrollEdgeEffectStyle(.soft, for: .top): content that has scrolled under the capsules
                    // is softened towards the edge, so text does not stand sharp between and inside them (user report:
                    // the title showed doubled and smeared around the capsules). Here: the card colour over the top
                    // 52 pt (the capsule row's height in the view), fading down, once the article has left its top.
                    // The effect is in the code; its strength and shape are inferred (no Mac shot of the preview scrolled).
                    Rectangle {
                        width: parent.width; height: 52
                        opacity: Math.max(0, Math.min(1, article.contentY / 16))
                        visible: opacity > 0
                        gradient: Gradient {
                            GradientStop { position: 0; color: Qt.rgba(Theme.previewCard.r, Theme.previewCard.g, Theme.previewCard.b, 0.92) }
                            GradientStop { position: 0.6; color: Qt.rgba(Theme.previewCard.r, Theme.previewCard.g, Theme.previewCard.b, 0.7) }
                            GradientStop { position: 1; color: Qt.rgba(Theme.previewCard.r, Theme.previewCard.g, Theme.previewCard.b, 0) }
                        }
                    }
                    }
                    // scroll indicator: 52 pt below the top (under the capsules), 16 above the bottom (the view's
                    // contentMargins for .scrollIndicators; AX scroll bar y 51..165 of the 180)
                    OverlayScrollbar {
                        flickable: article
                        x: parent.width - Tokens.scroller.inset - width
                        y: 52
                        height: parent.height - 52 - 16
                    }
                    // Glass toolbar capsules (liquidglass-0-mid-1-*.png, 2x): x 7.5, 88.5, 132.5; 74, 37, 128 wide; 37 tall
                    // at y 7; one LensGlass each over the article under it. Colour fitted on the copy capsule over the sky
                    // (161,192,223): light 0 / .5 / 1 -> (186,218,252), (200,225,251), (219,234,251); dark (136,164,192),
                    // (135,162,190), (84,97,111); since round 3 (GLASS-HIG.md) the decoded Regular face draws it (Tokens
                    // regularFace*), not a fitted gain. Rim line black a.4 light (159 -> 97), a.5 dark (158 -> 81). Refraction:
                    // the Regular recipe (Tokens regular*: inner, outer; GLASS-HIG.md, was the switch strip's fitted law). Until round 3: dark gain 0.79, not the shots' 0.85: in the
                    // 23.09.23 recording (dark, slider at 0.5) the share capsule's face over the same photo is 0.86 of
                    // ours where the photo itself is 0.93 (the recording's darker mid-tones), so 0.85 x 0.93 (judge #6:
                    // the rest capsule too bright, the press clipped it to white). Blur: the recording's face is smooth
                    // (luminance std 4.3, column range 13.5 levels); 3 pt gave 8.8 / 25, 16 pt 5.8 / 17 (larger blurs
                    // only add the 17-tap ring's noise): 16 pt at 0.5 on the earlier law's shape (1 + 4 x tint, by eye).
                    // Since round 2 (GLASS-HIG.md) the frost is the decoded blur fill instead (Tokens regularFill*).
                    Repeater {
                        // glyphs: the view's SF Symbols (square.and.arrow.up, ellipsis, square.on.square, magnifyingglass),
                        // regular, 16.5 pt (ink on the Mac shot: share 14.5 wide, the three dots 15 wide and 3 tall,
                        // the squares 17.5 x 17) and the magnifier at the body size (12 x 12); centres at 19.25 and
                        // 54.5 pt, 18.5, and 16 pt in their capsules
                        model: [{ x: 7.5, w: 74, g: ["square.and.arrow.up", "ellipsis"], c: [19.25, 54.5], t: "" },
                                { x: 88.5, w: 37, g: ["square.on.square"], c: [18.5], t: "" },
                                { x: 132.5, w: 128, g: ["magnifyingglass"], c: [16], t: "Search" }]
                        GlassButton {
                            id: cap
                            required property var modelData
                            x: modelData.x; y: 7; width: modelData.w; height: 37
                            // share | more: two glass buttons merged; each 37 wide (half the 74, centres 19.25 / 54.5)
                            segments: modelData.c.length === 2 ? [modelData.w / 2, modelData.w / 2] : []
                            LensGlass {
                                anchors.fill: parent
                                source: articleView
                                clampToSource: true   // 7 pt from the article's top and right edge, bends 18.5 pt in, 16 out
                                // the blur fill sees the Settings card around the article (round 3: with it the face matches
                                // the Mac's middle panel within 2-5 levels in light and dark; with the edge repeat in the
                                // blur too, dark read 20 levels light); the sharp samples keep the edge repeat (the rim)
                                fillBackdropOutside: true
                                backdrop: Tokens.control.lensBackdrop
                                origin: Qt.point(cap.x, cap.y)
                                band: Tokens.control.regularInnerBand(height)
                                amount: Tokens.control.regularInnerAmount(height)
                                outerBand: Tokens.control.regularOuterBand(height)
                                outerAmount: Tokens.control.regularOuterAmount(height)
                                outerOpacity: Tokens.control.regularOuterOpacity
                                rimBias: Tokens.control.regularRimBias
                                rimSpread: Tokens.control.regularRimSpread
                                fillLight: Tokens.control.regularFillLight
                                rimFace: Tokens.control.regularRimFace
                                rimStroke: Tokens.control.regularRimStroke
                                fillSigma: Tokens.control.regularFillSigma
                                fillNormal: Tokens.control.regularFillNormal(glassPreview.tint)
                                fillDarken: Theme.dark ? Tokens.control.regularFillMix(glassPreview.tint) : 0
                                fillLighten: Theme.dark ? 0 : Tokens.control.regularFillMix(glassPreview.tint)
                                // the decoded Regular face (Tokens regularFace*; round 3, was gain 1.14 / 0.79 and a fitted mix)
                                faceBlack: Tokens.control.regularFaceBlack
                                faceWhite: Tokens.control.regularFaceWhite
                                faceSat: Tokens.control.regularFaceSat
                                faceMaxLuma: Tokens.control.regularFaceMaxLuma
                                tint: Tokens.control.regularFaceFill(glassPreview.tint)
                                outline: Theme.dark ? 0.5 : 0.4
                                discCentre: light.discCentre
                                discLift: light.discLift
                                glowCentre: light.glowCentre
                                glowHalf: light.glowHalf
                                glowBig: light.glowBig
                                glowLittle: light.glowLittle
                                glowRadius: light.glowRadius
                                glowDodge: light.glowDodge
                                glowLut: light.glowLut
                            }
                            Repeater {
                                model: cap.modelData.g
                                SfSymbol {
                                    required property string modelData
                                    required property int index
                                    readonly property bool search: cap.modelData.t !== ""
                                    name: modelData
                                    pointSize: search ? 13 : 16.5
                                    x: cap.modelData.c[index] - width / 2
                                    y: (cap.height - height) / 2
                                    color: search ? (Theme.dark ? "#FFFFFF" : "#3A3A3C") : (Theme.dark ? "#FFFFFF" : "#1C1C1E")
                                }
                            }
                            // hover disc (the buttons' interaction fill, light and dark: Tokens.toolbar.glassButtonFill)
                            // and SwiftUI's press light of its buttons. The Search capsule takes the press light too and
                            // no hover disc (preview-hold-shine-search-{dark,light}.mov, capsule mean held - rest: dark
                            // +35 / +40 / +43, light +17 / +18 / +14, in one frame; hovered after the release 0 / 0 / 0;
                            // INTERACTIVE-GLASS-REA.md 8)
                            ToolbarHighlight {
                                id: light
                                anchors.fill: parent
                                hoverFill: cap.modelData.t === "" ? Tokens.toolbar.glassButtonFill : 0
                                littleOpacity: cap.modelData.t === "" ? -1 : 0.405
                                centres: cap.modelData.c
                            }
                            Text {
                                visible: cap.modelData.t !== ""
                                x: 31.5; anchors.verticalCenter: parent.verticalCenter
                                text: cap.modelData.t; font: Typography.font(13, Typography.medium)
                                color: Theme.dark ? Qt.rgba(1, 1, 1, 0.75) : Qt.rgba(0, 0, 0, 0.5)
                            }
                        }
                    }
                }
                // "Liquid Glass Tint Amount": one continuous slider, track 221.5 at x 465, end buttons 16 x 13 and
                // 17 x 13.5 that step -0.1 / +0.1, 3 tick dots (0, 0.5, 1), no labels, no snapping. NSGlassTintAmount is
                // written on mouse-up only; here appearance.glass the same way.
                Slider {
                    objectName: "glassSlider"
                    x: 1.5; width: 265.5
                    glyphGap: 5.5
                    value: AppState.appearance.glass
                    leftIcon: glassClear; rightIcon: glassTinted
                    endStep: 0.1
                    tickMarks: 3
                    // the fill runs to value x the track, the knob stays half a knob inside the ends (the 23.09.23
                    // recording, knob held: at 0 no fill shows in the lens, at 1 the fill reaches the track's end, at
                    // 0.07-0.09 the fill end is within 1.5 px of the lens centre; a fill to the knob's centre was 10 pt off)
                    fillToEnds: true
                    onMoved: v => glassPreview.dragTint = v
                    onEndReached: end => (end < 0 ? glassClearBounce : glassTintedBounce).play()
                    onReleased: Qt.callLater(() => glassPreview.dragTint = -1)
                    onCommitted: v => { AppState.set("appearance", { glass: Math.round(v * 1000) / 1000 }); glassPreview.dragTint = -1; }
                }
            }
        }
    }

    Card {
        title: "Theme"
        FormRow {
            label: "Color"
            alignTop: true
            implicitHeight: 62
            Row {
                spacing: 12
                Repeater {
                    model: ["multicolor", "blue", "purple", "pink", "red", "orange", "yellow", "green", "graphite"]
                    Column {
                        id: sw
                        required property string modelData
                        readonly property bool sel: AppState.appearance.accent === modelData
                        spacing: 4 // the ring overhangs the swatch by 4 pt; the name sits right under it (Q-settings-25)
                        // ref (RE, macOS 27.2 Appearance.appex AccentCircle): a 24pt image clipped to a
                        // circle, a 1pt quinaryLabel inner edge (plus-darker, so light mode only), and when
                        // selected a 3pt accent-colour ring whose outer edge is 32pt. Multicolor's image
                        // is AppKit's NSMulticolorAccent: a soft conic colour wheel, red at 3 o'clock.
                        Item {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 24; height: 24
                            Rectangle {
                                anchors.centerIn: parent
                                visible: sw.sel
                                width: 32; height: 32; radius: 16
                                color: "transparent"
                                border.width: 3; border.color: Theme.accent
                            }
                            Rectangle {
                                anchors.fill: parent; radius: 12
                                visible: sw.modelData !== "multicolor"
                                color: Accent.swatch(sw.modelData)   // controlAccentColor, light/dark (27.2.1)
                            }
                            Shape {
                                anchors.fill: parent
                                visible: sw.modelData === "multicolor"
                                preferredRendererType: Shape.CurveRenderer
                                ShapePath {
                                    strokeWidth: -1
                                    fillGradient: ConicalGradient {
                                        centerX: 12; centerY: 12; angle: 0
                                        // NSMulticolorAccent@2x, sampled from reference/screens/27.2.1/multicolor-swatch.png (Accent)
                                        GradientStop { position: 0 / 12; color: Accent.multicolorStops[0] }
                                        GradientStop { position: 1 / 12; color: Accent.multicolorStops[1] }
                                        GradientStop { position: 2 / 12; color: Accent.multicolorStops[2] }
                                        GradientStop { position: 3 / 12; color: Accent.multicolorStops[3] }
                                        GradientStop { position: 4 / 12; color: Accent.multicolorStops[4] }
                                        GradientStop { position: 5 / 12; color: Accent.multicolorStops[5] }
                                        GradientStop { position: 6 / 12; color: Accent.multicolorStops[6] }
                                        GradientStop { position: 7 / 12; color: Accent.multicolorStops[7] }
                                        GradientStop { position: 8 / 12; color: Accent.multicolorStops[8] }
                                        GradientStop { position: 9 / 12; color: Accent.multicolorStops[9] }
                                        GradientStop { position: 10 / 12; color: Accent.multicolorStops[10] }
                                        GradientStop { position: 11 / 12; color: Accent.multicolorStops[11] }
                                        GradientStop { position: 12 / 12; color: Accent.multicolorStops[0] }
                                    }
                                    PathAngleArc { centerX: 12; centerY: 12; radiusX: 12; radiusY: 12; startAngle: 0; sweepAngle: 360 }
                                }
                            }
                            Rectangle {
                                anchors.fill: parent; radius: 12
                                visible: !Theme.dark
                                color: "transparent"
                                border.width: 1; border.color: Qt.rgba(0, 0, 0, 0.047)
                            }
                            MouseArea { anchors.fill: parent; onClicked: AppState.set("appearance", { accent: sw.modelData }) }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 1; horizontalAlignment: Text.AlignHCenter
                            text: sw.sel ? sw.modelData.charAt(0).toUpperCase() + sw.modelData.slice(1) : ""
                            font: Typography.subheadline
                            color: Theme.secondaryLabel
                        }
                    }
                }
            }
        }
        // AppleHighlightColor: Automatic (key absent: selectedTextBackgroundColor follows the accent) or one of AppKit's
        // eight highlight keys; here appearance.highlight ("" = Automatic), read by Accent.selectedText. Menu (R3.8a
        // control-text-highlight-colour-open-*.png): Automatic, a separator, Blue ... Graphite, a separator, Choose
        // Colour…; the dots are the highlight colours themselves (selectedTextBackground, Accent.table text: light
        // blue #BAD6FB on the shot = #B3D7FF before Display P3, dark #476288 / #3F638B, graphite #E0E0E0 / #696969),
        // Automatic's NSMulticolorHighlight. Not offered: "Choose Colour…" (no colour panel), so no second separator.
        FormRow {
            id: hlRow
            label: "Text highlight color"
            implicitHeight: 38   // 1 + 37
            readonly property int index: Math.max(0, P.highlightNames.indexOf(AppState.appearance.highlight))
            Popup {
                objectName: "highlightPopup"
                // R13.2 popups.json: Automatic, the eight colours, then "Choose Colour…" after a second separator. No colour
                // panel here: that item leaves the choice as it was (settings/FALLBACKS.md "Pop-up menus")
                model: P.highlightNames.map(n => n ? n.charAt(0).toUpperCase() + n.slice(1) : "Automatic").concat(["Choose Color…"])
                // the current colour's dot sits inside the button (appearance-light.png: 16 pt, 12 pt from the button's
                // left edge, 8 pt before the text). Automatic: AppKit's NSMulticolorHighlight
                dots: P.highlightNames.map(n => n ? Accent.table[n].text[Theme.dark ? 1 : 0] : Accent.multicolorHighlightDot).concat([""])
                separators: [0, 8]
                currentIndex: hlRow.index
                onActivated: i => { if (i < P.highlightNames.length) AppState.set("appearance", { highlight: P.highlightNames[i] }); }
            }
        }
    }

    // 27.2.1 order below the theme card (appearance-scrolled-light.png, appearance-iconstyle-tinted-light.png)
    Card {
        FormRow {
            id: styleRow
            label: "Icon & widget style"
            alignTop: true
            readonly property string style: AppState.appearance.iconStyle
            // Dark offers Always / Auto, Clear and Tinted Light / Dark / Auto (Q-settings-27, PC #60 section 3)
            readonly property var names: ({ light: "Light", dark: style === "dark" ? "Always" : "Dark", auto: "Auto" })
            readonly property var variants: P.iconStyleVariantsOf(style)
            implicitHeight: variants.length ? 104.5 : 88   // the radio row (16.5 at 69 below the tiles) goes with Default
            Item {
                y: -2   // tiles: AX 38 x 52 at 9 below the row top
                width: tiles.width; height: styleRow.variants.length ? 85.5 : 52
                Row {
                    id: tiles
                    anchors.right: parent.right
                    spacing: 13
                    Repeater {
                        model: [{ t: "Default" }, { t: "Dark" }, { t: "Clear" }, { t: "Tinted" }]
                        Choice {
                            required property var modelData
                            w: 29; h: 29; r: 7; gap: 1.5   // AX 38 x 52 with the caption; tile 29, ring gap 1.5
                            caption: modelData.t
                            selected: AppState.appearance.iconStyle === modelData.t.toLowerCase()
                            // Default removes the key on the Mac; the mode carries over to the next style (P)
                            onPicked: AppState.set("appearance", {
                                iconStyle: modelData.t.toLowerCase(),
                                iconStyleVariant: P.iconStyleVariantAfter(styleRow.style, AppState.appearance.iconStyleVariant, modelData.t.toLowerCase())
                            })
                            // The tile is the Weather app's icon in that style (Appearance.appex IconStyleRow: ISIcon(
                            // bundleIdentifier: "com.apple.weather") through an ISImageDescriptor, in an
                            // AsyncIconImage), 36 pt with its 29 pt body on the tile (fitted on iconstyle-*-light.png:
                            // 72 px, rms 10-16 levels; R11.6 dark-mode stills, read as sRGB: 5-12). Default and Dark never change; Clear and Tinted show the mode
                            // of the radios (iconstyle-dark-light.png: Dark + Always in light mode shows the dark
                            // Clear and Tinted; Auto = the system's), Tinted in the chosen colour (Automatic = the
                            // accent; iconstyle-tinted-red-auto-light.png). Files: settings/assets/icon-style
                            // (themes/icons/tools/build-style-tiles.py, IconRendering's composition; reference/ASSETS.md)
                            Image {
                                // With Default selected the two are the light ones, in dark mode too (R11.6
                                // icon-style-tiles-default-selected-dark.png: Clear a grey 128 tile, Tinted the
                                // accent's; Default has no mode, the next style starts as Light)
                                readonly property bool darkTile: styleRow.style !== "default"
                                    && (AppState.appearance.iconStyleVariant === "dark"
                                        || (AppState.appearance.iconStyleVariant === "auto" && Theme.dark))
                                readonly property string tint: AppState.appearance.iconTint
                                    || (Accent.table[AppState.appearance.accent] ? AppState.appearance.accent : "blue")
                                readonly property string file: modelData.t === "Default" ? "default" : modelData.t === "Dark" ? "dark"
                                    : (modelData.t === "Clear" ? "clear" : "tinted-" + tint) + (darkTile ? "-dark" : "-light")
                                anchors.centerIn: parent
                                width: 36; height: 36
                                source: "../assets/icon-style/" + file + ".png"
                                sourceSize: Qt.size(144, 144)
                                smooth: true; mipmap: true
                            }
                        }
                    }
                }
                Row { // right-aligned at the card's inner edge; radios 52 / 49.5 / 49.5 wide, 8 apart (Clear, Tinted)
                    anchors.right: parent.right
                    y: 69
                    visible: styleRow.variants.length > 0
                    spacing: 8
                    Repeater {
                        model: styleRow.variants
                        Checkbox {
                            required property string modelData
                            radio: true
                            text: styleRow.names[modelData]
                            checked: AppState.appearance.iconStyleVariant === modelData
                            onToggled: AppState.set("appearance", { iconStyleVariant: modelData })
                        }
                    }
                }
            }
        }
        // AppleIconAppearanceTintColor: Automatic | Red ... Graphite (with colour dots) | Choose Colour… (PC #60
        // section 3); here appearance.iconTint ("" = Automatic). The custom colour popover is not drawn, so the menu
        // (R3.8a control-folder-colour-open-*.png) has its separator after Automatic only. The dot is the button's own
        // (control-folder-colour-rest-*.png: one 16 pt dot inside the 133 pt button; a second one beside it is gone)
        FormRow {
            id: tintRow
            label: AppState.appearance.iconStyle === "tinted" ? "Icon, widget & folder color" : "Folder color"
            implicitHeight: 41   // 1 + 40
            readonly property var names: ["Automatic", "Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink", "Graphite"]
            readonly property int index: Math.max(0, P.iconTints.indexOf(AppState.appearance.iconTint))
            function dot(i) { return i === 0 ? Theme.accent : Accent.swatch(P.iconTints[i]); }
            Popup {
                objectName: "folderColorPopup"
                model: tintRow.names.concat(["Choose Color…"])   // R13.2 popups.json; no colour panel here
                dots: tintRow.names.map((n, i) => tintRow.dot(i)).concat([""])
                separators: [0, 8]
                currentIndex: tintRow.index
                onActivated: i => { if (i < P.iconTints.length) AppState.set("appearance", { iconTint: P.iconTints[i] }); }
            }
        }
    }

    Card {
        title: "Windows"
        FormRow {
            label: "Sidebar icon size"
            implicitHeight: 37.5
            StatePopup { objectName: "sidebarIconSizePopup"; stateKey: "appearance"; field: "sidebarIconSize"; choices: [["Small", "small"], ["Medium", "medium"], ["Large", "large"]] }
        }
        FormRow { label: "Tint window background with wallpaper color"; implicitHeight: 37.5; Switch { checked: AppState.appearance.tintWindowBackground; onToggled: on => AppState.set("appearance", { tintWindowBackground: on }) } }   // 1 + 36.5, mini switch; read by Finder and Settings sidebars
    }

    // radio groups under their label, one per row (held locally until a backend exists). Label centre 18 below the
    // row, radio centres from 42 at a 22.5 pitch; rows 105 (3 radios) and 1 + 83 (2) (appearance-full-light.png)
    component RadioGroup: Item {
        id: rg
        property string label
        property var options: []
        property int current: 0
        property bool separator: false
        readonly property real _top: separator ? 1 : 0
        width: parent ? parent.width : 0
        Rectangle { visible: rg.separator; x: Theme.content.separatorInset; width: parent.width - 2 * x; height: 1; color: Theme.separator }
        MacText { x: Theme.content.rowPadding; y: rg._top + 18 - height / 2; text: rg.label }
        Repeater {
            model: rg.options
            Checkbox {
                required property string modelData
                required property int index
                x: Theme.content.rowPadding; y: rg._top + 42 + index * 22.5 - height / 2
                radio: true
                text: modelData
                checked: rg.current === index
                onToggled: rg.current = index
            }
        }
    }
    Card {
        RadioGroup { implicitHeight: 105; label: "Show scroll bars"; options: ["Automatically based on mouse or trackpad", "When scrolling", "Always"] }
        RadioGroup { implicitHeight: 84; separator: true; label: "Click in the scroll bar to"; options: ["Jump to the next page", "Jump to the spot that\u2019s clicked"] }
    }

    // Appearance.appex AccessibilitySettingsSection: opens x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Seeing_Display
    PaneFooter { Button { text: "More in Accessibility Settings…"; onClicked: AppState.navigate("accessibility", "display") } }
}
