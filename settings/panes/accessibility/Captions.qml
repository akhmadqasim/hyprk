import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

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
                SfSymbol {   // checkmark at the body size (this list is not on a Mac shot: the size is not measured)
                    visible: page.style === index
                    anchors.verticalCenter: parent.verticalCenter
                    name: "checkmark"; pointSize: 13; color: Theme.accent
                }
            }
        }
    }
    PaneFooter { help: false; Button { text: "+"; enabled: false } Button { text: "−"; enabled: false } }
    Card {
        FormRow {
            label: "Prefer closed captions and SDH"
            sublabel: "Use closed captions or SDH subtitles instead of standard subtitles when available."
            Switch { checked: page.ctl.a.preferSdh; onToggled: on => page.ctl.set({ preferSdh: on }) }
        }
    }
    PaneFooter {}
}
