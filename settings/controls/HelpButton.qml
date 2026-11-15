import QtQuick
import ".."
import "../HyprK"

// Round "?" help button at the bottom right of most panes: 24 pt (AX "Help" 24 x 24 in every pane; its disc is 48 px
// at 2x on live/settings-r12/acc-zoom-00-{dark,light}.png, px 1392..1439 x 805..852).
Rectangle {
    width: 24; height: 24; radius: 12
    color: Theme.controlFill
    border.color: Theme.cardStroke
    // the "?": 13 pt, or the size measured where it is (General > Software Update: ink 7.5 x 12.5 pt on
    // live/settings-r12/nav-general--softwareUpdate-dark.png, 16 pt)
    property real glyphSize: 13
    MacText { anchors.centerIn: parent; text: "?"; size: parent.glyphSize; weight: Typography.medium; color: Theme.label }
    // the pane's topic in the macOS User Guide (the anchor its extension passes to NSHelpManager; the Mac opens it in its
    // help viewer, here the same topic of the guide's web edition). Without a decoded anchor the button does nothing.
    property string helpAnchor: ""
    MouseArea {
        anchors.fill: parent
        enabled: parent.helpAnchor !== ""
        onClicked: Qt.openUrlExternally("https://support.apple.com/guide/mac-help/" + parent.helpAnchor + "/mac")
    }
}
