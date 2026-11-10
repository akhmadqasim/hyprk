import QtQuick
import ".."
import "../controls"
import "../HyprK"

// Functional: writes state/dock.json (read by the shell's dock).
Column {
    id: pane
    spacing: Theme.content.sectionGap
    readonly property var d: AppState.dock

    Card {
        title: "Dock"
        FormRow {
            label: "Size"
            Slider {
                width: 230; from: 16; to: 128; value: pane.d.size
                leftGlyph: "remove"; rightGlyph: "add"
                onMoved: v => AppState.set("dock", { size: Math.round(v) })
            }
        }
        FormRow {
            label: "Magnification"
            Slider {
                width: 230; from: 16; to: 128; value: pane.d.magnifiedSize
                enabled: pane.d.magnification
                leftGlyph: "remove"; rightGlyph: "add"
                onMoved: v => AppState.set("dock", { magnifiedSize: Math.round(v) })
            }
            Switch { checked: pane.d.magnification; onToggled: on => AppState.set("dock", { magnification: on }) }
        }
        FormRow {
            label: "Position on screen"
            StatePopup { stateKey: "dock"; field: "position"; choices: [["Left", "left"], ["Bottom", "bottom"], ["Right", "right"]] }
        }
        FormRow {
            label: "Minimize windows using"
            StatePopup { stateKey: "dock"; field: "minimizeEffect"; choices: [["Genie Effect", "genie"], ["Scale Effect", "scale"]] }
        }
        FormRow { label: "Double-click a window's title bar to"; LocalPopup { model: ["Zoom", "Minimize", "Do Nothing"] } }
        FormRow { label: "Minimize windows into application icon"; LocalSwitch {} }
        FormRow { label: "Automatically hide and show the Dock"; Switch { checked: pane.d.autohide; onToggled: on => AppState.set("dock", { autohide: on }) } }
        FormRow { label: "Animate opening applications"; LocalSwitch { checked: true } }
        FormRow { label: "Show indicators for open applications"; LocalSwitch { checked: true } }
        FormRow { label: "Show suggested and recent apps in Dock"; Switch { checked: pane.d.showRecents; onToggled: on => AppState.set("dock", { showRecents: on }) } }
    }

    Card {
        title: "Desktop & Stage Manager"
        FormRow { label: "Show Items"; LocalPopup { model: ["On Desktop", "In Stage Manager"] } }
        FormRow { label: "Click wallpaper to reveal desktop"; LocalPopup { model: ["Always", "Only in Stage Manager"]; currentIndex: 1 } }
        FormRow { label: "Stage Manager"; sublabel: "Arranges your recent windows into a single strip for reduced clutter and quick access."; LocalSwitch {} }
    }

    Card {
        title: "Windows"
        FormRow { label: "Prefer tabs when opening documents"; LocalPopup { model: ["Always", "In Full Screen", "Never"]; currentIndex: 1 } }
        FormRow { label: "Ask to keep changes when closing documents"; LocalSwitch {} }
        FormRow { label: "Close windows when quitting an application"; LocalSwitch { checked: true } }
        FormRow { label: "Drag windows to screen edges to tile"; LocalSwitch { checked: true } }
        FormRow { label: "Tiled windows have margins"; LocalSwitch {} }
    }

    PaneFooter { Button { text: "Hot Corners…" } }
}
