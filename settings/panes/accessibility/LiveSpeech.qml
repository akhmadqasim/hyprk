import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// Accessibility > Live Speech: type a phrase and have it spoken (spd-say).
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap
    readonly property bool can: ctl.hasSpeech

    Card {
        FormRow {
            label: "Type to speak"; dim: !page.can
            sublabel: page.can ? "Press Return or Speak to hear what you typed." : "Live Speech needs speech-dispatcher (spd-say)."
        }
        Item {
            width: parent.width; height: 44
            Rectangle {
                anchors.fill: parent; anchors.margins: 8
                radius: 6; color: Theme.windowBg; border.color: Theme.separator
                opacity: page.can ? 1 : 0.4
                TextInput {
                    id: phrase
                    TextMenu { target: phrase }   // the field editor's right-click menu (HyprK textmenu.js)
                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                    verticalAlignment: TextInput.AlignVCenter
                    enabled: page.can; clip: true
                    font: Typography.body
                    color: Theme.label
                    onAccepted: if (text !== "") page.ctl.speak(text)
                    Keys.onPressed: e => KeyBindings.handle(e, phrase)   // AppKit's text keys (HyprK keybindings.js)
                }
            }
        }
    }
    PaneFooter { Button { text: "Speak"; enabled: page.can; onClicked: if (phrase.text !== "") page.ctl.speak(phrase.text) } }
}
