import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Audio Descriptions (ax-acc-audio-descriptions-00). No backend: the switch keeps its own state.
AxPage {
    Card {
        AxRow { h: 52; label: "Play audio descriptions when available"
                sub: "Audio descriptions provide a spoken description of visual content in media."; LocalSwitch {} }
    }
    PaneFooter {}
}
