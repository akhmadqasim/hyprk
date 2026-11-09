import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    Card {
        FormRow { glyph: "dark_mode"; tint: Theme.tile.indigo; label: "Do Not Disturb" }
        FormRow { glyph: "bed"; tint: Theme.tile.teal; label: "Sleep"; sublabel: "Set Up" }
        FormRow { glyph: "person"; tint: Theme.tile.purple; label: "Personal"; sublabel: "Set Up" }
        FormRow { glyph: "work"; tint: Theme.tile.blue; label: "Work"; sublabel: "Set Up" }
    }
    PaneFooter { help: false; MacButton { text: "Add Focus…" } }
    Card {
        FormRow { label: "Share across devices"; MacSwitch { checked: true } }
        FormRow { label: "Focus status"; MacButton { text: "On" } }
    }
}
