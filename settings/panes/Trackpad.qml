import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    Card {
        title: "Point & Click"
        FormRow { label: "Tracking speed"; MacSlider { width: 200; value: 0.5 } }
        FormRow { label: "Click"; MacPopup { model: ["Light", "Medium", "Firm"]; currentIndex: 1 } }
        FormRow { label: "Force Click and haptic feedback"; MacSwitch { checked: true } }
        FormRow { label: "Look up & data detectors"; MacPopup { model: ["Force Click with One Finger", "Tap with Three Fingers", "Off"] } }
        FormRow { label: "Secondary click"; MacPopup { model: ["Click or Tap with Two Fingers", "Click in Bottom Right Corner", "Click in Bottom Left Corner", "Off"] } }
        FormRow { label: "Tap to click"; MacSwitch { checked: true } }
    }
    Card {
        title: "Scroll & Zoom"
        FormRow { label: "Natural scrolling"; MacSwitch { checked: true } }
        FormRow { label: "Zoom in or out"; MacSwitch { checked: true } }
        FormRow { label: "Smart zoom"; MacSwitch { checked: true } }
        FormRow { label: "Rotate"; MacSwitch { checked: true } }
    }
    Row { anchors.right: parent.right; spacing: 8; MacButton { text: "Set Up Bluetooth Trackpad…" } HelpButton {} }
}
