import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// Focus > a mode (27.2.1, live/settings-r13/dest-focus--<mode>-{dark,light}.png and ax-dest-focus--*): the mode's tile
// and name on a card (51 tall; 45 for Do Not Disturb and Reduce Interruptions), Intelligent Breakthrough and
// Silencing, Allow Notifications (Allowed People, Allowed Apps: 51 pt rows into pickers), Set a Schedule, Focus
// Filters, then Help and "Delete Focus…" (none on Do Not Disturb). Driving and Sleep follow the iPhone: a line with an
// icon instead of the schedule. The Mac's own people, apps and its Work location are not copied: "None allowed" and
// "No Schedules", as its unconfigured modes show. No Focus backend: the switch keeps its own state, the rows and
// buttons take the press only (settings/FALLBACKS.md "Focus").
Column {
    id: page
    property var pane
    property var mode
    spacing: Theme.content.sectionGap
    readonly property color tint: Theme.dark ? mode.dark : mode.light

    component Picker: FormRow {
        implicitHeight: Positioner.index > 0 ? 52 : 51
        sublabelGap: 2
        NavChevron {}
    }
    component Empty: Item {
        property alias text: t.text
        width: parent ? parent.width : 0; height: 36
        Text { id: t; anchors.centerIn: parent; font: Typography.subheadline; color: Theme.secondaryLabel }
    }

    Rectangle {
        width: parent.width; height: page.mode.short ? 45 : 51
        radius: Theme.content.cardRadius; color: Theme.cardFill; border.color: Theme.cardStroke
        Rectangle {
            id: tile
            x: 14; anchors.verticalCenter: parent.verticalCenter
            width: 23; height: 23; radius: 6
            color: page.tint
            SfSymbol { anchors.centerIn: parent; name: page.mode.symbol; pointSize: 12; color: "white" }
        }
        MacText { objectName: "focusModeName"; x: 44; anchors.verticalCenter: parent.verticalCenter; text: page.mode.name }
    }
    Card {
        FormRow {
            dim: page.mode.locked === true
            label: "Intelligent Breakthrough and Silencing"
            sublabel: "When " + page.mode.name + (page.mode.short ? "" : " Focus") + " is active, intelligently allow priority notifications to interrupt you and silence other notifications. Any notifications specifically allowed or silenced will always be allowed or silenced."
            sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
            LocalSwitch { objectName: "focusIntelligent"; checked: page.mode.locked === true; enabled: page.mode.locked !== true }
        }
    }
    Card {
        title: "Allow Notifications"
        subtitle: "Notifications from selected people and apps will be allowed; all others will be silenced."
        subtitleLineHeight: 14
        subtitleWidth: 390   // ax notifications-footer 612..1002 in two lines, "... all others will / be silenced." (r13)
        Picker { label: "Allowed People"; sublabel: "None allowed" }
        Picker { visible: page.mode.apps; label: "Allowed Apps"; sublabel: "None allowed" }
    }
    // the Mac leaves 51 pt under this card, to a heading (ax: 393.5 to 444.5) and to the iPhone line's card alike
    Item { width: 1; height: page.mode.note !== undefined ? 31 : 11 }
    Card {
        visible: page.mode.note !== undefined
        Item {
            width: parent.width; height: note.height + 20
            // the Mac's icons: the Health app's (Sleep) and the Settings gear (Driving), 23 pt
            PaneIcon { visible: page.mode.noteIcon === "settings"; x: 12; y: 12; size: 20; imageSource: Backend.appIconUrl("", "", Theme.iconLook, "System_Settings") }
            Rectangle {
                visible: page.mode.noteIcon === "health"
                x: 13; y: 11; width: 23; height: 23; radius: 6; color: "white"
                Text { anchors.centerIn: parent; text: "♥"; font.pixelSize: 15; color: "#FF2D55" }
            }
            Text {
                id: note
                x: page.mode.noteIcon === "settings" ? 43 : 40; y: 10; width: parent.width - x - 10; wrapMode: Text.WordWrap
                lineHeight: 16; lineHeightMode: Text.FixedHeight
                text: page.mode.note || ""
                font: Typography.body; color: Theme.label
            }
        }
    }
    Card {
        visible: page.mode.schedule
        title: "Set a Schedule"
        subtitle: "Have this Focus turn on automatically at a set time or location, or while using a certain app."
        subtitleLineHeight: 14
        Empty { visible: page.mode.empty === true; text: "No Schedules" }
        CardButtons { Button { text: "Add Schedule…" } }
    }
    Card {
        visible: page.mode.filters
        title: "Focus Filters"
        subtitle: "Customize how your apps and device behave when this Focus is on."
        Empty { text: "No Focus filters" }
        CardButtons { Button { text: "Add Filter…" } }
    }
    Row {   // Help, then Delete Focus… at the right edge (ax 574 / 606 .. 720)
        anchors.right: parent.right
        topPadding: 10; spacing: 8
        HelpButton {}
        Button { visible: page.mode.remove; text: "Delete Focus…" }
    }
}
