import QtQuick
import ".."
import "../controls"
import "../HyprK"

// Menu Bar, 27.2.1 (R3.8b control-center-{00..05}-light.png, ax-control-center-light.jsonl). The pane was the older
// "Control Center Modules" / "Menu Bar Only" layout; now the Mac's rows in its order. No backend reads them yet (held
// here, as before). Not here: the Menu Bar Controls card's illustration (not extracted); the rows Screen Mirroring,
// Keyboard Brightness, Timer and Weather (their tiles are not extracted); "Allow in the Menu Bar" (the apps' own menu bar
// items: no list of them here).
Column {
    id: pane
    spacing: Theme.content.sectionGap

    Card {
        FormRow { label: "Automatically hide and show the menu bar"; LocalPopup { model: ["Always", "On Desktop Only", "In Full Screen Only", "Never"]; currentIndex: 2 } }
        FormRow { label: "Show menu bar background"; LocalSwitch {} }
        FormRow { label: "Recent documents, applications and servers"; LocalPopup { model: ["None", "5", "10", "15", "20", "30", "50"]; currentIndex: 2 } }   // popups.json "controlCenter"
    }
    Card {
        FormRow { label: "Show suggestions in Control Gallery"; LocalSwitch { checked: true } }
    }

    // the description card: 79 tall, text 254 wide at 10 / 10 (2 lines, 11 pt), "Add Controls…" 10 in, 45 below the top
    Card {
        title: "Menu Bar Controls"
        Item {
            width: parent.width; height: 79
            Text {
                // 254 on the Mac (AX); 262 here so "bar." stays on the 2nd line as on the Mac (our 11 pt runs ~2 % wider)
                x: Theme.content.rowPadding; y: 10; width: 262
                wrapMode: Text.WordWrap
                text: "System and app controls can be configured to appear in both Control Center and the menu bar."
                font: Typography.subheadline
                color: Theme.secondaryLabel
            }
            Button { x: Theme.content.rowPadding; y: 45; text: "Add Controls…" }
        }
    }

    // a control: checkbox (16 pt, 13.5 in), the control's tile (22 pt, 37 in), its name (ink 64 in); rows 42 + the
    // separator (the list card 776.5 for 18 rows); a pop-up or button at the right, its pop-up off with the checkbox
    component Control: Item {
        id: c
        property string icon
        property string name
        property bool check: true          // Clock has no checkbox
        property bool on: false
        default property alias trailing: trail.data
        width: parent ? parent.width : 0
        height: Positioner.index > 0 ? 43 : 42
        Rectangle {
            visible: c.Positioner.index > 0
            x: Theme.content.separatorInset; width: parent.width - 2 * x; height: 1
            color: Theme.separator
        }
        Item {
            y: c.height - 42; width: parent.width; height: 42
            Checkbox {
                visible: c.check
                x: 13.5; anchors.verticalCenter: parent.verticalCenter
                checked: c.on
                onToggled: v => c.on = v
            }
            PaneIcon { id: ic; x: 37; anchors.verticalCenter: parent.verticalCenter; size: 22; iconId: c.icon }
            MacText { x: ic.x + 22 + 4.5; anchors.verticalCenter: parent.verticalCenter; text: c.name }
            Row {
                id: trail
                anchors.right: parent.right; anchors.rightMargin: Theme.content.rowPadding
                anchors.verticalCenter: parent.verticalCenter
                enabled: !c.check || c.on
            }
        }
    }
    Card {
        Control { icon: "menubar-clock"; name: "Clock"; check: false; Button { objectName: "menuBarClockButton"; text: "Clock Options…"; onClicked: clockOptions.open() } }
        Control { icon: "siri"; name: "Siri" }
        // controls of hardware this computer does not have are not listed (AppState.hw, FALLBACKS.md "Absent hardware")
        Control { objectName: "menuBarWifiControl"; visible: AppState.hw.wifi; icon: "wifi"; name: "Wi‑Fi"; on: true }
        Control { objectName: "menuBarBluetoothControl"; visible: AppState.hw.bluetooth; icon: "bluetooth"; name: "Bluetooth" }
        Control { objectName: "menuBarBatteryControl"; visible: AppState.hasBattery; icon: "battery"; name: "Battery"; on: true; Button { objectName: "menuBarBatteryButton"; text: "Battery Options…"; onClicked: batteryOptions.open() } }
        Control { objectName: "menuBarAirdropControl"; visible: AppState.hw.airdrop; icon: "general-airdrop"; name: "AirDrop" }
        Control { icon: "focus"; name: "Focus"; LocalPopup { model: ["Always Show", "Show When Active"] } }
        Control { icon: "display"; name: "Display"; on: true; LocalPopup { model: ["Always Show", "Show When Active"]; currentIndex: 1 } }
        Control { icon: "sound"; name: "Sound"; on: true; LocalPopup { model: ["Always Show", "Show When Active"]; currentIndex: 1 } }
        Control { icon: "menubar-nowplaying"; name: "Now Playing"; on: true; LocalPopup { model: ["Always Show", "Show When Active"]; currentIndex: 1 } }
        Control { icon: "users"; name: "Fast User Switching"; LocalPopup { model: ["Full Name", "Account Name", "Icon"]; currentIndex: 2 } }
        Control { icon: "keyboard"; name: "Text Input"; on: true }
        Control { icon: "general-timemachine"; name: "Time Machine" }
        Control { icon: "vpn"; name: "VPN" }
    }

    // ax-control-center-light.jsonl 1856.5: Reset Control Centre… (161.5 wide), Help
    PaneFooter { Button { text: "Reset Control Center…" } }

    // ---------- sheets (MAC-ANSWERS-13.md R13.1; live/settings-r13/dest-controlCenter--*-options-*.png, ax-dest-controlCenter--*) ----------
    // Clock Options…: 470 x 533 at y 52. "Date" [Show date, Show the day of the week], "Time" [Style Digital / Analog,
    // Flash the time separators, Display the time with seconds], [Announce the time, Interval, Voice + ⓘ], Customize
    // Voice…; the last three are disabled while Announce the time is off. The Mac's values: the shell's clock reads
    // none of them (settings/FALLBACKS.md). The other items of Interval and Voice are not on a shot.
    SubSheet {
        id: clockOptions
        objectName: "menuBarClock"
        sheetWidth: 470; sheetHeight: 533; sheetTop: 52
        // Row heights from ax-dest-controlCenter--clock-options-light.jsonl (sheet at 485,202): the cards are 74, 111.5
        // and 116 pt (Date 248..322, Time 378..489.5, the third 499.5..615.5): a card's last row is 1 pt shorter than
        // the 37.5 of the others (no hairline under it), the radio row is 37.5, and the pop-ups sit at 341 and 379.5
        // in the sheet (centres 353 and 391.5). With the shared row heights the rows stood 1.5 to 3 pt low
        Column {
            x: 20; y: 20; width: 430
            spacing: Theme.content.sectionGap
            Card {
                title: "Date"
                FormRow { label: "Show date"; LocalSwitch { checked: true } }
                FormRow { label: "Show the day of the week"; implicitHeight: 36.5; LocalSwitch { checked: true } }
            }
            Card {
                title: "Time"
                FormRow {
                    label: "Style"
                    implicitHeight: 37.5
                    Row {
                        id: style
                        property int current: 0
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16
                        Repeater {
                            model: ["Digital", "Analog"]
                            Checkbox { required property string modelData; required property int index; radio: true; text: modelData; checked: index === style.current; onToggled: style.current = index }
                        }
                    }
                }
                FormRow { label: "Flash the time separators"; LocalSwitch {} }
                FormRow { label: "Display the time with seconds"; implicitHeight: 36.5; LocalSwitch {} }
            }
            Card {
                FormRow { label: "Announce the time"; LocalSwitch { id: announce; objectName: "clockAnnounce" } }
                // with "Announce the time" off only the values are dimmed: the two labels keep the label colour (dest-
                // controlCenter--clock-options-*.png: 38 light / 222 dark, as the rows above)
                FormRow { label: "Interval"; implicitHeight: 37; LocalPopup { objectName: "clockInterval"; enabled: announce.checked; model: ["On the hour"] } }
                FormRow {
                    label: "Voice"; implicitHeight: 39
                    LocalPopup { enabled: announce.checked; model: ["System Voice"] }
                    InfoButton { opacity: announce.checked ? 1 : 0.5 }
                }
                Item { width: 1; height: 2.5 }
            }
            Item {
                width: parent.width; height: 24
                Button { anchors.right: parent.right; enabled: announce.checked; text: "Customize Voice…" }
            }
        }
    }
    // Battery Options…: 470 x 210: "Options" [Show Percentage, Show Energy Mode "Always"]. The Mac's values; the other
    // items of Show Energy Mode are not on a shot.
    SubSheet {
        id: batteryOptions
        objectName: "menuBarBattery"
        sheetWidth: 470; sheetHeight: 210
        Card {
            x: 20; y: 20; width: 430
            title: "Options"
            FormRow { label: "Show Percentage"; LocalSwitch {} }
            FormRow { label: "Show Energy Mode"; LocalPopup { model: ["Always"] } }
        }
    }
}
