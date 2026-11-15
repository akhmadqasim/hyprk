import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "PrivacyData.js" as PD

// Privacy & Security > FileVault (27.2.1, dest-privacyAndSecurity--filevault-*.png, ax-dest-...): the tile, the name and
// its line with a switch (on, the Mac's value), then "Password Reset" with its line and the Recovery Key row (Show:
// not pressed on the Mac, it asks for the password). No disk encryption backend: the switch keeps its own state.
// The still, 2x: the tile at 11..37 pt in the card and the text 11 pt after it (px 526..577, text from 600); "Password
// Reset" in the regular weight (ink 5.94 a row against 7.11 for the bold heading, JUDGE-95-24), unlike Focus' headings.
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap
    Card {
        FormRow {
            iconId: "privacy-filevault"; tint: Theme.tile.black; iconSize: 26; iconX: 11; labelGap: 11
            label: "FileVault"
            sublabel: "FileVault secures your data by encrypting the contents of your Mac and locking your screen with a password."
            sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
            LocalSwitch { objectName: "filevaultSwitch"; checked: true; anchors.verticalCenter: parent.verticalCenter }
        }
    }
    Card {
        title: "Password Reset"
        titleRegular: true
        subtitle: "If you forget the password for this Mac, you can reset it using your recovery key. You can view your recovery key on any device with iCloud Keychain turned on."
        subtitleLineHeight: 14
        FormRow { implicitHeight: 44; label: "Recovery Key"; Button { text: "Show" } }
    }
}
