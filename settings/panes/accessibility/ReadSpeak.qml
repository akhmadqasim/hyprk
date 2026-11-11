import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// Accessibility > Read & Speak through speech-dispatcher (scripts/a11y-speak.sh).
// Works: Speak selection (⌥Esc speaks the selected text, again stops), speaking
// rate, Play Sample. Without spd-say every row is disabled with a note.
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap
    readonly property var a: ctl.a
    readonly property bool can: ctl.hasSpeech

    Card {
        FormRow {
            label: "Accessibility Reader"; dim: true
            sublabel: "A reading view for any app isn't available on Linux."
            Switch { enabled: false }
        }
        FormRow {
            label: "Speak selection"; dim: !page.can
            sublabel: "Press ⌥Esc to hear the selected text; press it again to stop."
            Switch { enabled: page.can; checked: page.a.speakSelection; onToggled: on => page.ctl.set({ speakSelection: on }) }
        }
        FormRow {
            label: "Speak item under the pointer"; dim: true
            Switch { enabled: false }
        }
        FormRow {
            label: "Speak announcements"; dim: !page.can
            sublabel: "Saved for notifications; the shell doesn't speak them yet."
            Switch { enabled: page.can; checked: page.a.speakAnnouncements; onToggled: on => page.ctl.set({ speakAnnouncements: on }) }
        }
    }
    Card {
        FormRow {
            label: "System voice"; dim: !page.can
            value: page.can ? "eSpeak NG" : "None"
        }
        FormRow {
            label: "Speaking rate"; dim: !page.can
            Slider {
                width: 220; enabled: page.can
                // the Mac's ends are tortoise.fill / hare.fill: not in themes/icons/sf-symbols yet, so none are drawn
                value: page.a.speechRate
                onReleased: page.ctl.set({ speechRate: Math.round(_dragValue * 100) / 100 })
            }
        }
    }
    InlineNote { text: page.can ? page.ctl.hyprNote : "Speech needs speech-dispatcher (spd-say)." }
    PaneFooter {
        Button { text: "Play Sample"; enabled: page.can
                    onClicked: page.ctl.speak("Hello, this is how your system voice sounds.") }
    }
}
