import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Read & Speak (ax-acc-read-speak-00). Works: Speak selection (⌥Esc speaks the selected text through
// speech-dispatcher, scripts/a11y-speak.sh); Speak announcements is saved; the rest keeps its own state.
// System voice's ⓘ opens the voice sheet (MAC-ANSWERS-14.md R14.4, live/settings-r14/acc-read-speak--voice-info-dark.png):
// 750 x 450, 10 pt wider than the window (the Mac's sheet is a window of its own; here it is drawn in the window and
// loses 5 pt at each side). Left, 200 pt: the languages in 32 pt rows, each with its voice at the row's end; the first
// three rows are under the capture's blur, so the list starts at its fourth row's place. Right: the language's name,
// a card with Voice (a row into the voice list, "Voice 4"), Rate, Pitch and Speech Volume (sliders with 21, 21 and 20
// ticks), a card with Reset Voice Settings (red) and its line; under a hairline the play button and Done (not the
// default button). No voice backend: the sliders keep their own values, Reset puts the Mac's back, the rows, Voice
// and play take the press only. The other six ⓘ of this pane were not opened on the Mac.
AxPage {
    id: page
    readonly property var a: ctl.a
    Card {
        AxRow { h: 80; info: true; label: "Accessibility Reader"; subWidth: 364.5
                sub: "Read or listen to text in the Accessibility Reader app and customize fonts, layout and background colors. Press ⌘Esc to turn on and use Accessibility Reader."
                LocalSwitch {} }
    }
    Card {
        AxRow { h: 66; info: true; label: "Speak selection"; subWidth: 357.5
                sub: "Hear selected text spoken aloud. Select Speech > Start Speaking in the Quick Actions menu, or use a keyboard shortcut."
                Switch { checked: page.a.speakSelection; onToggled: on => page.ctl.set({ speakSelection: on }) } }
    }
    Card {
        AxRow { h: 52; info: true; label: "Speak item under the pointer"
                sub: "Mac will speak the words under the cursor."; LocalSwitch {} }
    }
    Card {
        AxRow { h: 66; info: true; label: "Speak announcements"; subWidth: 363
                sub: "Mac will speak the text in dialogs and notify you when you need to perform an action in an app."
                Switch { checked: page.a.speakAnnouncements; onToggled: on => page.ctl.set({ speakAnnouncements: on }) } }
    }
    Card {
        AxRow { h: 52; info: true; label: "Speak typing feedback"
                sub: "Mac will speak the keys you press and the characters you type."; LocalSwitch {} }
    }
    Card {
        AxRow { h: 38.25; ctlY: 18.5; label: "System speech language"; LocalPopup { model: ["Use System Language"] } }
        AxRow { h: 41.25; ctlY: 18.25; info: true; label: "System voice"; objectName: "systemVoiceRow"
                LocalPopup { model: ["Daniel"] }
                onInfoClicked: voice.open() }
        AxRow { h: 36.5; label: "Detect languages"; LocalSwitch { checked: true } }
    }
    Card {
        AxRow { h: 38; info: true; label: "Pronunciations"; LocalSwitch {} }
    }
    PaneFooter {}
    SubSheet {
        id: voice
        objectName: "voiceInfo"
        sheetWidth: 750; sheetHeight: 450
        footer: false
        readonly property var languages: [["Bangla", "Aman"], ["Basque", "-"], ["Bhojpuri", "-"], ["Bodo", "Aman"], ["Bulgarian", "Daria"],
            ["Catalan", "Montse"], ["Chinese", "Tingting"], ["Croatian", "Lana"], ["Czech", "Zuzana"], ["Danish", "Sara"], ["Dogri", "Aman"]]
        function reset() { rate.value = 0.5; pitch.value = 0.5; volume.value = 0.47; }
        onClosed: reset()
        component Glyph: Image {
            property string name
            width: sourceSize.width / 2; height: sourceSize.height / 2
            source: "../../assets/r14/" + name + (Theme.dark ? "-dark.png" : "-light.png")
        }
        Rectangle {
            width: 200; height: 450
            color: Theme.dark ? Qt.rgba(1, 1, 1, 0.03) : Qt.rgba(0, 0, 0, 0.03)
            topLeftRadius: Tokens.panel.sheetRadius; bottomLeftRadius: Tokens.panel.sheetRadius
            clip: true
            Repeater {
                model: voice.languages
                Item {
                    required property var modelData
                    required property int index
                    objectName: "voiceLanguage" + index
                    y: 105.5 + 32 * index; width: 200; height: 32
                    MacText { x: 16.5; anchors.verticalCenter: parent.verticalCenter; text: modelData[0] }
                    MacText { anchors.right: parent.right; anchors.rightMargin: 16.5; anchors.verticalCenter: parent.verticalCenter; text: modelData[1]; color: Theme.secondaryLabel }
                }
            }
            Rectangle { anchors.right: parent.right; width: Pixel.stroke(0.5, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); height: parent.height; color: Theme.separator }
        }
        Text { x: 248.5; y: 15.5; text: "English"; font: Typography.headline; color: Theme.label }
        Rectangle { x: 200; y: 46; width: 550; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
        Card {
            x: 220; y: 66.5; width: 510
            AxRow { h: 38; label: "Voice"; spacing: 12
                    Text { text: "Voice 4"; font: Typography.body; color: Theme.secondaryLabel }
                    Item { width: 6; height: 10; SfSymbol { name: "chevron.forward"; weight: "semibold"; pointSize: 10.5; color: Theme.tertiaryLabel } } }
            AxRow { h: 39; label: "Rate"
                    AxSlider { id: rate; objectName: "voiceRate"; width: 211; tickMarks: 21; value: 0.5; leftGlyph: "tortoise.fill"; rightGlyph: "hare.fill" } }
            AxRow { h: 39; label: "Pitch"
                    AxSlider { id: pitch; objectName: "voicePitch"; width: 211; tickMarks: 21; value: 0.5
                               leftIcon: Component { Glyph { name: "pitch-low" } }
                               rightIcon: Component { Glyph { name: "pitch-high" } } } }
            AxRow { h: 38; label: "Speech Volume"
                    AxSlider { id: volume; objectName: "voiceVolume"; width: 211; tickMarks: 20; value: 0.47; leftGlyph: "speaker.fill"; rightGlyph: "speaker.wave.3.fill"; rightGlyphSize: 12.7 } }
        }
        Card {
            x: 220; y: 239.5; width: 510
            Item {
                width: parent.width; height: 62
                Rectangle {
                    objectName: "voiceReset"
                    x: 10; y: 10.5; width: resetText.implicitWidth + 24; height: 24; radius: 6
                    color: Tokens.control.pushFill
                    Rectangle { anchors.fill: parent; radius: parent.radius; visible: resetMa.pressed; color: Tokens.control.pressOverlay }
                    Text { id: resetText; anchors.centerIn: parent; text: "Reset Voice Settings"; font: Typography.body; color: Theme.tile.red }
                    MouseArea { id: resetMa; anchors.fill: parent; onClicked: voice.reset() }
                }
                Text { x: 10; y: 38.5; text: "Reverts all voice changes to defaults."; font: Typography.subheadline; color: Theme.secondaryLabel }
            }
        }
        Rectangle { x: 200; y: 385; width: 550; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
        Rectangle {
            objectName: "voicePlay"
            x: 220; y: 406; width: 36; height: 24; radius: 6
            color: Tokens.control.pushFill
            Rectangle { anchors.fill: parent; radius: parent.radius; visible: playMa.pressed; color: Tokens.control.pressOverlay }
            SfSymbol { anchors.centerIn: parent; name: "play.fill"; pointSize: 11; color: Theme.label }
            MouseArea { id: playMa; anchors.fill: parent }
        }
        Button { objectName: "voiceDone"; x: 666; y: 406; width: 64; text: "Done"; onClicked: voice.close() }
        Shortcut { sequences: ["Return", "Enter"]; enabled: voice.shown; onActivated: voice.close() }
    }
}
