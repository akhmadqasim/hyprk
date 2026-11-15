import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// General > Date & Time (27.2.1, live/settings-r12/nav-general--dateAndTime-dark.png, ax-nav-...): [Set time and date
// automatically, Source + Set…] [Date and time, 24-hour time] [Set time zone automatically using your current
// location, Time zone, Time zone city], Help. The clock and the zone are this computer's (read-only); the switches
// keep the Mac's values, nothing is written (settings/FALLBACKS.md "General").
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    property date now: new Date()
    property string zone: ""
    Timer { interval: 1000; running: true; repeat: true; onTriggered: page.now = new Date() }
    Component.onCompleted: Backend.run(["sh", "-c", "readlink /etc/localtime || head -n 1 /etc/timezone"], (c, out) => {
        const m = /([^\/\s]+\/[^\/\s]+)\s*$/.exec(out);
        if (m) try { page.zone = m[1]; } catch (e) {}   // the page may be gone
    })
    Card {
        FormRow { label: "Set time and date automatically"; LocalSwitch { checked: true } }
        FormRow { label: "Source"; value: "Apple (time.apple.com.)"; Button { text: "Set…" } }
    }
    Card {
        FormRow { label: "Date and time"; value: Qt.formatDateTime(page.now, "d MMM yyyy") + " at " + Qt.formatDateTime(page.now, "HH:mm:ss") }
        FormRow { label: "24-hour time"; LocalSwitch { checked: true } }
    }
    Card {
        FormRow { label: "Set time zone automatically using your current location"; LocalSwitch { checked: true } }
        FormRow { label: "Time zone"; value: Qt.formatDateTime(page.now, "t") }
        FormRow { label: "Time zone city"; value: page.zone.replace(/^.*\//, "").replace(/_/g, " ") }
    }
    PaneFooter {}
}
