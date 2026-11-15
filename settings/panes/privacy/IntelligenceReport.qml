import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "PrivacyData.js" as PD

// Privacy & Security > Apple Intelligence Report (27.2.1, dest-privacyAndSecurity--apple-intelligence-report-*.png,
// ax-dest-...): Report Duration (a pop-up, "15 minutes": its other items are not on a shot), the line with its link,
// and Export Activity under the card. Nothing to report here: the controls take the press only.
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap
    Card {
        FormRow { label: "Report Duration"; LocalPopup { objectName: "aiReportDuration"; model: ["15 minutes"] } }
        Item {
            width: parent.width; height: 61
            Rectangle { x: 10; width: parent.width - 20; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            Text {
                x: 10; y: 3; width: 440; wrapMode: Text.WordWrap
                lineHeight: 16; lineHeightMode: Text.FixedHeight
                textFormat: Text.StyledText
                text: "This report is stored on device and may include personal data such as messages and text you enter in intelligent writing tools.<br><font color=\"" + Theme.accent + "\">About Apple Intelligence &amp; Privacy…</font>"
                font: Typography.body; color: Theme.secondaryLabel
            }
        }
    }
    Row { anchors.right: parent.right; Button { text: "Export Activity" } }   // ax 173: 10 under the card
}
