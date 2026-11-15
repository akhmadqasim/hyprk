import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "PrivacyData.js" as PD

// Privacy & Security > Analytics & Improvements (27.2.1, dest-privacyAndSecurity--analytics-improvements-*.png,
// ax-dest-...): the line, five switches with their texts (the Mac's values), then "About Device Analytics & Privacy…".
// Nothing is sent from here: the switches keep their own state (settings/FALLBACKS.md "Privacy & Security").
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap
    // 8.5 pt above the name and under the text; the rows' heights are the Mac's pitches (ax: 123.1 / 200.1 / 277.1 /
    // 368.1 / 431.1)
    component R: FormRow { sublabelPad: 16; sublabelGap: 2; sublabelLineHeight: 14 }
    Card {
        Item {
            width: parent.width; height: 50.5
            Text {
                x: 10; y: 10; width: 414; wrapMode: Text.WordWrap
                lineHeight: 16; lineHeightMode: Text.FixedHeight
                text: "Help Apple and app developers improve their products and services automatically."
                font: Typography.body; color: Theme.secondaryLabel
            }
        }
        R { implicitHeight: 77; label: "Share Mac Analytics"; sublabel: "Help Apple improve its products and services by automatically sending diagnostics and usage data.\nDiagnostic data may include locations."; LocalSwitch { objectName: "analyticsMac"; checked: true } }
        R { implicitHeight: 77; label: "Improve Siri & Dictation"; sublabel: "Help Apple improve Siri and Dictation by sharing the audio recordings and transcripts of your interactions with Siri, Dictation and Translate from this device."; LocalSwitch {} }
        R { implicitHeight: 91; label: "Improve Assistive Voice Features"; sublabel: "Help Apple improve assistive voice features by sharing audio recordings and transcripts of your Vocal Shortcuts and Voice Control interactions. This information is sent only with your consent and is submitted anonymously to Apple."; LocalSwitch {} }
        R { implicitHeight: 63; label: "Share with app developers"; sublabel: "Help app developers improve their applications by allowing Apple to share crash and usage data with them."; LocalSwitch { checked: true } }
        R { implicitHeight: 77; label: "Share iCloud Analytics"; sublabel: "Help Apple improve its products and services, including Siri and other intelligent features, by allowing analytics of usage and data from your iCloud account."; LocalSwitch { checked: true } }
        CardButtons { Button { text: "About Device Analytics & Privacy…" } }
    }
}
