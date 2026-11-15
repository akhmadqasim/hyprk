import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// Network > Firewall (27.2.1, live/settings-r13/dest-network--firewall-*.png, dest-network--firewall--options-*.png
// and their AX dumps): the placard row with the switch (on, the Mac's value; its text 326 pt wide), Options… and Help.
// Options…: a 500 x 532 sheet at y 52: Block all incoming connections; the applications with an Allow / Block pop-up
// each; three more switches below; Cancel and OK. The list (MAC-ANSWERS-14.md R14.2, ax-dest-network--firewall--
// options-*.jsonl): a 460 pt card of 32 pt rows (40 when the name takes two lines: AX row 6), the 16 pt icon 10 in and
// 4 down, the name 28 in, the pop-up right-aligned 10 pt from the end (233.5 x 24 on the Mac), a hairline under each
// row from the name's x, then the + / − strip. The rows are the Mac's four Apple entries R14.2 names (its other 36
// are redacted): their places in the list (0, 1, 2 and the two-line row 6) follow from the AX widths of the names,
// all four "Allow incoming connections"; the icons are the Mac's own, cut from dest-network--firewall--options-
// {dark,light}.png (rows 2 and 6; the first two are under the blur and drawn as the exec tile R14.2 describes).
// No firewall backend: the values are kept while the pane is open. The placard's text while the firewall is off was
// not captured (R14.1): it is the extension's own string for that state (Network.appex Localizable.loctable, en:
// FIREWALL_EXPLANATORY_TEXT_OFF), as the other texts here are its en strings (settings/FALLBACKS.md).
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    Card {
        FormRow {
            iconId: "network-firewall"; iconSize: 26; labelGap: 12
            sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
            label: "Firewall"
            // Network.appex Localizable.loctable (en): FIREWALL_EXPLANATORY_TEXT_LIMITED / _OFF
            sublabel: page.pane.firewallOn ? "The firewall is turned on and set up to prevent unauthorized applications, programs, and services from accepting incoming connections."
                                           : "This computer’s firewall is currently turned off. All incoming connections to this computer are allowed."
            Item { width: 74 - 8 - sw.width; height: 1 }
            // the placard's switch is the small one, 44 x 20 (dest-network--firewall-*.png: 88 x 40 px; the form rows' is mini)
            Switch { id: sw; objectName: "firewallSwitch"; controlSize: "small"; checked: page.pane.firewallOn; onToggled: on => page.pane.firewallOn = on }
        }
    }
    PaneFooter { Button { objectName: "firewallOptionsButton"; text: "Options…"; onClicked: options.open() } }

    SubSheet {
        id: options
        objectName: "firewallOptions"
        sheetWidth: 500; sheetHeight: 532; sheetTop: 52
        footer: false
        readonly property var apps: [{ name: "AirPlayXPCHelper", art: "exec" }, { name: "audioclocksyncd", art: "exec" },
                                     { name: "avconferenced", art: "exec" }, { name: "com.apple.WebKit.Networking", art: "document" }]
        Flickable {
            width: 500; height: 467
            clip: true
            contentHeight: col.height + 40
            boundsBehavior: Flickable.StopAtBounds
            acceptedButtons: Qt.NoButton
            Column {
                id: col
                x: 20; y: 20; width: 460
                spacing: Theme.content.sectionGap
                Card {
                    FormRow {
                        sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                        label: "Block all incoming connections"
                        sublabel: "Blocks all incoming connections except those required for basic Internet services, such as DHCP and IPSec."
                        LocalSwitch {}
                    }
                }
                Card {
                    objectName: "firewallApps"
                    Repeater {
                        model: options.apps
                        Item {
                            id: app
                            required property var modelData
                            required property int index
                            objectName: "firewallApp" + index
                            width: parent.width; height: name.lineCount > 1 ? 40 : 32
                            Image {
                                objectName: "firewallAppIcon"
                                x: 10; y: 4; width: 16; height: 16
                                source: "../../assets/firewall/" + app.modelData.art + (Theme.dark ? "-dark.png" : "-light.png")
                            }
                            MacText {
                                id: name
                                objectName: "firewallAppName"
                                x: 28; y: 4; width: pop.x - 28 - 21.5   // AX: the two-line name is 167 pt wide, the pop-up 216.5 in
                                wrapMode: Text.Wrap; maximumLineCount: 2
                                lineHeight: 16; lineHeightMode: Text.FixedHeight
                                text: app.modelData.name
                            }
                            LocalPopup {
                                id: pop
                                objectName: "firewallAppPopup"
                                anchors.right: parent.right; anchors.rightMargin: 10; y: 4
                                model: ["Allow incoming connections", "Block incoming connections"]
                                dots: [Theme.tile.green, Theme.tile.red]
                                dotSize: 10; dotGap: 6
                            }
                            Rectangle { visible: app.index < options.apps.length - 1; x: 28; y: parent.height - height; width: parent.width - 28; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
                        }
                    }
                    ListBar {}
                }
                Card {
                    FormRow { implicitHeight: 53; label: "Automatically allow built-in software to receive incoming connections"; LocalSwitch { checked: true } }   // a 2-line label: 10 pt above and below
                    FormRow {
                        sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                        label: "Automatically allow downloaded signed software to receive incoming connections"
                        sublabel: "Allows software signed by a valid certificate authority to provide services accessed from the network."
                        LocalSwitch { checked: true }
                    }
                    FormRow {
                        sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                        label: "Enable stealth mode"
                        sublabel: "Don’t respond to or acknowledge attempts to access this computer from the network by test applications using ICMP, such as Ping."
                        LocalSwitch {}
                    }
                }
            }
        }
        Rectangle { y: 467; width: 500; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
        Button { objectName: "firewallOptionsCancel"; x: 340; y: 488; width: 66; text: "Cancel"; onClicked: options.close() }
        Button { objectName: "firewallOptionsOK"; x: 414; y: 488; width: 66; text: "OK"; primary: true; onClicked: options.close() }
        Shortcut { sequences: ["Return", "Enter"]; enabled: options.shown; onActivated: options.close() }
    }
}
