import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Shortcut (ax-acc-shortcut-00..01): the features the shortcut toggles, all ticked, 24.5 pt rows.
// No backend: the boxes and the switch keep their own state.
AxPage {
    Card {
        Item {
            width: parent.width; height: 49
            Text { x: 10; y: 10; width: 445; wrapMode: Text.WordWrap; lineHeight: 14; lineHeightMode: Text.FixedHeight
                   text: "Accessibility features can be switched on and off by quickly pressing Touch ID three times, or pressing ⌥⌘F5. Select which features to toggle on and off:"
                   font: Typography.subheadline; color: Theme.secondaryLabel }
        }
        Repeater {
            model: ["VoiceOver", "Zoom", "Hover Text", "Hover Typing", "Invert Display Color", "Color Filters", "Accessibility Reader",
                    "Sticky Keys", "Slow Keys", "Mouse Keys", "Full Keyboard Access", "Accessibility Keyboard", "Increase Contrast",
                    "Reduce Transparency", "Show Borders", "Head Pointer", "Voice Control", "Live Captions", "Live Speech",
                    "Vehicle Motion Cues", "Background Sounds"]
            AxListRow {
                required property string modelData
                h: 24.5; sepX: 32   // the lines start at the labels (acc-shortcut-00-light.png)
                AxCheck { x: 10; anchors.verticalCenter: parent.verticalCenter; text: modelData; checked: true }
            }
        }
    }
    Card {
        AxRow { h: 52; labelY: 9.9; label: "Speech"; sub: "Speak items in the accessibility shortcut menu when navigated."
                LocalSwitch { checked: true } }
    }
    PaneFooter {}
}
