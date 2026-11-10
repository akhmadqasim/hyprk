import QtQuick
import "../.."
import "../../controls"

// Accessibility > Motion (macOS 27). Works: Reduce motion (shell, Settings controls,
// Hyprland window/Space animations) and Prefer non-blinking cursor (GNOME/GTK
// cursor-blink, shared with the host desktop). The rest needs media/GPU support.
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap

    Card {
        FormRow {
            label: "Reduce motion"
            sublabel: "Reduce the motion of the user interface, including Liquid Glass effects, window zooms and sliding Spaces."
            MacSwitch { checked: page.ctl.ap.reduceMotion === true; onToggled: on => page.ctl.setAppearance({ reduceMotion: on }) }
        }
        FormRow {
            label: "Dim flashing lights"; dim: true
            sublabel: "Video playback here can't detect flashing or strobing lights."
            MacSwitch { enabled_: false }
        }
        FormRow {
            label: "Auto-play animated images"
            sublabel: "Saved for apps that ask; most Linux apps don't yet."
            MacSwitch { checked: page.ctl.a.autoplayImages; onToggled: on => page.ctl.set({ autoplayImages: on }) }
        }
        FormRow {
            label: "Prefer non-blinking cursor"; dim: !page.ctl.hasGsettings
            sublabel: page.ctl.hasGsettings ? "The insertion point stops blinking in GTK and GNOME apps." : "Needs gsettings (GNOME settings) to reach apps."
            MacSwitch { enabled_: page.ctl.hasGsettings; checked: page.ctl.a.nonBlinkingCursor; onToggled: on => page.ctl.setNonBlinkingCursor(on) }
        }
        FormRow {
            label: "Vehicle Motion Cues"; dim: true
            sublabel: "Needs the motion sensors of a laptop."
            MacSwitch { enabled_: false }
        }
    }
    InlineNote { text: page.ctl.hyprNote }
    PaneFooter {}
}
