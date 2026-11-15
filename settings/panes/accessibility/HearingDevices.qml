import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Hearing Devices (ax-acc-hearing-devices-00): the placard, then an empty 36 pt group.
AxPage {
    Card {
        AxRow { h: 80; ctlY: 22; iconId: "ax-hearingdevices"; label: "MFi Hearing Devices"; subWidth: 335
                sub: "Pair MFi hearing aids and sound processors. Other hearing aids are paired in Bluetooth settings. Bring devices within range of this Mac to complete pairing."
                Button { text: "Set Up" } }
    }
    Item { width: 1; height: 36 }
    PaneFooter {}
}
