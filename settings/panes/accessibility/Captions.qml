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
                SfSymbol {   // Image(systemName: "checkmark").fontWeight(.semibold) and no font of its own = the body size:
                    // AccessibilitySettingsUI 27.2.1, the three checkmark rows (0x25ecbea68, 0x25ecbfb1c, 0x25ed06cb8)
                    visible: page.style === index
                    anchors.verticalCenter: parent.verticalCenter
                    name: "checkmark"; weight: "semibold"; pointSize: 13; color: Theme.accent
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
