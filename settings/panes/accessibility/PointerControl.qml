import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Pointer Control (ax-acc-pointer-control-00). No backend here (the mouse and trackpad speeds live in
// their panes): the controls keep their own state.
AxPage {
    Card {
        title: "Mouse & Trackpad"
        AxRow { h: 40.25; ctlY: 19.5; label: "Double-click speed"
                AxSlider { width: 245; leftGlyph: "tortoise.fill"; rightGlyph: "hare.fill"; glyphSize: 13; tickMarks: 11; value: 0.8 } }
        AxRow { h: 37.5; labelY: 10.25; label: "Spring-loading"; LocalSwitch { checked: true } }
        AxRow { h: 40.25; ctlY: 19.25; label: "Spring-loading speed"
                AxSlider { width: 245; leftGlyph: "tortoise.fill"; rightGlyph: "hare.fill"; glyphSize: 13; tickMarks: 7; value: 0.8333 } }
        AxRow { h: 52; label: "Ignore built-in trackpad when mouse or wireless trackpad is present"; labelWidth: 352; LocalSwitch {} }
    }
    Row {
        anchors.right: parent.right
        spacing: 10
        Button { text: "Trackpad Options…" }
        Button { text: "Mouse Options…" }
    }
    Card {
        title: "Alternate Control Methods"
        AxRow { h: 67; info: true; label: "Mouse Keys"; subWidth: 327.5
                sub: "Allows the pointer to be controlled using the keyboard keys or number pad."; LocalSwitch {} }
        AxRow { h: 67; info: true; label: "Alternate pointer actions"; subWidth: 340
                sub: "Allows a switch or facial expression to be used instead of mouse buttons or pointer actions like left-click and right-click."; LocalSwitch {} }
        AxRow { h: 66; info: true; label: "Head pointer"; subWidth: 362
                sub: "Allows the pointer to be controlled using the movement of your head captured by the camera."; LocalSwitch {} }
    }
    PaneFooter {}
}
