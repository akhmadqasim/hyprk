import QtQuick
import ".."
import "../controls"
import "../HyprK"

Column {
    spacing: Theme.content.sectionGap
    Card {
        title: "Control Center Modules"
        FormRow { iconId: "wifi"; label: "Wi‑Fi"; LocalPopup { model: ["Show in Menu Bar", "Don't Show in Menu Bar"] } }
        FormRow { iconId: "bluetooth"; label: "Bluetooth"; LocalPopup { model: ["Show in Menu Bar", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { iconId: "focus"; label: "Focus"; LocalPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { iconId: "display"; label: "Display"; LocalPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { iconId: "sound"; label: "Sound"; LocalPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
        FormRow { iconId: "menubar-nowplaying"; label: "Now Playing"; LocalPopup { model: ["Always Show in Menu Bar", "Show When Active", "Don't Show in Menu Bar"]; currentIndex: 1 } }
    }
    Card {
        title: "Menu Bar Only"
        FormRow { iconId: "menubar-clock"; label: "Clock"; Button { text: "Clock Options…" } }
        FormRow { iconId: "spotlight"; label: "Spotlight"; LocalPopup { model: ["Show in Menu Bar", "Don't Show in Menu Bar"] } }
        FormRow { label: "Automatically hide and show the menu bar"; LocalPopup { model: ["Always", "On Desktop Only", "In Full Screen Only", "Never"]; currentIndex: 2 } }
        FormRow { label: "Recent documents, applications and servers"; LocalPopup { model: ["None", "5", "10", "15", "20"]; currentIndex: 2 } }
    }
    PaneFooter { }
}
