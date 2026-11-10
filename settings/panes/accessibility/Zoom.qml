import QtQuick
import "../.."
import "../../controls"

// Accessibility > Zoom. Works: keyboard shortcuts (Option-Command-8 / = / -) and the
// scroll gesture with a modifier, both through Hyprland's cursor zoom
// (cursor:zoom_factor, scripts/a11y-zoom.sh). Only Full Screen style exists there.
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap
    readonly property var a: ctl.a
    readonly property var mods: ["control", "option", "command"]

    Card {
        FormRow {
            label: "Use keyboard shortcuts to zoom"
            sublabel: "Toggle zoom: ⌥⌘8   Zoom in: ⌥⌘=   Zoom out: ⌥⌘−"
            MacSwitch { checked: page.a.zoomKeys; onToggled: on => page.ctl.set({ zoomKeys: on }) }
        }
        FormRow {
            label: "Use trackpad gesture to zoom"; dim: true
            sublabel: "Hyprland has no pinch-to-zoom for the whole screen."
            MacSwitch { enabled_: false }
        }
        FormRow {
            label: "Use scroll gesture with modifier keys to zoom"
            MacPopup {
                anchors.verticalCenter: parent.verticalCenter
                enabled_: page.a.zoomScroll
                model: ["^ Control", "⌥ Option", "⌘ Command"]
                currentIndex: Math.max(0, page.mods.indexOf(page.a.zoomModifier))
                onActivated: i => page.ctl.set({ zoomModifier: page.mods[i] })
            }
            MacSwitch { checked: page.a.zoomScroll; onToggled: on => page.ctl.set({ zoomScroll: on }) }
        }
    }
    Card {
        FormRow {
            label: "Zoom style"
            sublabel: page.a.zoomStyle === "fullscreen" ? "" : "Split Screen and Picture-in-Picture need a zoom window Hyprland doesn't have; Full Screen is used."
            MacPopup {
                model: ["Full Screen", "Split Screen", "Picture-in-Picture"]
                currentIndex: Math.max(0, ["fullscreen", "split", "pip"].indexOf(page.a.zoomStyle))
                onActivated: i => page.ctl.set({ zoomStyle: ["fullscreen", "split", "pip"][i] })
            }
        }
        FormRow {
            label: "Zoom now"
            sublabel: "The screen follows the pointer while zoomed in."
            MacButton { text: "Zoom Out"; onClicked: Backend.run([page.ctl.scripts + "a11y-zoom.sh", "off"]) }
            MacButton { text: "Zoom In"; onClicked: Backend.run([page.ctl.scripts + "a11y-zoom.sh", "in"]) }
        }
    }
    InlineNote { text: page.ctl.hyprNote }
    PaneFooter { MacButton { text: "Advanced…"; enabled_: false } }
}
