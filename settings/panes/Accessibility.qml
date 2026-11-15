import QtQuick
import ".."
import "../controls"
import "../HyprK"

// macOS 27.2.1 Accessibility (reference/re/MAC-ANSWERS-12.md R12.1, re/27.2.1/live/settings-r12): the placard, then
// Vision / Physical and Motor / Hearing / Speech / General; each row pushes its sub-pane from panes/accessibility/
// (the window's toolbar shows its name and Go Back returns, SettingsApp.qml). What is wired to hyprk and what keeps
// the Mac's default: settings/FALLBACKS.md "Accessibility". State: state/accessibility.json + appearance.json (A11yCtl.qml).
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string page: ""          // "" = overview, else a row id below
    readonly property var current: _rows.find(r => r.id === page) || null
    readonly property string pageTitle: current ? current.title : ""   // the toolbar title while a sub-page is open

    // Created by URL: Quickshell only registers QML types of directories reached by
    // static imports, and the panes are loaded by Loader (same for the sub-pages).
    readonly property QtObject ctl: Qt.createComponent("accessibility/A11yCtl.qml").createObject(pane)
    // HYPRK_A11Y_PAGE=<row id> opens a sub-page (snapshots, deep links)
    Component.onCompleted: Backend.run(["printenv", "HYPRK_A11Y_PAGE"], (c, out) => {
        if (c === 0 && _rows.some(r => r.id === out.trim())) page = out.trim();
    })

    // id, title, row icon, page file in accessibility/, in the Mac's order (ax-accessibility-00-light.jsonl AX_FEATURE_*).
    // Icons: the row tiles of AccessibilityUIServer's / the extension's graphic icon UTIs (themes/icons/settings/
    // graphic.json). Keyboard and Siri: the pane's icon; RTT: its tile is not extracted yet, a plain green tile.
    readonly property var sections: [
        { title: "Vision", rows: [
            { id: "voiceover", title: "VoiceOver", icon: "ax-voiceover", file: "VoiceOver" },
            { id: "zoom", title: "Zoom", icon: "ax-zoom", file: "Zoom" },
            { id: "hovertext", title: "Hover Text", icon: "ax-hovertext", file: "HoverText" },
            { id: "display", title: "Display", icon: "display", file: "Display" },
            { id: "motion", title: "Motion", icon: "ax-motion", file: "Motion" },
            { id: "readspeak", title: "Read & Speak", icon: "ax-readspeak", file: "ReadSpeak" },
            { id: "audiodesc", title: "Audio Descriptions", icon: "ax-audiodesc", file: "AudioDescriptions" }
        ] },
        { title: "Physical and Motor", rows: [
            { id: "voicecontrol", title: "Voice Control", icon: "ax-voicecontrol", file: "VoiceControl" },
            { id: "keyboard", title: "Keyboard", icon: "keyboard", file: "KeyboardA11y" },
            { id: "pointer", title: "Pointer Control", icon: "ax-pointer", file: "PointerControl" },
            { id: "switchcontrol", title: "Switch Control", icon: "ax-switchcontrol", file: "SwitchControl" }
        ] },
        { title: "Hearing", rows: [
            { id: "hearingdevices", title: "Hearing Devices", icon: "ax-hearingdevices", file: "HearingDevices" },
            { id: "audio", title: "Audio", icon: "ax-audio", file: "Audio" },
            { id: "rtt", title: "RTT", tile: "green", icon: "ax-rtt", file: "RTT" },
            { id: "captions", title: "Subtitles and Captioning", icon: "ax-captions", file: "Captions" },
            { id: "livecaptions", title: "Live Captions", icon: "ax-livecaptions", file: "LiveCaptions" },
            { id: "namerecognition", title: "Name Recognition", icon: "ax-namerecognition", file: "NameRecognition" }
        ] },
        { title: "Speech", rows: [
            { id: "livespeech", title: "Live Speech", icon: "ax-livespeech", file: "LiveSpeech" },
            { id: "personalvoice", title: "Personal Voice", icon: "ax-personalvoice", file: "PersonalVoice" },
            { id: "vocalshortcuts", title: "Vocal Shortcuts", icon: "ax-vocalshortcuts", file: "VocalShortcuts" }
        ] },
        { title: "General", rows: [
            { id: "siri", title: "Siri", icon: "siri", file: "Siri" },
            { id: "shortcut", title: "Shortcut", icon: "ax-shortcut", file: "Shortcut" }
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
        text: "Personalize Mac in ways that work best for you with accessibility features for vision, hearing, motor, speech, and cognition."   // accessibilityPlacardInfo
        link: "Learn more…"
        helpAnchor: "mh35884"   // ax-accessibility-light.jsonl
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
                    id: nav
                    required property var modelData
                    required property int index
                    readonly property bool last: index === section.modelData.rows.length - 1
                    implicitHeight: index > 0 ? 43 : 42   // 42 + the separator
                    iconSize: 20
                    iconId: modelData.icon
                    tint: Theme.tile[modelData.tile || "blue"]
                    label: modelData.title
                    // the press lights the whole row until the mouse is released, then the sub-pane replaces the pane in
                    // one frame (R12.2, push-accessibility-voiceover-dark.mov 1.117 to 1.233 s: the card's 31 -> 43 of
                    // 255, white at 5 %; light is not on a clip with the mouse: black at 5 %)
                    Item {
                        parent: nav; anchors.fill: parent
                        Rectangle {
                            anchors.fill: parent
                            visible: press.pressed
                            color: Theme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.05)
                            topLeftRadius: nav.index === 0 ? Theme.content.cardRadius : 0; topRightRadius: topLeftRadius
                            bottomLeftRadius: nav.last ? Theme.content.cardRadius : 0; bottomRightRadius: bottomLeftRadius
                        }
                        MouseArea { id: press; anchors.fill: parent; onClicked: pane.page = nav.modelData.id }
                    }
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
    // pushed on the window's navigation: the toolbar shows its title and Go Back returns (SettingsApp.qml); no header here
    Loader {
        id: sub
        width: parent.width
        function load() {
            const r = pane.current;
            if (r) setSource("accessibility/" + r.file + ".qml", { ctl: ctl, info: r });
            else source = "";
        }
        Connections { target: pane; function onPageChanged() { sub.load(); } }
    }
    // the overview ends with the "?" button, 20 below the General card (ax-accessibility-light.jsonl: Help 24 x 24 at
    // y 1318.5, x 464; the card ends 1298.5)
    PaneFooter { visible: pane.page === "" }
}
