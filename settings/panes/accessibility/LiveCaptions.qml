import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Live Captions (ax-acc-live-captions-00). No backend: the controls keep their own state.
AxPage {
    Card {
        AxRow { h: 81; ctlY: 19; iconId: "ax-livecaptions"; label: "Live Captions"; subWidth: 345.5
                sub: "Your Mac will use on-device intelligence to automatically display captions across all apps. Accuracy of Live Captions may vary and should not be relied upon in high-risk or emergency situations."
                LocalSwitch { controlSize: "small" } }
        AxRow { h: 38.25; ctlY: 18.5; label: "Font family"; LocalPopup { model: ["Default"] } }
        AxRow { h: 38.5; ctlY: 18.75; label: "Font size"; AxStepper { value: 32; from: 1; unit: "pt" } }
        AxRow { h: 38.25; ctlY: 18.25; label: "Font color"; LocalPopup { model: ["Default"] } }
        AxRow { h: 37.5; ctlY: 18.5; label: "Background color"; LocalPopup { model: ["Default"] } }
    }
    Card {
        AxRow { h: 37; labelY: 9.75; ctlY: 18; label: "Language"; LocalPopup { model: ["English (United States)"] } }
    }
    Card {
        title: "In-App Live Captions"
        AxRow { h: 43; labelY: 13; ctlY: 21.5; textX: 38; label: "Live Captions in FaceTime"
                iconSource: Backend.appIconUrl("", "", Theme.iconLook, "FaceTime"); iconSize: 22; iconX: 9; iconY: 10.5   // acc-live-captions-00-light.png: 22 pt at 9, 10.5
                LocalSwitch {} }
        AxRow { h: 37.5; ctlY: 18.5; label: "Font size"; AxStepper { value: 17; from: 1; unit: "pt" } }
    }
    Text {
        x: 10; width: 449; wrapMode: Text.WordWrap; lineHeight: 14; lineHeightMode: Text.FixedHeight
        text: "Select preferred font size for FaceTime captions. All other caption preferences, including font family, color and background, are located in Live Captions settings for this Mac."
        font: Typography.subheadline; color: Theme.secondaryLabel
    }
    PaneFooter {}
}
