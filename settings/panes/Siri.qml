import QtQuick
import ".."
import "../controls"
import "../HyprK"

Column {
    spacing: Theme.content.sectionGap
    HeroCard { glyph: "graphic_eq"; tint: Theme.tile.purple; title: "Siri"; text: "Siri is not available on this computer." }
    Card {
        FormRow { label: "Siri"; Switch { enabled: false } }
        FormRow { label: "Listen for"; Popup { enabled: false; model: ["Off"] } }
        FormRow { label: "Keyboard shortcut"; Popup { enabled: false; model: ["Press Either Command Key Twice"] } }
    }
    PaneFooter {}
}
