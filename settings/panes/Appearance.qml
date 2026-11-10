import QtQuick
import QtQuick.Shapes
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
        Rectangle { // wallpaper
            anchors.fill: parent; radius: 6
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: darkWin ? "#1B2A6B" : "#8DB6F2" }
                GradientStop { position: 1; color: darkWin ? "#3A2E8F" : "#3D6BD8" }
            }
        }
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

    // Liquid Glass end buttons (liquidglass-slider-zoom4x-*.png): a rounded rectangle with a capsule over its lower
    // right; outlined = "Capsule Shape On A Rectangle With A Liquid Glass Effect", filled = "... On A Rectangle".
    // Pressed: the label colour (darker).
    component GlassEndIcon: Item {
        property bool filled
        readonly property bool down: parent && parent.pressed === true
        readonly property color ink: down ? Theme.label : Theme.secondaryLabel
        width: filled ? 17 : 16; height: filled ? 13.5 : 13
        Rectangle {
            x: 0; y: 0; width: parent.width * 0.72; height: parent.height * 0.62; radius: 3
            color: parent.filled ? parent.ink : "transparent"
            border.width: parent.filled ? 0 : 1; border.color: parent.ink
        }
        Rectangle {
            x: parent.width * 0.22; y: parent.height * 0.34; width: parent.width * 0.78; height: parent.height * 0.66
            radius: height / 2
            color: parent.filled ? parent.ink : Theme.cardFill
            border.width: 1; border.color: parent.filled ? Theme.cardFill : parent.ink
        }
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
                Rectangle { // preview: wallpaper with glass controls on top
                    width: 268; height: 180; radius: 14; clip: true
                    gradient: Gradient {
                        GradientStop { position: 0; color: "#8EC5F0" }
                        GradientStop { position: 0.55; color: "#5C9A55" }
                        GradientStop { position: 1; color: "#2F5A2E" }
                    }
                    RoundedImage {
                        id: preview
                        anchors.fill: parent; radius: 14; decodeWidth: 540
                        path: AppState.wallpaperImage || Backend.root + "/themes/wallpapers/png/DefaultAerial.png"
                    }
                    Rectangle { // ref: a document title strip under the photo
                        anchors.bottom: parent.bottom
                        width: parent.width; height: 30   // ref: a slim strip
                        bottomLeftRadius: 14; bottomRightRadius: 14
                        color: Theme.previewStrip
                        MacText {
                            x: 14; anchors.verticalCenter: parent.verticalCenter
                            text: P.prettyFileName(preview.path)
                            weight: Typography.semibold
                        }
                    }
                    Row {
                        x: 8; y: 8; spacing: 6
                        Repeater {
                            model: [{ w: 72, g: "ios_share  more_horiz", t: "" }, { w: 36, g: "filter_none", t: "" }, { w: 136, g: "search", t: "Search" }]
                            Rectangle {
                                required property var modelData
                                width: modelData.w; height: 36; radius: 18
                                // 0 = clearer, 1 = frosted: lighter in light mode, greyer in dark (PC #60 section 2;
                                // the Mac's Search capsule light #E1DBCB -> #E6E5E2, dark #989590 -> #5A5A57 over its
                                // photo). Follows the stored value, so it changes once on mouse-up, not while dragging.
                                color: Theme.dark ? Qt.rgba(0.30, 0.30, 0.29, 0.25 + 0.6 * AppState.appearance.glass)
                                                  : Qt.rgba(1, 1, 1, 0.18 + 0.6 * AppState.appearance.glass)
                                border.color: Qt.rgba(1, 1, 1, Theme.dark ? 0.35 : 0.7)
                                Row {
                                    x: 10; anchors.verticalCenter: parent.verticalCenter; spacing: 5
                                    Text { text: modelData.g; font.family: Theme.fontGlyph; font.pixelSize: 18; color: "#1C1C1E" }
                                    Text { text: modelData.t; font: Typography.body; color: "#3A3A3C"; anchors.verticalCenter: parent.verticalCenter }
                                }
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
                    onCommitted: v => AppState.set("appearance", { glass: Math.round(v * 1000) / 1000 })
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
        FormRow {
            label: "Text highlight color"
            implicitHeight: 38   // 1 + 37
            Rectangle { // ref: swatch of the current highlight colour before the pop-up
                width: 16; height: 16; radius: 8
                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                readonly property var names: ["", "accent", "blue", "purple", "pink", "red", "orange", "yellow", "green", "graphite"]
                readonly property string name: names[hl.currentIndex]
                // the accent colours of the swatches above (Accent, 27.2.1)
                color: name === "accent" ? Theme.accent : name ? Accent.swatch(name) : "transparent"
                gradient: name ? null : auto
                Gradient {   // Automatic: AppKit's NSMulticolorHighlight (multicolor-highlight-swatch.png)
                    id: auto
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: Accent.multicolorHighlightStops[0] }
                    GradientStop { position: 0.5; color: Accent.multicolorHighlightStops[1] }
                    GradientStop { position: 1; color: Accent.multicolorHighlightStops[2] }
                }
            }
            LocalPopup { id: hl; model: ["Automatic", "Accent Color", "Blue", "Purple", "Pink", "Red", "Orange", "Yellow", "Green", "Graphite"] }
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
                        model: [{ t: "Default", c: "#3C88F5" }, { t: "Dark", c: "#171717" }, { t: "Clear", c: "#7D7D7D" }, { t: "Tinted", c: "#3478F1" }]
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
                                Text {
                                    anchors.centerIn: parent; text: "cloud"; font.family: Theme.fontGlyph; font.pixelSize: 17
                                    color: modelData.t === "Dark" ? "#3C88F5" : "white"
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
        FormRow { label: "Tint window background with wallpaper color"; implicitHeight: 37.5; LocalSwitch { checked: true } }   // 1 + 36.5, mini switch
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
