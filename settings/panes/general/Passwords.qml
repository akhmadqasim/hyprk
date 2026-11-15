import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// General > AutoFill & Passwords (27.2.1, MAC-ANSWERS-13.md R13.4, live/settings-r13/nav-general--passwords-light.png,
// ax-nav-general--passwords-light.jsonl): the tile "All Your Passwords in One Place" (a close button, "Open
// Passwords"), then AutoFill Passwords and Passkeys, "AutoFill from" (Passwords), "Verification Codes" (Delete After
// Use, Set Up Codes In). No password store here: the switches keep their own state, the close button hides the tile
// as the Mac's Dismiss does, "Open Passwords" takes the press only (settings/FALLBACKS.md "General").
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    readonly property string icon: Backend.appIconUrl("", "", Theme.iconLook, "Passwords")
    component R: FormRow { sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14 }
    Rectangle {
        id: promo
        objectName: "passwordsPromo"
        width: parent.width; height: 114.5
        radius: Theme.content.cardRadius; color: Theme.cardFill; border.color: Theme.cardStroke
        PaneIcon { x: 10; y: 19; size: 26; imageSource: page.icon }
        MacText { x: 47; y: 14; text: "All Your Passwords in One Place"; weight: Typography.semibold }
        Text {
            x: 47; y: 31.5; width: 381; wrapMode: Text.WordWrap
            lineHeight: 14; lineHeightMode: Text.FixedHeight
            text: "Passwords, passkeys and verification codes are safely stored in the new Passwords app and are available to use in Safari and other apps."
            font: Typography.subheadline; color: Theme.secondaryLabel
        }
        Item {
            objectName: "passwordsDismiss"
            x: 444; y: 10; width: 14; height: 13
            SfSymbol { anchors.centerIn: parent; name: "xmark"; pointSize: 10; color: Theme.tertiaryLabel }
            MouseArea { anchors.fill: parent; anchors.margins: -5; onClicked: promo.visible = false }
        }
        Rectangle { x: 47; y: 72; width: parent.width - 57; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
        Button { anchors.right: parent.right; anchors.rightMargin: 10; y: 80.5; text: "Open Passwords" }
    }
    Item { visible: promo.visible; width: 1; height: 28 }   // the Mac leaves 48 pt under the tile (ax 178.5 to 226.5)
    Card {
        R {
            label: "AutoFill Passwords and Passkeys"
            sublabel: "Automatically suggest passwords, passkeys and verification codes when signing in to apps and websites."
            LocalSwitch { objectName: "passwordsAutoFill"; checked: true }
        }
    }
    Card {
        title: "AutoFill from"
        FormRow {
            implicitHeight: 52
            iconSource: page.icon; iconSize: 26; iconX: 10; labelGap: 11
            label: "Passwords"; sublabel: "Passkeys, passwords and codes"; sublabelGap: 2
            LocalSwitch { checked: true; anchors.verticalCenter: parent.verticalCenter }
        }
    }
    Card {
        title: "Verification Codes"
        R {
            label: "Delete After Use"
            sublabel: "Automatically delete verification codes in Messages and Mail after they are used."
            LocalSwitch { checked: true }
        }
    }
    Card {
        R {
            label: "Set Up Codes In"
            sublabel: "“Passwords” will be used to open links and QR codes for setting up verification codes."
            LocalPopup { objectName: "passwordsCodesIn"; model: ["Passwords"] }
        }
    }
}
