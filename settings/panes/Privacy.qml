import QtQuick
import ".."
import "../controls"
import "../HyprK"

Column {
    spacing: Theme.content.sectionGap
    Card {
        id: privacy
        title: "Privacy"
        // icons as SecurityPrivacyExtension names them (TCCServiceList.plist: Contacts by bundle id, the others graphic
        // icons; Calendars / Photos / Accessibility have a service class there, their icon is taken to be the app's / the
        // pane's)
        readonly property string apps: "file://" + Backend.root + "/themes/icons/apps/"
        FormRow { iconId: "privacy-location"; label: "Location Services" }
        FormRow { iconSource: privacy.apps + "Contacts-128.png"; label: "Contacts" }
        FormRow { iconSource: privacy.apps + "Calendar-128.png"; label: "Calendars" }
        FormRow { iconSource: privacy.apps + "Photos-128.png"; label: "Photos" }
        FormRow { iconId: "privacy-microphone"; label: "Microphone" }
        FormRow { iconId: "privacy-camera"; label: "Camera" }
        FormRow { iconId: "privacy-screenrecording"; label: "Screen & System Audio Recording" }
        FormRow { iconId: "privacy-files"; label: "Files & Folders" }
        FormRow { iconId: "accessibility"; label: "Accessibility" }
    }
    Card {
        title: "Security"
        FormRow { label: "Allow applications from"; LocalPopup { model: ["App Store", "App Store & Known Developers"]; currentIndex: 1 } }
        FormRow { label: "FileVault"; sublabel: "Disk encryption is managed by your Linux installer."; value: "Off"; }
        FormRow { label: "Lockdown Mode"; Button { text: "Turn On…" } }
    }
    PaneFooter { }
}
