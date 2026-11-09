import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    Card {
        title: "Notification Center"
        FormRow { label: "Show previews"; MacPopup { model: ["Always", "When Unlocked", "Never"]; currentIndex: 1 } }
        FormRow { label: "Summarize notifications"; MacSwitch {} }
        FormRow { label: "Allow notifications when the display is sleeping"; MacSwitch {} }
        FormRow { label: "Allow notifications when the screen is locked"; MacSwitch { checked: true } }
        FormRow { label: "Allow notifications when mirroring or sharing the display"; MacSwitch {} }
    }
    Card {
        title: "Application Notifications"
        FormRow { glyph: "calendar_month"; tint: Theme.tile.red; label: "Calendar"; sublabel: "Banners, Sounds, Badges" }
        FormRow { glyph: "photo_camera"; tint: Theme.tile.gray; label: "Screenshot"; sublabel: "Banners" }
        FormRow { glyph: "update"; tint: Theme.tile.gray; label: "Software Update"; sublabel: "Alerts, Badges" }
        FormRow { glyph: "terminal"; tint: Theme.tile.black; label: "Terminal"; sublabel: "Banners, Sounds" }
    }
    PaneFooter { }
}
