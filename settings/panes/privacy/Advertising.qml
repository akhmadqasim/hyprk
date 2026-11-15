import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "PrivacyData.js" as PD

// Privacy & Security > Apple Advertising (27.2.1, dest-privacyAndSecurity--apple-advertising-*.png, ax-dest-...): a
// card with the heading line, the text, "About Apple Advertising & Privacy…", the targeting line and "View Ad
// Targeting Information…"; then "Personalized Ads" with its line. The second button opens a sheet 500 x 400: a round
// close button, the title, and the Mac's line when it has nothing to show (as captured). No footer.
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap
    Card {
        Item {
            width: parent.width; height: 37
            MacText { x: 10; y: 10; text: "Apple Delivered Advertising" }
        }
        Item {
            width: parent.width; height: 91.5
            Rectangle { x: 10; width: parent.width - 20; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            Text {
                x: 10; y: 2; width: 448; wrapMode: Text.WordWrap
                lineHeight: 14; lineHeightMode: Text.FixedHeight
                text: "The Apple advertising platform does not share your personal information with third parties. It is designed to protect your privacy and does not follow you across apps and websites owned by other companies. You have control over how Apple uses your information."
                font: Typography.subheadline; color: Theme.secondaryLabel
            }
            Button { anchors.right: parent.right; anchors.rightMargin: 10; y: 64.5; text: "About Apple Advertising & Privacy…" }
        }
        Item {
            width: parent.width; height: 64.5
            Rectangle { x: 10; width: parent.width - 20; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            Text { x: 10; y: 10; text: "Ad targeting information is used by Apple to personalize your ad experience."; font: Typography.subheadline; color: Theme.secondaryLabel }
            Button { objectName: "adTargetingButton"; anchors.right: parent.right; anchors.rightMargin: 10; y: 30.5; text: "View Ad Targeting Information…"; onClicked: targeting.open() }
        }
    }
    Card {
        FormRow {
            label: "Personalized Ads"
            sublabel: "After Apple News or Stocks asks your permission to send you personalized ads, a setting will appear here reflecting your choice."
            sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
        }
    }
    SubSheet {
        id: targeting
        objectName: "adTargeting"
        sheetWidth: 500; sheetHeight: 400; sheetTop: 112
        footer: false
        Rectangle {
            objectName: "adTargetingClose"
            x: 15; y: 15; width: 42; height: 42; radius: 21
            color: Theme.dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06)
            SfSymbol { anchors.centerIn: parent; name: "xmark"; pointSize: 14; color: Theme.label }
            MouseArea { anchors.fill: parent; onClicked: targeting.close() }
        }
        Text { anchors.horizontalCenter: parent.horizontalCenter; y: 25.5; text: "Ad Targeting Information"; font: Typography.font(17, 590); color: Theme.label }
        Text { anchors.horizontalCenter: parent.horizontalCenter; y: 183; text: "Advertising information isn’t available right now. Try again later."; font: Typography.font(15, 400); color: Theme.label }
    }
}
