import QtQuick
import ".."
import "../controls"
import "../HyprK"

// Saves idle timeouts to state/lock.json (seconds, 0 = never) for the session's
// idle/lock glue (hypridle + hyprlock) to read. Nothing reads it yet; see FALLBACKS.md.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    function duration(s) { return s % 3600 === 0 ? s / 3600 + " h" : s % 60 === 0 ? s / 60 + " min" : s + " s"; }
    function forTime(s) { return "For " + duration(s); }

    // 27.2.1 (R3.8b lock-screen-00-light.png, ax-lock-screen-light.jsonl, a MacBook Air): display off on battery / on
    // power adapter (one row without a battery), the adapter's warning line when it is Never, Require password; a card
    // of switches (Show message when locked with Set…); When Switching User with two radios; Accessibility Options….
    // Removed (not in 27.2.1's pane): "Start Screen Saver when inactive" and "Show large clock" (state/lock.json fields
    // nothing read). Not here: the iPhone Mirroring line and "Show Live Activities when locked" (no iPhone here).
    // R13.2 popups.json: 13 items, Never last
    readonly property var offChoices: [["For 1 minute", 60], ["For 2 minutes", 120], ["For 3 minutes", 180], ["For 5 minutes", 300], ["For 10 minutes", 600], ["For 20 minutes", 1200], ["For 30 minutes", 1800], ["For 1 hour", 3600], ["For 1 hour, 30 minutes", 5400], ["For 2 hours", 7200], ["For 2 hours, 30 minutes", 9000], ["For 3 hours", 10800], ["Never", 0]]
    Card {
        FormRow {
            visible: AppState.hasBattery
            label: "Turn display off on battery when inactive"
            LocalPopup { objectName: "lockOffBattery"; model: pane.offChoices.map(c => c[0]); currentIndex: 4 }
        }
        FormRow {
            label: AppState.hasBattery ? "Turn display off on power adapter when inactive" : "Turn display off when inactive"
            sublabel: AppState.lock.displayOffAfter === 0 ? "Never letting your display turn off may shorten its lifespan and increase energy usage." : ""
            StatePopup { objectName: "lockOffAdapter"; stateKey: "lock"; field: "displayOffAfter"; formatValue: pane.forTime; choices: pane.offChoices }
        }
        FormRow {
            label: "Require password after screen saver begins or display is turned off"
            StatePopup { objectName: "lockRequirePassword"; stateKey: "lock"; field: "requirePasswordAfter"; formatValue: v => "After " + pane.duration(v); choices: [["Immediately", 0], ["After 5 seconds", 5], ["After 1 minute", 60], ["After 5 minutes", 300], ["After 15 minutes", 900], ["After 1 hour", 3600], ["After 8 hours", 28800]] }
        }
    }
    Card {
        FormRow { label: "Show username and photo"; LocalSwitch { checked: true } }
        FormRow { label: "Show password hints"; LocalSwitch {} }
        FormRow { label: "Show message when locked"; LocalSwitch { id: msgOn } Button { text: "Set…"; enabled: msgOn.checked } }
    }
    Card {
        title: "When Switching User"
        FormRow {   // two radios (ax: List of users at 222.5, Name and password at 334)
            label: "Login window shows"
            Row {
                spacing: 16
                property int current: 0
                Checkbox { radio: true; text: "List of users"; checked: parent.current === 0; onToggled: parent.current = 0 }
                Checkbox { radio: true; text: "Name and password"; checked: parent.current === 1; onToggled: parent.current = 1 }
            }
        }
        FormRow { label: "Show the Sleep, Restart and Shut Down buttons"; LocalSwitch { checked: true } }
    }
    PaneFooter { helpAnchor: "mh11784"; Button { objectName: "lockAccessibilityButton"; text: "Accessibility Options…"; onClicked: axOptions.open() } }   // LockScreen.appex: "Change Lock Screen settings on Mac"

    // Accessibility Options… (MAC-ANSWERS-13.md R13.1, live/settings-r13/dest-lockScreen--accessibility-options-*.png,
    // ax-dest-...): a sheet 470 x 479 at y 73: "Accessibility", six switches (off; ax 539,129.5 then every 37.5), two
    // lines of text, Done. The login window here has none of these features: the switches keep their own state
    // (settings/FALLBACKS.md "Sheets").
    SubSheet {
        id: axOptions
        objectName: "lockAccessibility"
        sheetWidth: 470; sheetHeight: 479
        Column {
            x: 20; y: 20; width: 430
            Card {
                title: "Accessibility"
                Repeater {
                    model: ["VoiceOver", "Zoom", "Accessibility Keyboard *", "Sticky Keys", "Slow Keys", "Mouse Keys"]
                    FormRow { required property string modelData; required property int index; label: modelData; LocalSwitch { objectName: "lockAx" + index } }
                }
            }
            Text {
                topPadding: 19; leftPadding: 10; width: 430; rightPadding: 10; wrapMode: Text.WordWrap
                lineHeight: 14; lineHeightMode: Text.FixedHeight
                text: "Turning off a feature disables that feature for all users at the login window but can be turned back on by the accessibility shortcut menu.\n\n* By turning on a feature, your own configurations will be used for all users at the login window."
                font: Typography.subheadline; color: Theme.secondaryLabel
            }
        }
    }
}
