import QtQuick
import "../.."
import "../../controls"

// Accessibility features with no Linux backend: the macOS description and a calm
// empty state instead of controls that do nothing.
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap

    Card {
        FormRow {
            glyph: page.info.glyph; tint: Theme.tile.blue; dim: true
            label: page.info.title
            sublabel: page.info.about || ""
            MacSwitch { enabled_: false }
        }
    }
    Unavailable {
        height: 200
        glyph: page.info.glyph
        title: page.info.title + " Unavailable"
        text: "This feature isn't available on Linux yet."
    }
}
