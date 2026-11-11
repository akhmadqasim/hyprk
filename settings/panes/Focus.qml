import QtQuick
import ".."
import "../controls"
import "../HyprK"

Column {
    spacing: Theme.content.sectionGap
    Card {
        // each mode's symbol in its colour: the modes' own configuration on 27.2.1 (themes/icons/sf-symbols/names.json
        // focusModes: symbol, colorName and the light / dark colour). How the Mac's pane draws them (tile or bare
        // symbol, size) is not measured: no shot of this pane.
        FormRow { symbol: "moon.fill"; symbolColor: Theme.dark ? "#6D7CFF" : "#6155F5"; label: "Do Not Disturb" }
        FormRow { symbol: "bed.double.fill"; symbolColor: Theme.dark ? "#6D7CFF" : "#6155F5"; label: "Sleep"; sublabel: "Set Up" }
        FormRow { symbol: "person.fill"; symbolColor: Theme.dark ? "#DB34F2" : "#CB30E0"; label: "Personal"; sublabel: "Set Up" }
        FormRow { symbol: "person.lanyardcard.fill"; symbolColor: Theme.dark ? "#00D2E0" : "#00C3D0"; label: "Work"; sublabel: "Set Up" }
    }
    PaneFooter { help: false; Button { text: "Add Focus…" } }
    Card {
        FormRow { label: "Share across devices"; LocalSwitch { checked: true } }
        FormRow { label: "Focus status"; Button { text: "On" } }
    }
}
