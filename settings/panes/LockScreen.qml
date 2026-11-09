import QtQuick
import ".."
import "../controls"

// Functional: idle timeouts go to state/lock.json (seconds, 0 = never), which the
// shell's idle/lock glue (hypridle + hyprlock) reads.
Column {
    id: pane
    spacing: Theme.content.sectionGap
    readonly property var l: AppState.lock

    // A pop-up bound to one lock.json key with [label, seconds] choices.
    component TimePopup: MacPopup {
        property string key
        property var choices: []
        model: choices.map(c => c[0])
        currentIndex: Math.max(0, choices.findIndex(c => c[1] === pane.l[key]))
        onActivated: i => AppState.set("lock", { [key]: choices[i][1] })
    }

    Card {
        FormRow {
            label: "Start Screen Saver when inactive"
            TimePopup { key: "screenSaverAfter"; choices: [["Never", 0], ["For 1 minute", 60], ["For 2 minutes", 120], ["For 5 minutes", 300], ["For 10 minutes", 600], ["For 20 minutes", 1200], ["For 30 minutes", 1800], ["For 1 hour", 3600]] }
        }
        FormRow {
            label: "Turn display off when inactive"
            TimePopup { key: "displayOffAfter"; choices: [["Never", 0], ["For 1 minute", 60], ["For 2 minutes", 120], ["For 5 minutes", 300], ["For 10 minutes", 600], ["For 20 minutes", 1200], ["For 30 minutes", 1800], ["For 1 hour", 3600], ["For 3 hours", 10800]] }
        }
        FormRow {
            label: "Require password after screen saver begins or display is turned off"
            TimePopup { key: "requirePasswordAfter"; choices: [["Immediately", 0], ["After 5 seconds", 5], ["After 1 minute", 60], ["After 5 minutes", 300], ["After 15 minutes", 900], ["After 1 hour", 3600], ["After 8 hours", 28800]] }
        }
        FormRow {
            label: "Show large clock"
            MacPopup {
                readonly property var keys: ["screensaver", "lock", "never"]
                model: ["On Screen Saver and Lock Screen", "On Lock Screen", "Never"]
                currentIndex: Math.max(0, keys.indexOf(pane.l.largeClock))
                onActivated: i => AppState.set("lock", { largeClock: keys[i] })
            }
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
