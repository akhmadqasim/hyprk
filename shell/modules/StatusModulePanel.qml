import QtQuick
import Quickshell
import qs
import qs.components
import qs.HyprK
import "../lib/statusmodule.js" as SM

// A menu bar status item's module (macOS 27.2.1 ControlCenter.app ModuleStack: Wi-Fi, Battery, Focus), drawn from the
// rows lib/statusmodule.js builds. Sizes and their sources: lib/statusmodule.js and
// reference/re/27.2.1/STATUS-REA-27.2.1.md "Measured on the Mac shots" (M). Unlike Control Center's tiles the panel
// follows the appearance (M: light glass with dark text in light, dark glass with white text in dark): menu glass
// (StatusModuleWindow's layer), continuous r 16 (M: the corner as Control Center's module panel).
Item {
    id: p
    property var rows: []
    property real originX: 0
    property real originY: 0
    property real materialize: 1
    signal switchToggled(bool on)
    signal rowActivated(var row)
    signal disclosureToggled()
    signal settingsRequested(string pane)

    readonly property var m: SM.metrics()
    readonly property var laid: SM.layout(rows)
    width: m.width
    height: laid.height

    // M, colours over the glass (2x shots, display RGB; the Mac draws them vibrant: a constant step over any backdrop):
    // primary text black .85 over the light glass (25,33,38 over 170,220,250, an exact alpha fit), white .9 in dark
    // (234 over 45..57); secondary (list titles, state lines, the percentage, the chevron, the lock, glyphs in an off
    // disc) 104 levels under the glass in light (plus-darker) and 80 over it in dark (plus-lighter); lines, off discs
    // and the hovered row 20 under / over. Every channel moves by the same step whatever the glass's colour
    // (VIBRANCY-REA.md: the lock 180,240,255 -> 74,137,153 light, 66,90,209 -> 145,169,255 dark; lines exactly -20 / +20
    // on three backdrops), so the text takes the backdrop's hue. Dark is drawn so: additive through
    // shaders/plustext.frag (`plus`). Plus-darker cannot be done by an over-blend (VIBRANCY-REA.md), so light keeps
    // the alpha with the same step at the glass's luminance: black .5 / .1
    readonly property bool dark: Theme.dark
    readonly property bool plus: dark
    readonly property real secondaryLift: 80 / 255
    readonly property real lineLift: 20 / 255
    readonly property color primary: dark ? Qt.rgba(1, 1, 1, 0.9) : Qt.rgba(0, 0, 0, 0.85)
    // with `plus` only the coverage of these is used (white), the lift is added under it
    readonly property color secondary: plus ? "#FFFFFF" : Qt.rgba(0, 0, 0, 0.5)
    readonly property color lineColor: plus ? "#FFFFFF" : Qt.rgba(0, 0, 0, 0.1)
    readonly property color discOff: lineColor
    // systemIndigoColor, light (0.3804, 0.3333, 0.9608) / dark (0.4275, 0.4863, 1) (names.json focusModes)
    readonly property color focusOn: dark ? Qt.rgba(0.4275, 0.4863, 1, 1) : Qt.rgba(0.3804, 0.3333, 0.9608, 1)
    // M (R4.2 module-wifi-hover-row-*.png): a hovered row is exactly the line's step, 20 under / over the glass
    readonly property color rowHover: lineColor
    readonly property real dpr: QsWindow.window ? QsWindow.window.devicePixelRatio : Screen.devicePixelRatio

    // plus-lighter for a layered item: the glass under it + `lift` where the item covers (shaders/plustext.frag)
    component PlusLift: ShaderEffect {
        property real lift: p.secondaryLift
        fragmentShader: Qt.resolvedUrl("../shaders/plustext.frag.qsb")
    }

    Glass {
        anchors.fill: parent
        radius: Theme.cc.modulePanelRadius
        sx: p.originX
        sy: p.originY
        tint: Theme.glass.tintStrong
        solidColor: Theme.reduceTransparency ? Theme.color.menuSolid : Theme.glass.solid
        materialize: p.materialize
    }

    Repeater {
        model: p.laid.rows
        Item {
            id: row
            required property var modelData
            readonly property var r: modelData
            y: r.y
            width: p.width
            height: r.h

            // header: title (M: SF 13 Semibold, "Wi‑Fi" ink 32.5 wide), then a switch or the text accessory at the right
            Text {
                visible: row.r.type === "header"
                x: p.m.inset
                anchors.baseline: parent.top
                anchors.baselineOffset: row.r.subtitle ? p.m.headerSubBaseline : p.m.headerBaseline
                text: row.r.title || ""
                font: Typography.font(Theme.font.ccModuleRow, Typography.semibold)
                color: p.primary
            }
            Text {   // M: the Focus header's "On" while a Focus is on, SF 12 Regular (cap 8.5), secondary
                visible: row.r.type === "header" && !!row.r.subtitle
                x: p.m.inset
                anchors.baseline: parent.top
                anchors.baselineOffset: p.m.subtitleBaseline
                text: row.r.subtitle || ""
                font: Typography.font(12)
                color: p.secondary
                layer.enabled: p.plus && visible
                layer.effect: PlusLift {}
            }
            Text {   // M: the Battery percentage, SF 13 Regular ("100%" ink 33 wide), secondary, right edge 14 in
                visible: row.r.type === "header" && row.r.accessory === "text"
                anchors.right: parent.right
                anchors.rightMargin: p.m.inset
                anchors.baseline: parent.top
                anchors.baselineOffset: p.m.headerBaseline
                text: row.r.text || ""
                font: Typography.font(Theme.font.ccModuleRow)
                color: p.secondary
                layer.enabled: p.plus && visible
                layer.effect: PlusLift {}
            }
            Loader {   // C: ModuleSwitchToggle = SwiftUI SwitchToggleStyle. M: 54 x 24, knob 32 x 20: HyprK regular
                active: row.r.type === "header" && row.r.accessory === "switch"
                anchors.right: parent.right
                anchors.rightMargin: p.m.inset
                y: p.m.switchCentre - (item ? item.height / 2 : 0)
                sourceComponent: Switch {
                    controlSize: "regular"
                    checked: row.r.on
                    enabled: row.r.enabled
                    onToggled: p.switchToggled(checked)
                }
            }

            Rectangle {
                visible: row.r.type === "divider"
                x: p.m.inset
                y: row.r.lineY || 0
                width: p.width - 2 * p.m.inset
                height: Pixel.stroke(1, p.dpr)   // exact, antialiased at a fractional scale like the Mac's downsample (HyprK pixel.js)
                antialiasing: Pixel.soft(p.dpr)
                color: p.lineColor
                layer.enabled: p.plus && visible
                layer.effect: PlusLift { lift: p.lineLift }
            }

            // list title (M: SF 12 Semibold, secondary: "Known Network" ink 91.5 wide); Other Networks has a chevron
            Text {
                visible: row.r.type === "title"
                x: p.m.inset
                anchors.baseline: parent.top
                anchors.baselineOffset: p.m.titleBaseline
                text: row.r.title || ""
                font: Typography.font(12, Typography.semibold)
                color: p.secondary
                layer.enabled: p.plus && visible
                layer.effect: PlusLift {}
            }
            Symbol {   // M: ink 5.5 x 10 with its right edge 15 from the panel's, secondary; down when open (GUESS)
                visible: row.r.type === "title" && row.r.disclosure === true
                anchors.right: parent.right
                anchors.rightMargin: p.m.inset - 2
                anchors.verticalCenter: parent.verticalCenter
                name: row.r.expanded ? "chevron.down" : "chevron.right"
                size: 14
                pointSize: 12
                color: p.secondary
                layer.enabled: p.plus && visible
                layer.effect: PlusLift {}
            }
            MouseArea {
                enabled: row.r.type === "title" && row.r.disclosure === true
                anchors.fill: parent
                onClicked: p.disclosureToggled()
            }

            // M: the hovered row's rounded rectangle, 7 in, r 10, the row's 32. The footer link: GUESS the same, centred on
            // its 22 pt button (not hovered on the shots)
            Rectangle {
                visible: (row.r.type === "toggle" || row.r.type === "footer") && rowMa.containsMouse && row.r.enabled !== false
                x: p.m.hoverInset
                y: row.r.type === "footer" ? row.r.baseline - 21 : 0
                width: p.width - 2 * p.m.hoverInset
                height: p.m.rowH
                radius: p.m.hoverRadius
                color: p.rowHover
                layer.enabled: p.plus && visible
                layer.effect: PlusLift { lift: p.lineLift }
            }
            Item {
                visible: row.r.type === "toggle"
                x: p.m.inset
                anchors.verticalCenter: parent.verticalCenter
                width: p.m.disc; height: width
                opacity: row.r.enabled === false ? 0.5 : 1   // GUESS: no disabled row on the Mac shots
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    // M: on, the accent (Wi-Fi connected: 0,136,255 sRGB) with a white glyph; off, the line's step with a
                    // secondary glyph (VIBRANCY-REA.md: the glyph is 80 over the off disc, so the glass + 100, in dark).
                    // A Focus mode on (R4.2, Driving): its own colour, (97,84,244) light / (109,124,255) dark =
                    // systemIndigo (Do Not Disturb's too, names.json focusModes), white glyph
                    color: !row.r.on ? p.discOff : row.r.focus ? p.focusOn : Tokens.accent
                    layer.enabled: p.plus && !row.r.on && parent.visible
                    layer.effect: PlusLift { lift: p.lineLift }
                }
                Symbol {
                    id: discGlyph
                    readonly property bool quarter: row.r.symbol === "battery.25percent"
                    anchors.centerIn: parent
                    // battery.25percent is not in the extracted set: the empty outline and its level drawn below
                    name: quarter ? "battery.0percent" : row.r.symbol || ""
                    size: 20
                    // M: glyph inks within 0.5 at 13 pt (moon 13 x 13, car 15.5 x 12.5); the battery 19 x 9.5 at 13.5
                    pointSize: quarter ? 13.5 : 13
                    variableValue: row.r.level !== undefined ? row.r.level : -1
                    color: row.r.on ? "#FFFFFF" : p.secondary
                    layer.enabled: p.plus && !row.r.on && parent.visible
                    layer.effect: PlusLift {}
                    // M: the level, a quarter of the outline's inside (battery.0percent.regular's inner path x 6.51..42.71,
                    // y 6.38..22.47 at 32 units), flush with its left edge, drawn lighter than the outline (about 75 % of
                    // its step over the disc on the Low Power shot)
                    Rectangle {
                        visible: discGlyph.quarter
                        x: discGlyph.origin.x + 6.51 * discGlyph.unit
                        y: discGlyph.origin.y + 6.38 * discGlyph.unit
                        width: (42.71 - 6.51) * 0.25 * discGlyph.unit
                        height: (22.47 - 6.38) * discGlyph.unit
                        topLeftRadius: 6.3 * discGlyph.unit
                        bottomLeftRadius: 6.3 * discGlyph.unit
                        color: discGlyph.color
                        opacity: 0.75
                    }
                }
            }
            Symbol {   // M: the known network's lock, ink 8.5 x 12.5 ending at x 291.5 (2.5 inside the 14 inset), secondary
                visible: row.r.type === "toggle" && row.r.lock === true
                anchors.right: parent.right
                anchors.rightMargin: p.m.inset - 1   // the 16 box's right edge 3.65 past the 8.7 pt ink at 13 pt
                anchors.verticalCenter: parent.verticalCenter
                name: "lock.fill"
                size: 16
                pointSize: 13
                color: p.secondary
                layer.enabled: p.plus && visible
                layer.effect: PlusLift {}
            }
            Text {
                visible: row.r.type === "toggle" || row.r.type === "label" || row.r.type === "note" || row.r.type === "footer"
                x: row.r.type === "toggle" ? p.m.textX : p.m.inset
                width: parent.width - x - p.m.inset - (row.r.lock ? 20 : 0)
                anchors.baseline: parent.top
                anchors.baselineOffset: row.r.type === "label" ? p.m.labelBaseline
                                      : row.r.type === "note" ? p.m.titleBaseline
                                      : row.r.type === "footer" ? row.r.baseline
                                      : row.r.h / 2 + p.m.rowBaseline
                text: row.r.title || ""
                elide: Text.ElideRight
                // M: rows and the footer SF 13 Regular ("Do Not Disturb" 88.5 wide), primary; the Battery state lines
                // SF 12 Regular ("Power Source: Power Adapter" 166.5), secondary. "No Apps Using Significant Energy":
                // GUESS the state lines' style (not on the shots)
                font: Typography.font(row.r.type === "label" || row.r.type === "note" ? 12 : Theme.font.ccModuleRow)
                color: row.r.type === "label" || row.r.type === "note" ? p.secondary : p.primary
                opacity: row.r.enabled === false ? 0.45 : 1   // GUESS: a disabled row's dimming (none on the Mac shots)
                layer.enabled: p.plus && visible && (row.r.type === "label" || row.r.type === "note")
                layer.effect: PlusLift {}
            }
            MouseArea {
                id: rowMa
                enabled: (row.r.type === "toggle" || row.r.type === "footer") && row.r.enabled !== false
                y: row.r.type === "footer" ? row.r.baseline - 21 : 0
                width: parent.width
                height: row.r.type === "footer" ? p.m.rowH : parent.height
                hoverEnabled: true
                onClicked: row.r.type === "footer" ? p.settingsRequested(row.r.action) : p.rowActivated(row.r)
            }
        }
    }
}
