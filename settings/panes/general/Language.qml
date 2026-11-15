import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// General > Language & Region (27.2.1, live/settings-r12/nav-general--languageAndRegion-dark.png, ax-nav-...):
// Preferred Languages (a list in the card, + / −), the format samples over Region, Calendar, Temperature, Measurement
// system, First day of week, Date format and Number format, Live Text, Applications (an empty list, + / −),
// Translation Languages… and Help. The language, region and samples are the session locale's, read-only; nothing is
// written (settings/FALLBACKS.md "General"). The pop-ups show the current value only: their items are not on a shot.
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    readonly property var loc: Qt.locale()
    readonly property date now: new Date()
    readonly property bool metric: loc.measurementSystem === Locale.MetricSystem
    component ListHead: Item {
        property string title
        property string line
        width: parent.width; height: line !== "" ? 42.5 : 36.5
        MacText { x: 10; y: 10; text: parent.title; font: Typography.headline }
        Text { visible: parent.line !== ""; x: 10; y: 27.5; text: parent.line; font: Typography.subheadline; color: Theme.secondaryLabel }
    }
    Card {
        ListHead { title: "Preferred Languages" }
        Item {
            width: parent.width; height: 57
            Rectangle { width: parent.width; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            MacText { x: 10; y: 4.5; text: page.loc.nativeLanguageName }
            MacText { x: 168; y: 4.5; text: page.loc.nativeLanguageName + " — Primary"; color: Theme.secondaryLabel }
        }
        ListBar {}
    }
    Card {
        Item {
            width: parent.width; height: 49.5
            Text { anchors.horizontalCenter: parent.horizontalCenter; y: 9.5; text: page.now.toLocaleString(page.loc, Locale.LongFormat); font: Typography.subheadline; color: Theme.secondaryLabel }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter; y: 25
                text: page.now.toLocaleString(page.loc, Locale.ShortFormat) + "    " + Number(12345.67).toLocaleCurrencyString(page.loc) + "    " + Number(4567.89).toLocaleString(page.loc, "f", 2)
                font: Typography.subheadline; color: Theme.secondaryLabel
            }
        }
        FormRow { implicitHeight: 41; label: "Region"; LocalPopup { model: [page.loc.nativeTerritoryName] } }
        FormRow { label: "Calendar"; LocalPopup { model: ["Gregorian"] } }
        FormRow {
            label: "Temperature"
            Checkbox { radio: true; property bool on: page.metric; checked: on; onToggled: on = true; text: "Celsius (°C)"; anchors.verticalCenter: parent.verticalCenter }
            Checkbox { radio: true; checked: !parent.children[1].on; onToggled: parent.children[1].on = false; text: "Fahrenheit (°F)"; anchors.verticalCenter: parent.verticalCenter }
        }
        FormRow {
            id: measure
            property int pick: page.loc.measurementSystem === Locale.MetricSystem ? 0 : page.loc.measurementSystem === Locale.ImperialUKSystem ? 2 : 1
            label: "Measurement system"
            Checkbox { radio: true; checked: measure.pick === 0; onToggled: measure.pick = 0; text: "Metric"; anchors.verticalCenter: parent.verticalCenter }
            Checkbox { radio: true; checked: measure.pick === 1; onToggled: measure.pick = 1; text: "US"; anchors.verticalCenter: parent.verticalCenter }
            Checkbox { radio: true; checked: measure.pick === 2; onToggled: measure.pick = 2; text: "UK"; anchors.verticalCenter: parent.verticalCenter }
        }
        FormRow { label: "First day of week"; LocalPopup { model: [page.loc.dayName(page.loc.firstDayOfWeek, Locale.LongFormat)] } }
        FormRow { label: "Date format"; LocalPopup { model: [new Date(2026, 7, 19).toLocaleDateString(page.loc, Locale.ShortFormat)] } }
        FormRow { label: "Number format"; LocalPopup { model: [Number(1234567.89).toLocaleString(page.loc, "f", 2)] } }
    }
    Card {
        FormRow { sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14; label: "Live Text"; sublabel: "Select text in images to copy or take action."; LocalSwitch { checked: true } }
    }
    Card {
        ListHead { title: "Applications"; line: "Customize language settings for the following applications:" }
        Item { width: parent.width; height: 38.5 }
        ListBar {}
    }
    PaneFooter { Button { text: "Translation Languages…" } }
}
