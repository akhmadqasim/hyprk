import QtQuick
import qs
import qs.components
import qs.HyprK
import "../lib/statusmodule.js" as SM

// A menu bar status item's module (macOS 27.2.1 ControlCenter.app ModuleStack: Wi-Fi, Battery, Focus), drawn from the
// rows lib/statusmodule.js builds. Sizes and their sources: lib/statusmodule.js and
// reference/re/27.2.1/STATUS-REA-27.2.1.md. Glass, colours and the row look are the Sound module's
// (CcSoundPanel.qml: same Module class, same 308 width): one glass panel of the tiles' family, continuous r 16.
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

    Glass {
        anchors.fill: parent
        radius: Theme.cc.modulePanelRadius
        sx: p.originX
        sy: p.originY
        tint: Theme.cc.tileTint
        solidColor: Theme.cc.tileSolid
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

            // header: title, then a switch or the text accessory at the right
            Text {
                visible: row.r.type === "header"
                x: p.m.inset
                anchors.baseline: parent.top
                anchors.baselineOffset: p.m.headerBaseline
                text: row.r.title || ""
                font: Typography.font(Theme.font.ccModuleTitle, Typography.bold)
                color: Theme.cc.text
            }
            Text {   // GUESS: weight and colour (the Battery header's percentage, C: a Text accessory)
                visible: row.r.type === "header" && row.r.accessory === "text"
                anchors.right: parent.right
                anchors.rightMargin: p.m.inset
                anchors.baseline: parent.top
                anchors.baselineOffset: p.m.headerBaseline
                text: row.r.text || ""
                font: Typography.font(Theme.font.ccModuleRow)
                color: Theme.cc.moduleHeader
            }
            Loader {   // C: ModuleSwitchToggle = SwiftUI SwitchToggleStyle; its size is not decoded (GUESS: HyprK default)
                active: row.r.type === "header" && row.r.accessory === "switch"
                anchors.right: parent.right
                anchors.rightMargin: p.m.inset
                y: p.m.headerBaseline - 5 - (item ? item.height / 2 : 0)
                sourceComponent: Switch {
                    checked: row.r.on
                    enabled: row.r.enabled
                    onToggled: p.switchToggled(checked)
                }
            }

            Rectangle {
                visible: row.r.type === "divider"
                x: p.m.inset
                y: p.m.dividerLine
                width: p.width - 2 * p.m.inset
                height: 1
                color: Theme.cc.moduleSeparator
            }

            // list title ("Known Network", "Other Networks"); Other Networks has a disclosure chevron
            Text {
                visible: row.r.type === "title"
                x: p.m.inset
                anchors.baseline: parent.top
                anchors.baselineOffset: p.m.titleBaseline
                text: row.r.title || ""
                font: Typography.font(Theme.font.ccModuleTitle, Typography.bold)
                color: Theme.cc.moduleHeader
            }
            Symbol {   // GUESS: glyph and size (ModuleStackDisclosureIndicator is not decoded)
                visible: row.r.type === "title" && row.r.disclosure === true
                anchors.right: parent.right
                anchors.rightMargin: p.m.inset
                anchors.verticalCenter: parent.verticalCenter
                name: row.r.expanded ? "chevron.down" : "chevron.right"
                size: 12
                color: Theme.cc.moduleHeader
            }
            MouseArea {
                enabled: row.r.type === "title" && row.r.disclosure === true
                anchors.fill: parent
                onClicked: p.disclosureToggled()
            }

            // toggle row, label row, footer link: hover capsule 5 in (the Sound module), disc, text
            Rectangle {
                visible: (row.r.type === "toggle" || row.r.type === "footer") && rowMa.containsMouse && row.r.enabled !== false
                x: Theme.cc.soundRowInset
                width: p.width - 2 * Theme.cc.soundRowInset
                height: p.m.rowH
                radius: height / 2
                color: Theme.cc.moduleRowHover
            }
            Rectangle {
                visible: row.r.type === "toggle"
                x: p.m.inset
                anchors.verticalCenter: parent.verticalCenter
                width: p.m.disc; height: width; radius: width / 2
                // on: white disc, glyph in the accent (Focus: the mode's colour, Q-panels-02); off: white .25
                color: row.r.on ? Theme.cc.toggleOnBg : Theme.cc.capsuleOffBg
                opacity: row.r.enabled === false ? 0.5 : 1
                Symbol {
                    anchors.centerIn: parent
                    name: row.r.symbol || ""
                    size: 18; pointSize: Theme.cc.soundDeviceGlyph
                    variableValue: row.r.level !== undefined ? row.r.level : -1
                    color: !row.r.on ? Theme.cc.toggleOffIcon
                         : row.r.focus ? Theme.cc.focusOnIcon : Theme.cc.toggleOnIcon
                }
            }
            Text {
                visible: row.r.type === "toggle" || row.r.type === "label" || row.r.type === "footer"
                x: row.r.type === "toggle" ? p.m.textX : p.m.inset
                width: parent.width - x - p.m.inset
                anchors.baseline: parent.top
                anchors.baselineOffset: (row.r.type === "footer" ? p.m.rowH : row.r.h) / 2 + p.m.rowBaseline
                text: row.r.title || ""
                elide: Text.ElideRight
                font: Typography.font(Theme.font.ccModuleRow)
                color: Theme.cc.text
                opacity: row.r.enabled === false ? 0.45 : 1   // GUESS: a disabled row's dimming
            }
            MouseArea {
                id: rowMa
                enabled: (row.r.type === "toggle" || row.r.type === "footer") && row.r.enabled !== false
                y: 0
                width: parent.width
                height: row.r.type === "footer" ? p.m.rowH : parent.height
                hoverEnabled: true
                onClicked: row.r.type === "footer" ? p.settingsRequested(row.r.action) : p.rowActivated(row.r)
            }
        }
    }
}
