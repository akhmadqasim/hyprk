import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "PrivacyData.js" as PD

// Privacy & Security > Background Security Improvements (27.2.1, dest-privacyAndSecurity--background-security-
// improvements-*.png, ax-dest-...): "Automatically Install" (on) with two paragraphs and a link. No such updates
// here: the switch keeps its own state.
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap
    Card {
        FormRow {
            label: "Automatically Install"
            sublabel: "Background Security Improvements provides additional protection to your Mac in between software updates.\n\nIn rare instances of compatibility issues, these security improvements may be temporarily removed and then enhanced in a future software update.\n"
            sublink: "Learn more…"
            sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
            LocalSwitch { objectName: "backgroundSecuritySwitch"; checked: true }
        }
    }
}
