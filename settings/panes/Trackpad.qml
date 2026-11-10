import QtQuick
import ".."
import "../controls"
import "../HyprK"

Column {
    spacing: Theme.content.sectionGap
    Card {
        title: "Point & Click"
        FormRow { label: "Tracking speed"; Slider { width: 200; value: 0.5 } }
        FormRow { label: "Click"; LocalPopup { model: ["Light", "Medium", "Firm"]; currentIndex: 1 } }
        FormRow { label: "Force Click and haptic feedback"; LocalSwitch { checked: true } }
        FormRow { label: "Look up & data detectors"; LocalPopup { model: ["Force Click with One Finger", "Tap with Three Fingers", "Off"] } }
        FormRow { label: "Secondary click"; LocalPopup { model: ["Click or Tap with Two Fingers", "Click in Bottom Right Corner", "Click in Bottom Left Corner", "Off"] } }
        FormRow { label: "Tap to click"; LocalSwitch { checked: true } }
    }
    Card {
        title: "Scroll & Zoom"
        FormRow { label: "Natural scrolling"; LocalSwitch { checked: true } }
        FormRow { label: "Zoom in or out"; LocalSwitch { checked: true } }
        FormRow { label: "Smart zoom"; LocalSwitch { checked: true } }
        FormRow { label: "Rotate"; LocalSwitch { checked: true } }
    }
    PaneFooter { Button { text: "Set Up Bluetooth Trackpad…" } }
}
