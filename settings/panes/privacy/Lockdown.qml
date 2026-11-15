import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "PrivacyData.js" as PD

// Privacy & Security > Lockdown Mode (27.2.1, dest-privacyAndSecurity--lockdown-mode-*.png, ax-dest-...): the tile, the
// name and its text with a link, "Turn On…" at the right (not pressed on the Mac: it changes the system).
// The still, 2x: the tile at 11..37 pt across and 12 pt under the card's top (px 526..577, 152..203), the name 10 pt
// under the top (AX 224 in the card at 214) and 11 pt after the tile; the text is 314 pt wide in five lines (AX
// 650..964, the button at 977), so it wraps 12 pt before the button, not 10.
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap
    Card {
        FormRow {
            iconId: "privacy"; iconSize: 26; alignTop: true; topY: 10; iconY: 12; iconX: 11; labelGap: 11; sublabelWidth: 315
            label: "Lockdown Mode"
            sublabel: "Lockdown Mode offers the strongest protection for your Mac and data by reducing your exposure to current and future digital threats. This is intended for anyone in high-risk situations, such as journalists, activists, leaders, public figures and abuse survivors."
            sublink: "Learn more…"
            sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
            Button { text: "Turn On…" }
        }
    }
}
