import QtQuick
import ".."
import "../controls"
import "../HyprK"

Column {
    spacing: Theme.content.sectionGap
    Card {
        title: "Control Center Modules"
        FormRow { glyph: "wifi"; tint: Theme.tile.blue; label: "Wi‑Fi"; LocalPopup { model: ["Show in Menu Bar", "Don't Show in Menu Bar"] } }
        FormRow { glyph: "bluetooth"; tint: Theme.tile.blue; label: "Bluetooth"; LocalPopup { model: ["Show in Menu Bar", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { glyph: "dark_mode"; tint: Theme.tile.indigo; label: "Focus"; LocalPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { glyph: "light_mode"; tint: Theme.tile.blue; label: "Display"; LocalPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { glyph: "volume_up"; tint: Theme.tile.pink; label: "Sound"; LocalPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { glyph: "play_arrow"; tint: Theme.tile.orange; label: "Now Playing"; LocalPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
    }
    Card {
        title: "Menu Bar Only"
        FormRow { glyph: "schedule"; tint: Theme.tile.gray; label: "Clock"; Button { text: "Clock Options…" } }
        FormRow { glyph: "search"; tint: Theme.tile.gray; label: "Spotlight"; LocalPopup { model: ["Show in Menu Bar", "Don't Show in Menu Bar"] } }
        FormRow { label: "Automatically hide and show the menu bar"; LocalPopup { model: ["Always", "On Desktop Only", "In Full Screen Only", "Never"]; currentIndex: 2 } }
        FormRow { label: "Recent documents, applications and servers"; LocalPopup { model: ["None", "5", "10", "15", "20"]; currentIndex: 2 } }
    }
    PaneFooter { }
}
