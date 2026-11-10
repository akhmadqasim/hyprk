import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// Accessibility > Audio. Choices are saved in state/accessibility.json; the shell
// and PipeWire glue don't act on them yet (FALLBACKS.md).
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap

    Card {
        title: "General"
        FormRow {
            label: "Flash the screen when an alert sound occurs"
            Switch { checked: page.ctl.a.flashScreen; onToggled: on => page.ctl.set({ flashScreen: on }) }
        }
        FormRow {
            label: "Play stereo audio as mono"
            Switch { checked: page.ctl.a.monoAudio; onToggled: on => page.ctl.set({ monoAudio: on }) }
        }
    }
    InlineNote { text: "Saved for the shell and PipeWire; they don't apply these two yet." }
    Card {
        title: "Background Sounds"
        FormRow {
            label: "Background sounds"; dim: true
            sublabel: "Plays background sounds to mask unwanted environmental noise."
            Switch { enabled: false }
        }
    }
    PaneFooter { Button { text: "Sound Settings…" } }
}
