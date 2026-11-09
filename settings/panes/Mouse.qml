import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    Card {
        FormRow { label: "Tracking speed"; MacSlider { width: 200; value: 0.5 } }
        FormRow { label: "Natural scrolling"; sublabel: "Content tracks finger movement"; MacSwitch { checked: true } }
        FormRow { label: "Secondary click"; MacPopup { model: ["Click Right Side", "Click Left Side"] } }
        FormRow { label: "Double-click speed"; MacSlider { width: 200; value: 0.6 } }
        FormRow { label: "Scrolling speed"; MacSlider { width: 200; value: 0.4 } }
    }
    PaneFooter { MacButton { text: "Advanced…" } }
}
