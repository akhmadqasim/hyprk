import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    HeroCard { glyph: "graphic_eq"; tint: Theme.tile.purple; title: "Siri"; text: "Siri is not available on this computer." }
    Card {
        FormRow { label: "Siri"; MacSwitch { enabled_: false } }
        FormRow { label: "Listen for"; MacPopup { enabled_: false; model: ["Off"] } }
        FormRow { label: "Keyboard shortcut"; MacPopup { enabled_: false; model: ["Press Either Command Key Twice"] } }
    }
    PaneFooter {}
}
