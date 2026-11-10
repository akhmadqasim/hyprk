import QtQuick
import ".."
import "../controls"
import "../HyprK"

Column {
    spacing: Theme.content.sectionGap
    Card {
        title: "Privacy"
        FormRow { glyph: "near_me"; tint: Theme.tile.blue; label: "Location Services" }
        FormRow { glyph: "contacts"; tint: Theme.tile.gray; label: "Contacts" }
        FormRow { glyph: "calendar_month"; tint: Theme.tile.red; label: "Calendars" }
        FormRow { glyph: "photo_library"; tint: Theme.tile.orange; label: "Photos" }
        FormRow { glyph: "mic"; tint: Theme.tile.orange; label: "Microphone" }
        FormRow { glyph: "videocam"; tint: Theme.tile.green; label: "Camera" }
        FormRow { glyph: "screen_share"; tint: Theme.tile.purple; label: "Screen & System Audio Recording" }
        FormRow { glyph: "folder"; tint: Theme.tile.blue; label: "Files & Folders" }
        FormRow { glyph: "accessibility_new"; tint: Theme.tile.blue; label: "Accessibility" }
    }
    Card {
        title: "Security"
        FormRow { label: "Allow applications from"; LocalPopup { model: ["App Store", "App Store & Known Developers"]; currentIndex: 1 } }
        FormRow { label: "FileVault"; sublabel: "Disk encryption is managed by your Linux installer."; value: "Off"; }
        FormRow { label: "Lockdown Mode"; Button { text: "Turn On…" } }
    }
    PaneFooter { }
}
