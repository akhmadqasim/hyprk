import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    Card {
        FormRow { label: "Key repeat rate"; MacSlider { width: 200; value: 0.75 } }
        FormRow { label: "Delay until repeat"; MacSlider { width: 200; value: 0.6 } }
        FormRow { label: "Adjust keyboard brightness in low light"; MacSwitch { checked: true } }
        FormRow { label: "Press 🌐 key to"; MacPopup { model: ["Change Input Source", "Show Emoji & Symbols", "Start Dictation", "Do Nothing"]; currentIndex: 1 } }
        FormRow { label: "Keyboard navigation"; sublabel: "Use keyboard navigation to move focus between controls."; MacSwitch {} }
    }
    PaneFooter { help: false; MacButton { text: "Keyboard Shortcuts…" } }
    Card {
        title: "Text Input"
        FormRow { label: "Input Sources"; value: "U.S."; MacButton { text: "Edit…" } }
    }
    Card {
        title: "Dictation"
        FormRow { label: "Dictation"; sublabel: "Use Dictation wherever you can type text."; MacSwitch {} }
    }
    PaneFooter { MacButton { text: "Set Up Keyboard…" } }
}
