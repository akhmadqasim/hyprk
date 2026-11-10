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

    // id, title, glyph, page file in accessibility/ (none = Unsupported.qml showing `about`)
    readonly property var sections: [
        { title: "Vision", rows: [
            { id: "voiceover", title: "VoiceOver", glyph: "record_voice_over", file: "VoiceOver" },
            { id: "zoom", title: "Zoom", glyph: "zoom_in", file: "Zoom" },
            { id: "hovertext", title: "Hover Text", glyph: "text_fields", about: "Show a larger version of the text under the pointer, or of what you type." },
            { id: "display", title: "Display", glyph: "desktop_windows", file: "Display" },
            { id: "motion", title: "Motion", glyph: "animation", file: "Motion" },
            { id: "readspeak", title: "Read & Speak", glyph: "chat", file: "ReadSpeak" }
        ] },
        { title: "Hearing", rows: [
            { id: "audiodesc", title: "Audio Descriptions", glyph: "speaker_notes", about: "Hear descriptions of the visual content of videos, when they are available." },
            { id: "hearingdevices", title: "Hearing Devices", glyph: "hearing", about: "Pair and adjust Made for iPhone hearing devices." },
            { id: "audio", title: "Audio", glyph: "volume_up", file: "Audio" },
            { id: "captions", title: "Captions", glyph: "closed_caption", file: "Captions" },
            { id: "livecaptions", title: "Live Captions", glyph: "subtitles", about: "Get real-time captions of spoken audio, transcribed on this computer." },
            { id: "namerecognition", title: "Name Recognition", glyph: "person_search", about: "Get a notification when your name is called." }
        ] },
        { title: "Motor", rows: [
            { id: "voicecontrol", title: "Voice Control", glyph: "settings_voice", about: "Control your computer and apps with spoken commands." },
            { id: "keyboard", title: "Keyboard", glyph: "keyboard", file: "KeyboardA11y" },
            { id: "pointer", title: "Pointer Control", glyph: "mouse", file: "PointerControl" },
            { id: "switchcontrol", title: "Switch Control", glyph: "toggle_on", about: "Control your computer with adaptive switches." }
        ] },
        { title: "Speech", rows: [
            { id: "livespeech", title: "Live Speech", glyph: "keyboard_voice", file: "LiveSpeech" },
            { id: "personalvoice", title: "Personal Voice", glyph: "person", about: "Create a synthesized voice that sounds like you." },
            { id: "vocalshortcuts", title: "Vocal Shortcuts", glyph: "mic", about: "Perform an action when you say a chosen word or sound." },
            { id: "siri", title: "Siri", glyph: "graphic_eq", about: "Let Siri listen for atypical speech." }
        ] },
        { title: "General", rows: [
            { id: "shortcut", title: "Shortcut", glyph: "accessibility_new", about: "Choose the features in the Accessibility Shortcuts panel." }
        ] }
    ]
    readonly property var _rows: sections.reduce((all, s) => all.concat(s.rows), [])

    // ---------- overview ----------
    HeroCard {
        visible: pane.page === ""
        iconId: "accessibility"; glyph: "accessibility_new"; tint: Theme.tile.blue
        title: "Accessibility"
        text: "Personalize your computer in ways that work for you, with features for vision, hearing, motor, speech and more."
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
                    glyph: modelData.glyph; tint: Theme.tile.blue
                    label: modelData.title
                    onClicked: pane.page = modelData.id
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "chevron_right"; font.family: Theme.fontGlyph; font.pixelSize: 18
                        color: Theme.tertiaryLabel
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
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "chevron_left"; font.family: Theme.fontGlyph; font.pixelSize: 22
                color: Theme.accent
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Accessibility"
                font.family: Theme.fontText; font.pixelSize: Theme.font.body
                color: Theme.accent
            }
        }
        MouseArea { anchors.fill: back; cursorShape: Qt.PointingHandCursor; onClicked: pane.page = "" }
        MacText {
            anchors.centerIn: parent
            text: pane.current ? pane.current.title : ""
            font.family: Theme.fontDisplay; font.pixelSize: Theme.font.body; weight: Font.Bold
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
