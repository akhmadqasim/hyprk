import QtQuick
import ".."
import "../controls"

// Functional: writes state/dock.json (read by the shell's dock).
Column {
    id: pane
    spacing: Theme.content.sectionGap
    readonly property var d: AppState.dock
    readonly property var positions: ["left", "bottom", "right"]
    readonly property var effects: ["genie", "scale"]

    Card {
        title: "Dock"
        FormRow {
            label: "Size"
            MacSlider {
                width: 230; from: 16; to: 128; value: pane.d.size
                leftGlyph: "remove"; rightGlyph: "add"
                onMoved: v => AppState.setDock({ size: Math.round(v) })
            }
        }
        FormRow {
            label: "Magnification"
            MacSlider {
                width: 230; from: 16; to: 128; value: pane.d.magnifiedSize
                enabled_: pane.d.magnification
                leftGlyph: "remove"; rightGlyph: "add"
                onMoved: v => AppState.setDock({ magnifiedSize: Math.round(v) })
            }
            MacSwitch { checked: pane.d.magnification; onToggled: on => AppState.setDock({ magnification: on }) }
        }
        FormRow {
            label: "Position on screen"
            MacPopup {
                model: ["Left", "Bottom", "Right"]
                currentIndex: pane.positions.indexOf(pane.d.position)
                onActivated: i => AppState.setDock({ position: pane.positions[i] })
            }
        }
        FormRow {
            label: "Minimize windows using"
            MacPopup {
                model: ["Genie Effect", "Scale Effect"]
                currentIndex: Math.max(0, pane.effects.indexOf(pane.d.minimizeEffect))
                onActivated: i => AppState.setDock({ minimizeEffect: pane.effects[i] })
            }
        }
        FormRow { label: "Double-click a window's title bar to"; MacPopup { model: ["Zoom", "Minimize", "Do Nothing"] } }
        FormRow { label: "Minimize windows into application icon"; MacSwitch {} }
        FormRow { label: "Automatically hide and show the Dock"; MacSwitch { checked: pane.d.autohide; onToggled: on => AppState.setDock({ autohide: on }) } }
        FormRow { label: "Animate opening applications"; MacSwitch { checked: true } }
        FormRow { label: "Show indicators for open applications"; MacSwitch { checked: true } }
        FormRow { label: "Show suggested and recent apps in Dock"; MacSwitch { checked: pane.d.showRecents; onToggled: on => AppState.setDock({ showRecents: on }) } }
    }

    Card {
        title: "Desktop & Stage Manager"
        FormRow { label: "Show Items"; MacPopup { model: ["On Desktop", "In Stage Manager"] } }
        FormRow { label: "Click wallpaper to reveal desktop"; MacPopup { model: ["Always", "Only in Stage Manager"]; currentIndex: 1 } }
        FormRow { label: "Stage Manager"; sublabel: "Arranges your recent windows into a single strip for reduced clutter and quick access."; MacSwitch {} }
    }

    Card {
        title: "Windows"
        FormRow { label: "Prefer tabs when opening documents"; MacPopup { model: ["Always", "In Full Screen", "Never"]; currentIndex: 1 } }
        FormRow { label: "Ask to keep changes when closing documents"; MacSwitch {} }
        FormRow { label: "Close windows when quitting an application"; MacSwitch { checked: true } }
        FormRow { label: "Drag windows to screen edges to tile"; MacSwitch { checked: true } }
        FormRow { label: "Tiled windows have margins"; MacSwitch {} }
    }

    Row { anchors.right: parent.right; spacing: 8; MacButton { text: "Hot Corners…" } HelpButton {} }
}
