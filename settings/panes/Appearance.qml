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
        // here the user's wallpaper, else hyprk's default; one small decode shared by every thumbnail
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
            path: AppState.wallpaperImage || Backend.root + "/themes/wallpapers/png/DefaultAerial.png"
        }
        Rectangle { width: 67; height: 44; radius: 6; visible: darkWin; color: Qt.rgba(0.02, 0.03, 0.12, 0.55) }
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
    component GlassEndIcon: SfSymbol {
        property bool filled
        readonly property bool down: parent && parent.pressed === true
        name: filled ? "capsule.on.rectangle.fill" : "capsule.on.rectangle.liquid.glass"
        pointSize: 13
        color: down ? Theme.label : Theme.secondaryLabel
    }
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
                    Flickable {
                        id: article
                        anchors.fill: parent
                        contentHeight: articleBody.height
                        boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
                        RubberBand { flickable: article }
                        // The Mac's own article: AppearancePreferencesFramework 27.2.1, GlassStylePreviewView. Text from
                        // its Localizable.loctable (en), photos from its Assets.car (apple-park, architecture, pond,
                        // rainbow; settings/assets/glass-preview, 804 px wide), layout from the view's code, which
                        // reproduces the AX frames of the Mac (ax-scroll000-dark.jsonl: title y 167.9, subtitle
                        // 190.9, text 221.9, first photo 294, heading 475.6, ...): the photo fills a 268 x 152 slot,
                        // the text block starts 16 pt below it (padding 16, the hero's bottom padding -8, stack
                        // spacing 8), its lines 8 pt apart; title and headings title3 (15 pt, 19 pt lines), body 13 pt
                        // on 16 pt lines; photos 236 wide, r 16, 16 pt above and below. The card is the view's own
                        // colour (0.912, 0.897, 0.876 light, 0.076, 0.070, 0.060 dark = Theme.previewCard).
                        // Inferred: the 8 pt spacer at the end (the code has 32 or 8 by a state not decoded).
                        Item {
                            id: articleBody
                            width: article.width
                            height: articleText.y + articleText.height + 16 + 8 + 8
                            Rectangle { anchors.fill: parent; color: Theme.previewCard }
                            Image {
                                width: parent.width; height: 152
                                source: Qt.resolvedUrl("../assets/glass-preview/apple-park.jpg")
                                sourceSize.width: 804
                                fillMode: Image.PreserveAspectCrop
                                clip: true
                                asynchronous: true
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
                                        { img: "architecture", h: 157.5, t: "The Architecture", b: "Apple Park was made for walking and exploring. The innovative design elements emphasize openness and connection to nature." },
                                        { img: "pond", h: 157.5, t: "The Pond", b: "With gently lapping waves and a surrounding of trees, it\u2019s one of the most serene spots on campus." },
                                        { img: "rainbow", h: 263.5, t: "The Rainbow", b: "One of the most iconic features of Apple Park, the Rainbow brings much joy to all who experience it." }]
                                    Column {
                                        id: section
                                        required property var modelData
                                        width: articleText.width; spacing: 8
                                        Item {
                                            width: parent.width; height: section.modelData.h + 32
                                            RoundedImage {
                                                y: 16; width: parent.width; height: section.modelData.h; radius: 16; decodeWidth: 804
                                                source: Qt.resolvedUrl("../assets/glass-preview/" + section.modelData.img + ".jpg")
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
                    // (161,192,223): light 0 / .5 / 1 -> (186,218,252), (200,225,251), (219,234,251) = the sample x1.14
                    // mixed with white .00 / .22 / .48; dark (136,164,192), (135,162,190), (84,97,111) = x0.85 mixed
                    // with #1E1E1E 0 / 0 / .5. Rim line black a.4 light (159 -> 97), a.5 dark (158 -> 81). Refraction:
                    // the knob lens law (Tokens lensBand / lensAmount). Blur: not measurable from the shots (the
                    // photo under the capsules is not visible without them); 1 pt at 0 to 5 pt at 1 by eye (estimate).
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
                            LensGlass {
                                anchors.fill: parent
                                source: articleView
                                clampToSource: true   // 7 pt from the article's top and right edge, bends 12.6 pt
                                origin: Qt.point(cap.x, cap.y)
                                band: height * Tokens.control.lensBand
                                amount: height * Tokens.control.lensAmount
                                blur: 1 + 4 * glassPreview.tint
                                gain: Theme.dark ? 0.85 : 1.14
                                tint: Theme.dark ? Qt.rgba(0.118, 0.118, 0.118, Math.max(0, glassPreview.tint - 0.5))
                                                 : Qt.rgba(1, 1, 1, glassPreview.tint <= 0.5 ? 0.44 * glassPreview.tint
                                                                                              : 0.22 + 0.52 * (glassPreview.tint - 0.5))
                                outline: Theme.dark ? 0.5 : 0.4
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
                    onMoved: v => glassPreview.dragTint = v
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
        // eight highlight keys; here appearance.highlight ("" = Automatic), read by Accent.selectedText. The swatch
        // and the menu dots are the keys' catalog colours (System controlAccent<Name>Color = the accent swatches;
        // accent-colors.json highlightKeys), Automatic's is NSMulticolorHighlight. Not offered: "Choose Color..."
        // (no colour panel). The open menu's dots are not on a Mac shot (popup-menu-open-*.png is another pop-up).
        FormRow {
            id: hlRow
            label: "Text highlight color"
            implicitHeight: 38   // 1 + 37
            readonly property int index: Math.max(0, P.highlightNames.indexOf(AppState.appearance.highlight))
            Popup {
                objectName: "highlightPopup"
                model: P.highlightNames.map(n => n ? n.charAt(0).toUpperCase() + n.slice(1) : "Automatic")
                // the current colour's dot sits inside the button (appearance-light.png: 16 pt, 12 pt from the button's
                // left edge, 8 pt before the text). Automatic: AppKit's NSMulticolorHighlight
                dots: P.highlightNames.map(n => n ? Accent.swatch(n) : Accent.multicolorHighlightDot)
                currentIndex: hlRow.index
                onActivated: i => AppState.set("appearance", { highlight: P.highlightNames[i] })
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
                        // tile and sun colours: sampled on appearance-*.png (Display P3 numbers) and converted to sRGB
                        // (reference/ours/COLOUR-P3-AUDIT.md: 60,136,245 -> 0,138,253; 249,196,22 -> 255,193,0)
                        model: [{ t: "Default", c: "#008AFD" }, { t: "Dark", c: "#171717" }, { t: "Clear", c: "#7D7D7D" }, { t: "Tinted", c: "#007AF9" }]
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
                            Rectangle {   // Wi-Fi tile body per style (#35)
                                anchors.fill: parent; radius: 7
                                // Tinted shows the chosen tint (iconstyle-tinted-red-auto-light.png)
                                color: modelData.t === "Tinted" && AppState.appearance.iconTint ? Accent.swatch(AppState.appearance.iconTint) : modelData.c
                                // sun behind a translucent cloud (27.2.1 appearance-light.png tiles): sun 11 pt at
                                // centre (20, 12.5), cloud over the lower left; sampled sun #F9C416 / #EDB609 / #E0E1E1 / #96DEFF
                                Rectangle {
                                    x: 14.5; y: 7; width: 11; height: 11; radius: 5.5
                                    color: ({ Default: "#FFC100", Dark: "#F7B300", Clear: "#E0E1E1", Tinted: "#7EE0FF" })[modelData.t]
                                }
                                SfSymbol {   // cloud.fill, fitted on appearance-light.png's tiles (the Mac's is the Weather
                                    // icon's own cloud): ink 39 px wide, left edge 9 px and bottom 44 px in the 58 px tile
                                    x: 4.1; y: 9; name: "cloud.fill"; pointSize: 16.6
                                    color: modelData.t === "Dark" ? Qt.rgba(0.85, 0.85, 0.86, 0.8) : modelData.t === "Clear" ? Qt.rgba(0.86, 0.86, 0.87, 0.85)
                                         : Qt.rgba(1, 1, 1, 0.62)
                                }
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
        // section 3); here appearance.iconTint ("" = Automatic). The custom colour popover is not drawn.
        FormRow {
            id: tintRow
            label: AppState.appearance.iconStyle === "tinted" ? "Icon, widget & folder color" : "Folder color"
            implicitHeight: 41   // 1 + 40
            readonly property var names: ["Automatic", "Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink", "Graphite"]
            readonly property int index: Math.max(0, P.iconTints.indexOf(AppState.appearance.iconTint))
            function dot(i) { return i === 0 ? Theme.accent : Accent.swatch(P.iconTints[i]); }
            Rectangle { width: 16; height: 16; radius: 8; color: tintRow.dot(tintRow.index); anchors.verticalCenter: parent ? parent.verticalCenter : undefined }
            Popup {
                model: tintRow.names
                dots: tintRow.names.map((n, i) => tintRow.dot(i))
                currentIndex: tintRow.index
                onActivated: i => AppState.set("appearance", { iconTint: P.iconTints[i] })
            }
        }
    }

    Card {
        title: "Windows"
        FormRow {
            label: "Sidebar icon size"
            implicitHeight: 37.5
            StatePopup { stateKey: "appearance"; field: "sidebarIconSize"; choices: [["Small", "small"], ["Medium", "medium"], ["Large", "large"]] }
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
        RadioGroup { implicitHeight: 84; separator: true; label: "Click in the scroll bar to"; options: ["Jump to the next page", "Jump to the spot that's clicked"] }
    }

    PaneFooter { Button { text: "More in Accessibility Settings…" } }
}
