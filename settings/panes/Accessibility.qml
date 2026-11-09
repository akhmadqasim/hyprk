import QtQuick
import ".."
import "../controls"

// "Reduce transparency" is functional (state/appearance.json, honored by the
// shell and by this app's sidebar). The rest is visual.
Column {
    spacing: Theme.content.sectionGap

    HeroCard {
        glyph: "accessibility_new"; tint: Theme.tile.blue
        title: "Accessibility"
        text: "Personalize your computer to suit your vision, hearing, motor and speech needs."
    }
    Card {
        title: "Display"
        FormRow {
            label: "Reduce transparency"
            sublabel: "Improves contrast by reducing transparency in windows, menus and the Dock."
            MacSwitch { checked: AppState.appearance.reduceTransparency; onToggled: on => AppState.setAppearance({ reduceTransparency: on }) }
        }
        FormRow { label: "Increase contrast"; MacSwitch {} }
        FormRow { label: "Reduce motion"; MacSwitch {} }
        FormRow { label: "Differentiate without color"; MacSwitch {} }
    }
    Card {
        title: "Vision"
        FormRow { glyph: "zoom_in"; tint: Theme.tile.blue; label: "Zoom"; value: "Off"; }
        FormRow { glyph: "record_voice_over"; tint: Theme.tile.black; label: "VoiceOver"; value: "Off"; }
        FormRow { glyph: "subtitles"; tint: Theme.tile.gray; label: "Spoken Content" }
    }
}
