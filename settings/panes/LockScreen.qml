import QtQuick
import ".."
import "../controls"

// Saves idle timeouts to state/lock.json (seconds, 0 = never) for the session's
// idle/lock glue (hypridle + hyprlock) to read. Nothing reads it yet; see FALLBACKS.md.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    function duration(s) { return s % 3600 === 0 ? s / 3600 + " h" : s % 60 === 0 ? s / 60 + " min" : s + " s"; }
    function forTime(s) { return "For " + duration(s); }

    Card {
        FormRow {
            label: "Start Screen Saver when inactive"
            StatePopup { stateKey: "lock"; field: "screenSaverAfter"; formatValue: pane.forTime; choices: [["Never", 0], ["For 1 minute", 60], ["For 2 minutes", 120], ["For 5 minutes", 300], ["For 10 minutes", 600], ["For 20 minutes", 1200], ["For 30 minutes", 1800], ["For 1 hour", 3600]] }
        }
        FormRow {
            label: "Turn display off when inactive"
            StatePopup { stateKey: "lock"; field: "displayOffAfter"; formatValue: pane.forTime; choices: [["Never", 0], ["For 1 minute", 60], ["For 2 minutes", 120], ["For 5 minutes", 300], ["For 10 minutes", 600], ["For 20 minutes", 1200], ["For 30 minutes", 1800], ["For 1 hour", 3600], ["For 3 hours", 10800]] }
        }
        FormRow {
            label: "Require password after screen saver begins or display is turned off"
            StatePopup { stateKey: "lock"; field: "requirePasswordAfter"; formatValue: v => "After " + pane.duration(v); choices: [["Immediately", 0], ["After 5 seconds", 5], ["After 1 minute", 60], ["After 5 minutes", 300], ["After 15 minutes", 900], ["After 1 hour", 3600], ["After 8 hours", 28800]] }
        }
        FormRow {
            label: "Show large clock"
            StatePopup { stateKey: "lock"; field: "largeClock"; choices: [["On Screen Saver and Lock Screen", "screensaver"], ["On Lock Screen", "lock"], ["Never", "never"]] }
        }
    }
    Card {
        title: "When Switching User"
        FormRow { label: "Login window shows"; MacPopup { model: ["List of users", "Name and password"] } }
        FormRow { label: "Show the Sleep, Restart and Shut Down buttons"; MacSwitch { checked: true } }
        FormRow { label: "Show password hints"; MacSwitch {} }
    }
    PaneFooter {}
}
