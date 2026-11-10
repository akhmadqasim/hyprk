import QtQuick
import ".."
import "../controls"
import "../HyprK"

// Functional: writes state/dock.json (read by the shell's dock).
Column {
    id: pane
    spacing: Theme.content.sectionGap
    readonly property var d: AppState.dock

    // 27.2.1 order and layout (MAC-ANSWERS.md Q-settings-29, desktop-dock-*.png): the Size and Magnification sliders
    // side by side in one 69 pt card (200 / 220 wide, 11 pt end labels under the track), then two cards of rows.
    // Magnification has no switch: its slider's left end is "Off".
    component SliderCell: Item {
        id: cell
        property string label
        default property alias slider: holder.data
        height: 69
        MacText { x: 0; y: 10; text: cell.label }
        Item { id: holder; y: 27.5; width: parent.width; height: 31 }
    }
    Card {
        title: "Dock"
        Item {
            width: parent.width; height: 69
            SliderCell {
                x: Theme.content.rowPadding; width: 200
                label: "Size"
                Slider {
                    width: parent.width; from: 16; to: 128; value: pane.d.size
                    tickMarks: 2; leftText: "Small"; rightText: "Large"
                    onMoved: v => AppState.set("dock", { size: Math.round(v) })
                }
            }
            SliderCell {
                x: parent.width - Theme.content.rowPadding - width; width: 220
                label: "Magnification"
                Slider {
                    readonly property real span: Math.max(1, 128 - pane.d.size)
                    width: parent.width
                    value: pane.d.magnification ? Math.max(0.12, (pane.d.magnifiedSize - pane.d.size) / span) : 0
                    labels: [["Off", 0], ["Small", 0.12], ["Large", 1]]
                    onMoved: v => AppState.set("dock", v < 0.06 ? { magnification: false }
                        : { magnification: true, magnifiedSize: Math.round(pane.d.size + v * span) })
                }
            }
        }
    }
    Card {
        FormRow {
            label: "Position on screen"
            StatePopup { stateKey: "dock"; field: "position"; choices: [["Left", "left"], ["Bottom", "bottom"], ["Right", "right"]] }
        }
        FormRow {
            label: "Minimize window animation"
            StatePopup { stateKey: "dock"; field: "minimizeEffect"; choices: [["Genie Effect", "genie"], ["Scale Effect", "scale"]] }
        }
        FormRow { label: "Double-click a window's title bar to"; LocalPopup { model: ["Zoom", "Minimize", "Do Nothing"] } }
        FormRow { label: "Minimize windows into application icon"; LocalSwitch {} }
    }
    Card {
        FormRow { label: "Automatically hide and show the Dock"; Switch { checked: pane.d.autohide; onToggled: on => AppState.set("dock", { autohide: on }) } }
        FormRow { label: "Animate opening applications"; LocalSwitch { checked: true } }
        FormRow { label: "Show indicators for open applications"; LocalSwitch { checked: true } }
        FormRow { label: "Show suggested and recent apps in Dock"; Switch { checked: pane.d.showRecents; onToggled: on => AppState.set("dock", { showRecents: on }) } }
    }

    Card {
        title: "Desktop & Stage Manager"
        FormRow { // two checkboxes (27.2.1), held locally until a backend exists
            label: "Show items"
            Checkbox { property bool on: true; checked: on; onToggled: v => on = v; text: "On Desktop"; anchors.verticalCenter: parent.verticalCenter }
            Checkbox { property bool on: false; checked: on; onToggled: v => on = v; text: "In Stage Manager"; anchors.verticalCenter: parent.verticalCenter }
        }
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
