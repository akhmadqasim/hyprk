import QtQuick
import ".."
import "../controls"
import "../HyprK"

// 27.2.1 (R3.8b general-{00..02}-light.png, ax-general-light.jsonl): the hero card 164 tall, then cards of 48 pt rows
// (pitch 49) with a chevron: [About, Software Update, Storage] [AirDrop & Continuity]
// [AutoFill & Passwords, Date & Time, Language & Region, Login Items & Extensions, Sharing, Startup Disk, Time Machine]
// [Device Management] [Transfer or Reset]. AutoFill & Passwords and Device Management (R13.4) are here too: their tiles
// are not extracted (themes/icons/settings), so Passwords borrows its app's icon and Device Management has a plain tile.
// Not here by the user's choice (2026-11-15, settings/FALLBACKS.md "General"): the Mac's [AppleCare & Warranty] card
// between the first card and AirDrop & Continuity. The cards after it sit 58 pt higher than on the Mac. Do not add it back.
// Each row pushes its sub-pane (MAC-ANSWERS-12.md R12.3, live/settings-r12/nav-general--*-dark.png and ax-nav-general--*):
// panes/general/<file>.qml, on the window's navigation (SettingsApp.qml: toolbar title, Go Back; no header here).
Column {
    id: pane
    spacing: Theme.content.sectionGap
    property string page: ""          // "" = the pane's root, else a key of `subs`
    // the toolbar titles as the Mac's (Login Items & Extensions is "Login Items" there: R12.3)
    readonly property var subs: ({
        about: { title: "About", file: "About" },
        softwareupdate: { title: "Software Update", file: "SoftwareUpdate" },
        storage: { title: "Storage", file: "Storage" },
        airdrop: { title: "AirDrop & Continuity", file: "AirDrop" },
        datetime: { title: "Date & Time", file: "DateTime" },
        language: { title: "Language & Region", file: "Language" },
        loginitems: { title: "Login Items", file: "LoginItems" },
        sharing: { title: "Sharing", file: "Sharing" },
        startupdisk: { title: "Startup Disk", file: "StartupDisk" },
        timemachine: { title: "Time Machine", file: "TimeMachine" },
        transfer: { title: "Transfer or Reset", file: "Transfer" },
        passwords: { title: "AutoFill & Passwords", file: "Passwords" },
        devicemanagement: { title: "Device Management", file: "DeviceManagement" }
    })
    readonly property string pageTitle: subs[page] ? subs[page].title : ""
    // the hero title's bottom (HeroCard: 25.5 + the 50 pt tile + 10.5 + the 26 pt title frame): the toolbar shows
    // "General" once it has scrolled under it
    readonly property real toolbarTitleAfter: 112
    HeroCard {
        visible: pane.page === ""; iconId: "general"; tint: Theme.tile.gray; title: "General"; text: "Manage your overall setup and preferences for Mac, such as software updates, device language, AirDrop, and more." }   // GeneralSettings.appex Localizable.loctable
    // a row: 48 tall (+ the separator), the extension's tile, a chevron.forward as Accessibility's rows (the ink 10.5 pt
    // inside the card: px 1408..1418 of the 1480 window on general-00-light.png)
    // the tile 22 at 12.5 in, the label at 47.5 (general-00-light.png: tile ink 529..574 px, "About" ink from 600 px,
    // the card at 504 px)
    component Row48: FormRow {
        property string sub
        objectName: "generalRow-" + sub
        onClicked: pane.page = sub
        implicitHeight: Positioner.index > 0 ? 49 : 48
        iconSize: 22; iconX: 12.5; labelGap: 13
        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 6; height: 10
            SfSymbol { name: "chevron.forward"; weight: "semibold"; pointSize: 10.5; color: Theme.tertiaryLabel }
        }
    }
    Card {
        visible: pane.page === ""
        // each row: its sub-pane extension's own icon (themes/icons/settings/graphic.json). About is ISCurrentDevice on the
        // Mac, the model's symbol: here a laptop with a battery, else a desktop computer.
        Row48 { iconId: AppState.hasBattery ? "general-about-laptop" : "general-about"; label: "About"; sub: "about" }
        Row48 { iconId: "general-softwareupdate"; label: "Software Update"; sub: "softwareupdate" }
        Row48 { iconId: "general-storage"; label: "Storage"; sub: "storage" }
    }
    Card {
        visible: pane.page === ""
        Row48 { iconId: "general-airdrop"; label: "AirDrop & Continuity"; sub: "airdrop" }   // 27.2.1's name (was AirDrop & Handoff)
    }
    Card {
        visible: pane.page === ""
        Row48 { iconSource: Backend.appIconUrl("", "", Theme.iconLook, "Passwords"); label: "AutoFill & Passwords"; sub: "passwords" }
        Row48 { iconId: "general-datetime"; label: "Date & Time"; sub: "datetime" }
        Row48 { iconId: "general-language"; label: "Language & Region"; sub: "language" }
        Row48 { iconId: "general-loginitems"; label: "Login Items & Extensions"; sub: "loginitems" }
        Row48 { iconId: "general-sharing"; label: "Sharing"; sub: "sharing" }
        Row48 { iconId: "general-startupdisk"; label: "Startup Disk"; sub: "startupdisk" }
        Row48 { iconId: "general-timemachine"; label: "Time Machine"; sub: "timemachine" }
    }
    Card {
        visible: pane.page === ""
        Row48 { iconId: "general-devicemanagement"; tint: Theme.tile.black; label: "Device Management"; sub: "devicemanagement" }
    }
    Card {
        visible: pane.page === ""
        Row48 { iconId: "general-transfer"; label: "Transfer or Reset"; sub: "transfer" }
    }
    // ---------- sub-pane ----------
    Loader {
        id: sub
        objectName: "generalSub"
        width: parent.width
        function load() {
            const r = pane.subs[pane.page];
            if (r) setSource("general/" + r.file + ".qml", { pane: pane });
            else source = "";
        }
        Connections { target: pane; function onPageChanged() { sub.load(); } }
    }
}
