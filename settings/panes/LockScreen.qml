import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    Card {
        FormRow { label: "Start Screen Saver when inactive"; MacPopup { model: ["Never", "For 1 minute", "For 5 minutes", "For 20 minutes", "For 1 hour"]; currentIndex: 3 } }
        FormRow { label: "Turn display off when inactive"; MacPopup { model: ["Never", "For 5 minutes", "For 10 minutes", "For 1 hour"]; currentIndex: 2 } }
        FormRow { label: "Require password after screen saver begins or display is turned off"; MacPopup { model: ["Immediately", "After 5 seconds", "After 1 minute", "After 1 hour"] } }
        FormRow { label: "Show large clock"; MacPopup { model: ["On Screen Saver and Lock Screen", "On Lock Screen", "Never"]; currentIndex: 1 } }
    }
    Card {
        title: "When Switching User"
        FormRow { label: "Login window shows"; MacPopup { model: ["List of users", "Name and password"] } }
        FormRow { label: "Show the Sleep, Restart and Shut Down buttons"; MacSwitch { checked: true } }
        FormRow { label: "Show password hints"; MacSwitch {} }
    }
    PaneFooter { }
}
