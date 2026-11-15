import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Switch Control (ax-acc-switch-control-00..03). No backend: the controls keep their own state.
// The list's buttons (MAC-ANSWERS-14.md R14.4, live/settings-r14/acc-switch-control--{add,ellipsis}-dark.png): "+" opens
// a sheet 265 x 122, "Press your switch now…" beside a spinner, Cancel and Done (Done disabled: no switch was pressed
// on the capture, so what follows a press is not known and no press is taken here); "−" and "…" are disabled while no
// row is selected, as on the Mac.
AxPage {
    id: page
    property bool fade: false
    Card {
        AxRow { h: 80.95; ctlY: 19; iconId: "ax-switchcontrol"; label: "Switch Control"; subWidth: 347.5
                sub: "Switch Control allows the computer to be controlled using one or more switches. These can be mouse, keyboard, gamepad buttons or dedicated devices."
                LocalSwitch { controlSize: "small" } }
        AxRow { h: 37.42; label: "Appearance"; AxRadio { model: ["Dark", "Light"] } }
        AxRow { h: 37.5; label: "Fade panel after inactivity"; Switch { checked: page.fade; onToggled: on => page.fade = on } }
        AxRow { h: 38.5; ctlY: 18.6; label: "Duration of inactivity"
                AxStepper { enabled: page.fade; value: 15; fieldWidth: 65; unit: "seconds"; shown: value.toFixed(2).replace(".", ",") } }
        AxRow { h: 37.5; label: "Allow platform switching to control your computer"; LocalSwitch {} }
        AxRow { h: 48.1; ctlY: 22.1; subWidth: 328; sub: "The Panel Editor allows you to customize the panels shown by Switch Control."
                Button { text: "Panel Editor…" } }
    }
    Card {
        title: "Typing"
        AxRow { h: 37.5; label: "Show current text in keyboard panel"; LocalSwitch { checked: true } }
        AxRow { h: 37.5; label: "Insert and remove spaces automatically"; LocalSwitch {} }
        AxRow { h: 37.5; label: "Capitalize sentences automatically"; LocalSwitch {} }
        AxRow { h: 62.1; ctlY: 22.1; subWidth: 273
                sub: "Additional typing features, such as automatic correction and text substitutions, can be enabled in Keyboard settings."
                Button { text: "Keyboard Settings…"; onClicked: AppState.navigate("keyboard", "") } }
    }
    Card {
        title: "Switches"
        // the table (acc-switch-control-01-light.png): a 448 pt box 10 in, header 28, one row 24, the button strip 24
        Item {
            width: parent.width; height: 97
            Rectangle {
                x: 10; y: 10; width: parent.width - 20; height: 76
                color: "transparent"
                border.width: 1; border.color: Theme.dark ? Qt.rgba(1, 1, 1, 0.096) : Qt.rgba(0, 0, 0, 0.073)
                Rectangle { x: 1; y: 1; width: parent.width - 2; height: 27; color: Theme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.03) }
                Text { x: 6; y: 1 + (27 - height) / 2; text: "Required"; font: Typography.font(11, Typography.semibold); color: Theme.secondaryLabel }
                Rectangle { y: 27; width: parent.width; height: 1; color: parent.border.color }
                Text { x: 10; y: 28 + (24 - height) / 2; text: "Space Input"; font: Typography.body; color: Theme.label }
                Text { x: 236.5; y: 28 + (24 - height) / 2; text: "Select Item"; font: Typography.body; color: Theme.label }
                AxListBar { x: 1; y: 52; width: parent.width - 2; height: 23
                            objectName: "switchListBar"
                            glyphs: [{ name: "plus", on: true }, { name: "minus", on: false }, { name: "ellipsis.circle", on: false }]
                            onActivated: i => { if (i === 0) add.open(); } }
            }
        }
        AxRow { h: 52.4; labelY: 10.5; label: "Auto scanning"
                sub: "To turn off auto scan, add the Move to Next Item action first."
                Switch { checked: true; enabled: false } }
        AxRow { h: 44.5; ctlY: 22.5; Button { text: "Switch Timing…" } }
    }
    Card {
        title: "Navigation"
        AxRow { h: 38.25; labelY: 10.1; ctlY: 18.5; label: "While navigating"; LocalPopup { model: ["Do nothing", "Speak selected item"] } }
        AxRow { h: 38.25; labelY: 10.1; ctlY: 18.5; label: "Restart action position"; LocalPopup { model: ["After cursor", "From beginning"] } }
        AxRow { h: 37.5; labelY: 10.1; label: "Resume auto scanning after selection"; LocalSwitch {} }
        AxRow { h: 37.5; labelY: 10.1; label: "Reverse cursor direction after hitting edge"; LocalSwitch { checked: true } }
        AxRow { h: 38.25; labelY: 10.1; ctlY: 18.5; label: "Switch Control cursor size"; LocalPopup { model: ["Small", "Medium", "Large"] } }
        AxRow { h: 37.45; labelY: 10.1; label: "Pointer precision"; AxRadio { model: ["Low", "High"] } }
        AxRow { h: 37.8; labelY: 10.1; ctlY: 18.5; label: "Loops"; LocalPopup { model: ["1", "2", "3", "4", "5"]; currentIndex: 1 } }
        AxRow { h: 44.5; ctlY: 22.5; Button { text: "Navigation Timing…" } }
    }
    PaneFooter {}
    SubSheet {
        id: add
        objectName: "switchAdd"
        sheetWidth: 265; sheetHeight: 122
        footer: false
        MacText { x: 47.5; y: 21; text: "Press your switch now…" }
        // the spinner: 16 pt, eight spokes, turning (NSProgressIndicator's spinning style)
        Item {
            id: spinner
            objectName: "switchAddSpinner"
            x: 205.5; y: 21; width: 16; height: 16
            Repeater {
                model: 8
                Rectangle {
                    required property int index
                    x: 7.1; y: 0.5; width: 1.8; height: 4.6; radius: 0.9
                    color: Theme.label
                    opacity: 1 - index / 9
                    transform: Rotation { origin.x: 0.9; origin.y: 7.5; angle: -index * 45 }
                }
            }
            RotationAnimator on rotation { running: add.shown && !Tokens.reduceMotion; from: 0; to: 360; duration: 1000; loops: Animation.Infinite }
        }
        Button { objectName: "switchAddCancel"; x: 110; y: 77; width: 69; text: "Cancel"; onClicked: add.close() }
        Button { objectName: "switchAddDone"; x: 190; y: 77; width: 55; text: "Done"; enabled: false }
    }
}
