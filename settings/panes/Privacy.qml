import QtQuick
import ".."
import "../controls"
import "../HyprK"
import "privacy/PrivacyData.js" as PD

// 27.2.1 (R3.8b privacy-security-{00..05}-light.png, ax-privacy-security-light.jsonl; MAC-ANSWERS-13.md R13.1,
// live/settings-r13/ax-dest-privacyAndSecurity--advanced-dark.jsonl for the whole root): a compact hero, Location
// Services on its own card, the data classes (52 pt rows, the access under the name), the device classes (42 pt rows,
// the count at the end), four cards of single topics, then Security: Allow applications from, FileVault, Accessories,
// Background Security Improvements, and Lockdown Mode with its line; Advanced… and Help.
// All 33 rows push their sub-pane on the window's navigation (SettingsApp.qml): panes/privacy/ (PrivacyData.js).
// Advanced… is a sheet 470 x 199. No TCC here and the Mac's applications are redacted: no application is listed and
// the counts are the Mac's wording for none (PrivacyData.js; settings/FALLBACKS.md "Privacy & Security"). Row tiles
// the icon set does not have are the Mac's own, cut from its rows (MAC-ANSWERS-14.md R14.3, Panes.cropIcons).
Column {
    id: pane
    spacing: Theme.content.sectionGap
    property string page: ""          // "" = the root, else a class id of PrivacyData.js
    readonly property var cls: PD.find(page)
    readonly property string pageTitle: cls ? cls.title : ""
    function app(name) { return Backend.appIconUrl("", "", Theme.iconLook, name); }

    component Nav: FormRow {
        property var c
        objectName: "privacyRow-" + c.id
        implicitHeight: (c.sub !== undefined ? 52 : 42) + (Positioner.index > 0 ? 1 : 0)
        iconId: c.app !== undefined ? "" : c.icon || ""
        iconSource: c.app !== undefined ? pane.app(c.app) : ""
        tint: Theme.tile.black
        label: c.label || c.title
        sublabel: c.sub || ""; sublabelGap: 2
        value: c.value || ""
        onClicked: pane.page = c.id
        NavChevron {}
    }
    HeroCard {
        visible: pane.page === ""
        compact: true
        iconId: "privacy"
        title: "Privacy"
        text: "Control which apps can access your data, location, camera and microphone, and manage safety protections."
        link: "Learn more…"
        helpAnchor: "mchl0b8771e8"   // ax-privacy-security-light.jsonl
    }
    Repeater {
        model: PD.groups
        Card {
            id: group
            required property var modelData
            visible: pane.page === ""
            Repeater { model: group.modelData; Nav { required property var modelData; c: modelData } }
        }
    }
    Card {
        visible: pane.page === ""
        title: "Security"
        FormRow { label: "Allow applications from"; LocalPopup { objectName: "privacyAllowApps"; model: ["App Store", "App Store & Known Developers"]; currentIndex: 1 } }
    }
    Card {   // privacy-security-05-dark.png: the pop-up on its own card, the three rows on the next
        visible: pane.page === ""
        Repeater { model: PD.security; Nav { required property var modelData; c: modelData } }
    }
    Card {
        visible: pane.page === ""
        // ax 1771 / 1822.9: the row, then its line under the card
        Nav { c: PD.lockdown }
        footer: "Your Mac can reduce your exposure to digital threats by applying security limits to apps and features. This is intended for people in high-risk situations, such as journalists, activists and public figures."
    }
    PaneFooter { visible: pane.page === ""; Button { objectName: "privacyAdvancedButton"; text: "Advanced…"; onClicked: advanced.open() } }

    // ---------- sub-pane ----------
    Loader {
        id: sub
        objectName: "privacySub"
        width: parent.width
        function load() {
            const c = pane.cls;
            if (c) setSource("privacy/" + (c.file || "AppList") + ".qml", { pane: pane, cls: c });
            else source = "";
        }
        Connections { target: pane; function onPageChanged() { sub.load(); } }
    }

    // Advanced… (dest-privacyAndSecurity--advanced-*.png, ax-dest-...): 470 x 199, two switches (off: ax 539,243.5 and
    // 539,296.5), Help at the strip's left, Done. No policy backend: they keep their own state.
    SubSheet {
        id: advanced
        objectName: "privacyAdvanced"
        sheetWidth: 470; sheetHeight: 199
        help: true
        Column {
            x: 20; y: 20; width: 430
            Card {
                FormRow { implicitHeight: 52; alignTop: true; label: "Require an administrator password to access systemwide settings"; LocalSwitch { objectName: "privacyAdminSwitch" } }
                FormRow { label: "Log out automatically after inactivity"; LocalSwitch {} }
            }
        }
    }
}
