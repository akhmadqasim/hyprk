import QtQuick
import ".."
import "../controls"
import "../HyprK"

Column {
    spacing: Theme.content.sectionGap
    Card {
        title: "Search results"
        Repeater {
            model: ["Applications", "Calculator", "Contacts", "Conversion", "Definition", "Documents", "Folders", "Images", "System Settings", "Tips", "Websites"]
            FormRow { required property string modelData; label: modelData; LocalSwitch { checked: true } }
        }
    }
    Card {
        FormRow { label: "Help Apple improve Search"; LocalSwitch {} }
    }
    PaneFooter { Button { text: "Search Privacy…" } }
}
