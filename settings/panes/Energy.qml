import QtQuick
import ".."
import "../controls"
import "../HyprK"

// Shown as "Battery" on laptops and "Energy" on desktops (hasBattery). Visual only.
Column {
    spacing: Theme.content.sectionGap
    Card {
        visible: AppState.hasBattery
        FormRow { label: "Low Power Mode"; LocalPopup { model: ["Never", "Always", "Only on Battery", "Only on Power Adapter"] } }
        FormRow { label: "Battery Health"; value: "Normal"; }
    }
    Card {
        visible: !AppState.hasBattery
        FormRow { label: "Low Power Mode"; LocalPopup { model: ["Never", "Always"] } }
        FormRow { label: "Prevent automatic sleeping when the display is off"; LocalSwitch {} }
        FormRow { label: "Wake for network access"; LocalSwitch { checked: true } }
        FormRow { label: "Start up automatically after a power failure"; LocalSwitch {} }
    }
    // a laptop: Options… (ax-dest-battery-dark.jsonl "options", 82 x 24); the desktop's button is not on a Mac shot
    PaneFooter {
        Button { objectName: "batteryOptionsButton"; visible: AppState.hasBattery; text: "Options…"; onClicked: options.open() }
        Button { visible: !AppState.hasBattery; text: "Schedule…" }
    }

    // Options… (MAC-ANSWERS-13.md R13.1; live/settings-r13/dest-battery--options-*.png, ax-dest-battery--options-*):
    // 470 x 347, one card of four rows. The Mac's values; no power backend reads them (settings/FALLBACKS.md). The
    // other items of "Wake for network access" are not on a shot.
    SubSheet {
        id: options
        objectName: "batteryOptions"
        sheetWidth: 470; sheetHeight: 347
        Card {
            x: 20; y: 20; width: 430
            FormRow { label: "Slightly dim the display on battery"; LocalSwitch {} }
            FormRow { implicitHeight: 53; label: "Prevent automatic sleeping on power adapter when the display is off"; LocalSwitch { checked: true } }   // a 2-line label: 10 pt above and below
            FormRow {
                sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                label: "Wake for network access"
                sublabel: "While sleeping, your Mac can receive incoming network traffic, such as iMessages and other iCloud updates, to keep your applications up to date."
                Item { width: 16; height: 1 }
                LocalPopup { model: ["Always"] }
            }
            FormRow {
                sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                label: "Optimize video streaming while on battery"
                sublabel: "To increase battery life, your Mac will stream high dynamic range (HDR) video in standard dynamic range (SDR)."
                LocalSwitch {}
            }
        }
    }
}
