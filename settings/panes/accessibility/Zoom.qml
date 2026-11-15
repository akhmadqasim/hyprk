import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Zoom (ax-acc-zoom-00). Works: the keyboard shortcuts and the scroll gesture with a modifier, through
// Hyprland's cursor zoom (cursor:zoom_factor, scripts/a11y-zoom.sh).
AxPage {
    id: page
    readonly property var a: ctl.a
    readonly property var mods: ["control", "option", "command"]
    readonly property var styles: ["fullscreen", "split", "pip"]
    Card {
        AxRow {
            h: 81; labelY: 10.1
            label: "Use keyboard shortcuts to zoom"
            sub: "Toggle zoom: ⌥⌘8\nZoom in: ⌥⌘=\nZoom out: ⌥⌘-"
            Switch { checked: page.a.zoomKeys; onToggled: on => page.ctl.set({ zoomKeys: on }) }
        }
        AxRow {
            h: 67; labelY: 10.1
            label: "Use trackpad gesture to zoom"
            sub: "Double-tap three fingers to toggle zoom\nDouble-tap three fingers and drag to change zoom"
            LocalSwitch {}
        }
        AxRow {
            h: 37.5; labelY: 10.1
            label: "Use scroll gesture with modifier keys to zoom"
            Switch { checked: page.a.zoomScroll; onToggled: on => page.ctl.set({ zoomScroll: on }) }
        }
        AxRow {
            h: 44; labelY: 10.1; ctlY: 21
            label: "Modifier key for scroll gesture"
            AxCombo {   // R14.4: the arrow opens the list of the three keys under the field
                objectName: "zoomModifierCombo"
                model: ["⌃ Control", "⌥ Option", "⌘ Command"]
                currentIndex: Math.max(0, page.mods.indexOf(page.a.zoomModifier))
                onActivated: i => page.ctl.set({ zoomModifier: page.mods[i] })
            }
        }
        AxRow {
            h: 44.5; labelY: 13.25; ctlY: 21.5
            label: "Zoom style"
            Popup {
                model: ["Full Screen", "Split Screen", "Picture-in-Picture"]
                currentIndex: Math.max(0, page.styles.indexOf(page.a.zoomStyle))
                onActivated: i => page.ctl.set({ zoomStyle: page.styles[i] })
            }
            Button { text: "Choose Display…" }
        }
        AxRow {
            h: 44.5; ctlY: 22.5
            Button { text: "Advanced…" }
        }
    }
    PaneFooter {}
}
