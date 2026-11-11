import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// Accessibility features with no Linux backend: the macOS description and a calm
// empty state instead of controls that do nothing.
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap

    Card {
        FormRow {
            iconId: page.info.icon; dim: true
            label: page.info.title
            sublabel: page.info.about || ""
            Switch { enabled: false }
        }
    }
    Unavailable {
        height: 200
        title: page.info.title + " Unavailable"
        text: "This feature isn't available on Linux yet."
    }
}
