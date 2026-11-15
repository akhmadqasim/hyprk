import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Motion (ax-acc-motion-00). Works: Reduce motion (shell, Settings controls, Hyprland window / Space
// animations) and Prefer non-blinking cursor (GTK cursor-blink of the hyprk session); the others are saved or local.
AxPage {
    id: page
    Card {
        AxRow { h: 37.5; label: "Reduce motion"
                Switch { checked: page.ctl.ap.reduceMotion === true; onToggled: on => page.ctl.setAppearance({ reduceMotion: on }) } }
        AxRow { h: 37.5; label: "Auto-play animated images"
                Switch { checked: page.ctl.a.autoplayImages; onToggled: on => page.ctl.set({ autoplayImages: on }) } }
        AxRow { h: 36.5; label: "Prefer non-blinking cursor"
                Switch { checked: page.ctl.a.nonBlinkingCursor; onToggled: on => page.ctl.setNonBlinkingCursor(on) } }
    }
    Card {
        AxRow {
            h: 67
            label: "Vehicle Motion Cues"
            sub: "Dots appear near the edges of your Mac screen. They follow the movement of the vehicle and may help reduce motion sickness."
            subWidth: 397.5
            LocalSwitch {}
        }
        AxRow { h: 44; ctlY: 22; Button { text: "Customize Appearance" } }
    }
    PaneFooter {}
}
