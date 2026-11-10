import QtQuick
import "../.."
import "../../controls"

// Accessibility > Captions: the style list is a preview; Prefer closed captions is saved.
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap
    property int style: 0

    Card {
        title: "Style"
        Repeater {
            model: ["Default", "Transparent Background", "Large Text", "Classic", "Outline Text"]
            FormRow {
                required property string modelData
                required property int index
                label: modelData
                onClicked: page.style = index
                Text {
                    visible: page.style === index
                    anchors.verticalCenter: parent.verticalCenter
                    text: "check"; font.family: Theme.fontGlyph; font.pixelSize: 18; color: Theme.accent
                }
            }
        }
    }
    PaneFooter { help: false; MacButton { text: "+"; enabled_: false } MacButton { text: "−"; enabled_: false } }
    Card {
        FormRow {
            label: "Prefer closed captions and SDH"
            sublabel: "Use closed captions or SDH subtitles instead of standard subtitles when available."
            MacSwitch { checked: page.ctl.a.preferSdh; onToggled: on => page.ctl.set({ preferSdh: on }) }
        }
    }
    PaneFooter {}
}
