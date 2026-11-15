import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// Privacy & Security > Screen & System Audio Recording (27.2.1, dest-privacyAndSecurity--screen-system-audio-recording-
// *.png, ax-dest-...): two headed lists with a + / − strip: the applications (40 pt rows with a switch on the Mac) and
// "System Audio Recording Only" ("No Items", 24 pt). The Mac's applications are blurred / redacted on every capture, so
// none is listed: the first list shows what the Mac's empty second list shows, "No Items".
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap
    Card {
        title: "Screen & System Audio Recording"
        subtitle: "Allow the applications below to record the content of your screen and audio, even while using other applications."
        subtitleLineHeight: 14
        Item {
            width: parent.width; height: 24
            MacText { anchors.centerIn: parent; text: "No Items"; color: Theme.secondaryLabel }
        }
        ListBar {}
    }
    Card {
        title: "System Audio Recording Only"
        subtitle: "Allow the applications below to access and record your system audio."
        Item {
            width: parent.width; height: 24
            MacText { anchors.centerIn: parent; text: "No Items"; color: Theme.secondaryLabel }
        }
        ListBar {}
    }
}
