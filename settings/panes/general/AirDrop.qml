import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// General > AirDrop & Continuity (27.2.1, live/settings-r12/nav-general--airDropAndHandoff-dark.png, ax-nav-...): four
// headed cards, the Mac's values (no AirDrop, Handoff, iPhone or AirPlay backend: settings/FALLBACKS.md "General").
// The pop-ups show the Mac's value only: their other items are not on a shot. Not here: the "iPhone" row (the Mac's
// own phone, redacted).
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    component R: FormRow { sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14 }
    Card {
        objectName: "airdropCard"
        visible: AppState.hw.airdrop   // AirDrop needs Wi-Fi and Bluetooth: without both the card is not shown
        title: "AirDrop"
        R { label: "AirDrop"; sublabel: "AirDrop lets you share instantly with people nearby. You can be discoverable in AirDrop to receive from everyone or only people in your contacts."; LocalPopup { model: ["Contacts Only"] } }
        R { label: "Known AirDrop Contacts"; sublabel: "You will automatically appear for 30 days to people you have shared a single-use code with."; Button { text: "Manage…" } }
        CardButtons { Button { text: "About AirDrop & Privacy…" } }
    }
    Card {
        title: "Continuity"
        R { label: "Allow Handoff between this Mac and your iCloud devices"; LocalSwitch { checked: true } }
    }
    Card {
        title: "Widgets & iPhone Mirroring"
        R { label: "iPhone Widgets"; LocalSwitch { checked: true } }
        R { implicitHeight: 37; label: "Notifications & Live Activities"; NavChevron {} }
    }
    Card {
        title: "AirPlay"
        R { label: "AirPlay Receiver"; sublabel: "AirPlay Receiver allows nearby Apple devices to send video and audio content to your Mac with AirPlay."; LocalSwitch { checked: true } }
        R { label: "Allow AirPlay for"; sublabel: "Only devices signed in to your Apple Account can see and AirPlay to this computer."; LocalPopup { model: ["Current User"] } }
        R { label: "Require password"; LocalSwitch { checked: true; anchors.verticalCenter: parent.verticalCenter } Button { text: "Set…" } }
    }
    PaneFooter {}
}
