import QtQuick
import ".."
import "../controls"
import "../HyprK"

Column {
    spacing: Theme.content.sectionGap
    HeroCard { iconId: "siri"; tint: Theme.tile.purple; title: "Siri"; text: "Siri is an intelligent assistant that helps you find information and get things done." }   // SiriPreferenceExtension SIRI_PLACARD_DESCRIPTION (its Learn more… link left out)
    Card {
        FormRow { label: "Siri"; Switch { enabled: false } }
        FormRow { label: "Listen for"; Popup { enabled: false; model: ["Off"] } }
        FormRow { label: "Keyboard shortcut"; Popup { enabled: false; model: ["Press Either Command Key Twice"] } }
    }
    PaneFooter {}
}
