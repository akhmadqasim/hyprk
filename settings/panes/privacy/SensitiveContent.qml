import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "PrivacyData.js" as PD

// Privacy & Security > Sensitive Content Warning (27.2.1, dest-privacyAndSecurity--sensitive-content-warning-*.png,
// ax-dest-...): the tile, the name and its text with a link, a large switch (off); then "Safety Resources" with its
// line and link. No such feature here: the switch keeps its own state (settings/FALLBACKS.md "Privacy & Security").
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap
    Card {
        FormRow {
            iconId: "privacy-sensitive"; tint: Theme.tile.black; iconSize: 26; alignTop: true
            label: "Sensitive Content Warning"
            sublabel: "Detect photos and videos containing nudity, gore and violence before they are viewed on your Mac, and receive guidance to help make a safe choice. Apple does not have access to the photos or videos."
            sublink: "Learn more…"
            sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
            LocalSwitch { objectName: "sensitiveSwitch" }
        }
    }
    Card {
        FormRow {
            label: "Safety Resources"
            sublabel: "Resources to help you make a safe choice when receiving photos or videos containing nudity."
            sublink: "Learn more…"
            sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
        }
    }
}
