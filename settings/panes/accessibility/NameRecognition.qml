import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Name Recognition (ax-acc-name-recognition-00).
AxPage {
    Card {
        AxRow { h: 52; ctlY: 22; iconId: "ax-namerecognition"; label: "Name Recognition"
                sub: "Teach your Mac to recognize your name."; Button { text: "Set Up" } }
    }
    PaneFooter {}
}
