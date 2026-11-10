import QtQuick
import ".."
import "../controls"
import "../HyprK"

Column {
    spacing: Theme.content.sectionGap
    Card {
        FormRow { label: "Tracking speed"; Slider { width: 200; value: 0.5 } }
        FormRow { label: "Natural scrolling"; sublabel: "Content tracks finger movement"; LocalSwitch { checked: true } }
        FormRow { label: "Secondary click"; LocalPopup { model: ["Click Right Side", "Click Left Side"] } }
        FormRow { label: "Double-click speed"; Slider { width: 200; value: 0.6 } }
        FormRow { label: "Scrolling speed"; Slider { width: 200; value: 0.4 } }
    }
    PaneFooter { Button { text: "Advanced…" } }
}
