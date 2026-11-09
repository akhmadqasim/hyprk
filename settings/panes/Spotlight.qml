import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    Card {
        title: "Search results"
        Repeater {
            model: ["Applications", "Calculator", "Contacts", "Conversion", "Definition", "Documents", "Folders", "Images", "System Settings", "Tips", "Websites"]
            FormRow { required property string modelData; label: modelData; MacSwitch { checked: true } }
        }
    }
    Card {
        FormRow { label: "Help Apple improve Search"; MacSwitch {} }
    }
    PaneFooter { MacButton { text: "Search Privacy…" } }
}
