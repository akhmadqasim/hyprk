import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// Privacy & Security > Location Services (27.2.1, live/settings-r13/dest-privacyAndSecurity--location-services-*.png,
// ax-dest-...): the main switch with its line, then the applications (43 pt rows on the Mac: blurred / redacted on every
// capture, so none is listed here), "System Services" with Details…, and the legend of the location arrow. Details… is a sheet 470 x 533 at y 52: its services are redacted on the capture, so only the row that is
// readable is drawn ("Show location icon in Control Center when System Services request your location", at its place).
// No location backend: the switches keep their own state (settings/FALLBACKS.md "Privacy & Security").
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap
    Card {
        FormRow {
            label: "Location Services"
            sublabel: "Allow the applications and services below to determine your location."
            sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
            LocalSwitch { objectName: "locationMain"; controlSize: "small"; checked: true }   // the placard's: 44 x 20 (88 x 40 px on the Mac)
        }
        FormRow {
            implicitHeight: 44
            iconId: "privacy-location"
            label: "System Services"
            Button { objectName: "locationDetailsButton"; text: "Details…"; onClicked: details.open() }
        }
        Item {
            width: parent.width; height: 37
            Rectangle { x: 10; width: parent.width - 20; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            SfSymbol { x: 12; anchors.verticalCenter: parent.verticalCenter; name: "location.fill"; pointSize: 11; color: Theme.dark ? "#DB34F2" : "#CB30E0" }
            Text { x: 33.5; anchors.verticalCenter: parent.verticalCenter; text: "Indicates an application that has used your location within the last 24 hours."; font: Typography.subheadline; color: Theme.secondaryLabel }
        }
    }
    PaneFooter {}
    SubSheet {
        id: details
        objectName: "locationDetails"
        sheetWidth: 470; sheetHeight: 533; sheetTop: 52
        Column {
            x: 20; y: 412; width: 430
            Card {
                FormRow {
                    label: "Show location icon in Control Center when System Services request your location"
                    LocalSwitch {}
                }
            }
        }
    }
}
