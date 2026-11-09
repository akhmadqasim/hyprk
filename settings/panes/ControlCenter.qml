import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    Card {
        title: "Control Center Modules"
        FormRow { glyph: "wifi"; tint: Theme.tile.blue; label: "Wi‑Fi"; MacPopup { model: ["Show in Menu Bar", "Don't Show in Menu Bar"] } }
        FormRow { glyph: "bluetooth"; tint: Theme.tile.blue; label: "Bluetooth"; MacPopup { model: ["Show in Menu Bar", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { glyph: "dark_mode"; tint: Theme.tile.indigo; label: "Focus"; MacPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { glyph: "light_mode"; tint: Theme.tile.blue; label: "Display"; MacPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { glyph: "volume_up"; tint: Theme.tile.pink; label: "Sound"; MacPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { glyph: "play_arrow"; tint: Theme.tile.orange; label: "Now Playing"; MacPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
    }
    Card {
        title: "Menu Bar Only"
        FormRow { glyph: "schedule"; tint: Theme.tile.gray; label: "Clock"; MacButton { text: "Clock Options…" } }
        FormRow { glyph: "search"; tint: Theme.tile.gray; label: "Spotlight"; MacPopup { model: ["Show in Menu Bar", "Don't Show in Menu Bar"] } }
        FormRow { label: "Automatically hide and show the menu bar"; MacPopup { model: ["Always", "On Desktop Only", "In Full Screen Only", "Never"]; currentIndex: 2 } }
        FormRow { label: "Recent documents, applications and servers"; MacPopup { model: ["None", "5", "10", "15", "20"]; currentIndex: 2 } }
    }
    Row { anchors.right: parent.right; HelpButton {} }
}
