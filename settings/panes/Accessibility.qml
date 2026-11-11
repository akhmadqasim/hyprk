import QtQuick
import ".."
import "../controls"
import "../HyprK"

// macOS 27 Accessibility: overview grouped Vision / Hearing / Motor / Speech / General
// (rows from support.apple.com mchlp1400, macOS 27); each row opens a sub-page from
// panes/accessibility/. What works on Linux and the fallbacks: settings/FALLBACKS.md
// "Accessibility". State: state/accessibility.json + appearance.json (A11yCtl.qml).
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string page: ""          // "" = overview, else a row id below
    readonly property var current: _rows.find(r => r.id === page) || null

    // Created by URL: Quickshell only registers QML types of directories reached by
    // static imports, and the panes are loaded by Loader (same for the sub-pages).
    readonly property QtObject ctl: Qt.createComponent("accessibility/A11yCtl.qml").createObject(pane)
    // HYPRK_A11Y_PAGE=<row id> opens a sub-page (snapshots, deep links)
    Component.onCompleted: Backend.run(["printenv", "HYPRK_A11Y_PAGE"], (c, out) => {
        if (c === 0 && _rows.some(r => r.id === out.trim())) page = out.trim();
    })

    // id, title, icon, page file in accessibility/ (none = Unsupported.qml showing `about`). Icons: the row tiles of
    // AccessibilityUIServer's / the extension's graphic icon UTIs (themes/icons/settings/graphic.json); the 7 Vision rows
    // against accessibility-{light,dark}.png: tile body rms 7.8-16.6. Keyboard and Siri: the pane's icon (their UTI was not found).
    readonly property var sections: [
        { title: "Vision", rows: [
            { id: "voiceover", title: "VoiceOver", icon: "ax-voiceover", file: "VoiceOver" },
            { id: "zoom", title: "Zoom", icon: "ax-zoom", file: "Zoom" },
            { id: "hovertext", title: "Hover Text", icon: "ax-hovertext", about: "Show a larger version of the text under the pointer, or of what you type." },
            { id: "display", title: "Display", icon: "display", file: "Display" },
            { id: "motion", title: "Motion", icon: "ax-motion", file: "Motion" },
            { id: "readspeak", title: "Read & Speak", icon: "ax-readspeak", file: "ReadSpeak" },
            { id: "audiodesc", title: "Audio Descriptions", icon: "ax-audiodesc", about: "Hear descriptions of the visual content of videos, when they are available." }
        ] },
        { title: "Physical and Motor", rows: [
            { id: "voicecontrol", title: "Voice Control", icon: "ax-voicecontrol", about: "Control your computer and apps with spoken commands." },
            { id: "keyboard", title: "Keyboard", icon: "keyboard", file: "KeyboardA11y" },
            { id: "pointer", title: "Pointer Control", icon: "ax-pointer", file: "PointerControl" },
            { id: "switchcontrol", title: "Switch Control", icon: "ax-switchcontrol", about: "Control your computer with adaptive switches." }
        ] },
        { title: "Hearing", rows: [
            { id: "hearingdevices", title: "Hearing Devices", icon: "ax-hearingdevices", about: "Pair and adjust Made for iPhone hearing devices." },
            { id: "audio", title: "Audio", icon: "ax-audio", file: "Audio" },
            { id: "captions", title: "Captions", icon: "ax-captions", file: "Captions" },
            { id: "livecaptions", title: "Live Captions", icon: "ax-livecaptions", about: "Get real-time captions of spoken audio, transcribed on this computer." },
            { id: "namerecognition", title: "Name Recognition", icon: "ax-namerecognition", about: "Get a notification when your name is called." }
        ] },
        { title: "Speech", rows: [
            { id: "livespeech", title: "Live Speech", icon: "ax-livespeech", file: "LiveSpeech" },
            { id: "personalvoice", title: "Personal Voice", icon: "ax-personalvoice", about: "Create a synthesized voice that sounds like you." },
            { id: "vocalshortcuts", title: "Vocal Shortcuts", icon: "ax-vocalshortcuts", about: "Perform an action when you say a chosen word or sound." },
            { id: "siri", title: "Siri", icon: "siri", about: "Let Siri listen for atypical speech." }
        ] },
        { title: "General", rows: [
            { id: "shortcut", title: "Shortcut", icon: "ax-shortcut", about: "Choose the features in the Accessibility Shortcuts panel." }
        ] }
    ]
    readonly property var _rows: sections.reduce((all, s) => all.concat(s.rows), [])

    // ---------- overview ----------
    // 27.2.1 (accessibility-light.png): compact hero; Vision (with Audio Descriptions), then Physical and Motor, rows 42
    HeroCard {
        visible: pane.page === ""
        compact: true
        iconId: "accessibility"
        title: "Accessibility"
        text: "Personalize your computer in ways that work best for you with accessibility features for vision, hearing, motor, speech and cognition."
        link: "Learn more…"
        // no Apple help book here: what each feature does on Linux (settings/FALLBACKS.md)
        onLinkActivated: Qt.openUrlExternally("file://" + Backend.root + "/settings/FALLBACKS.md")
    }
    Repeater {
        model: pane.page === "" ? pane.sections : []
        Card {
            id: section
            required property var modelData
            title: modelData.title
            Repeater {
                model: section.modelData.rows
                FormRow {
                    required property var modelData
                    required property int index
                    implicitHeight: index > 0 ? 43 : 42   // 42 + the separator
                    iconSize: 20
                    iconId: modelData.icon
                    label: modelData.title
                    onClicked: pane.page = modelData.id
                    // chevron.forward semibold 10.5 pt: fitted on accessibility-{light,dark}.png (alpha rms .026 /
                    // .031; regular and medium, 10 to 13 pt: .041 and up). Ink 5.5 x 9.4 pt, centre 13.4 pt from the
                    // card's edge on the Mac (x 706.6 of 740); 183 on 247 light, 92 on 37 dark = tertiaryLabel
                    Item {   // the ink's right edge 10.5 pt inside the card (px 1419 of 1480), on whole pixels
                        anchors.verticalCenter: parent.verticalCenter
                        width: 6; height: 10
                        SfSymbol { name: "chevron.forward"; weight: "semibold"; pointSize: 10.5; color: Theme.tertiaryLabel }
                    }
                }
            }
        }
    }

    // ---------- sub-page ----------
    Item { // back link and page title (the window toolbar keeps "Accessibility")
        visible: pane.current !== null
        width: parent.width; height: 28
        Row {
            id: back
            anchors.verticalCenter: parent.verticalCenter
            Item { // the back link is hyprk's (the Mac navigates with the toolbar's back button): size not from a Mac shot
                anchors.verticalCenter: parent.verticalCenter
                width: 22; height: 22
                SfSymbol { anchors.centerIn: parent; name: "chevron.backward"; weight: "semibold"; pointSize: 13; color: Theme.accent }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Accessibility"
                font: Typography.body
                color: Theme.accent
            }
        }
        MouseArea { anchors.fill: back; cursorShape: Qt.PointingHandCursor; onClicked: pane.page = "" }
        MacText {
            anchors.centerIn: parent
            text: pane.current ? pane.current.title : ""
            font: Typography.headline
            color: Theme.label
        }
    }
    Loader {
        id: sub
        width: parent.width
        function load() {
            const r = pane.current;
            if (r) setSource("accessibility/" + (r.file || "Unsupported") + ".qml", { ctl: ctl, info: r });
            else source = "";
        }
        Connections { target: pane; function onPageChanged() { sub.load(); } }
    }
}
