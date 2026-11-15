import QtQuick
import ".."
import "../controls"
import "../HyprK"

// 27.2.1 (MAC-ANSWERS-12.md R12.3; live/settings-r12/nav-trackpad--tab-{point-click,scroll-zoom,more-gestures}-dark.png
// and their AX dumps): right under the toolbar a card 225 x 142 with the trackpad's outline (96 x 73) and the gesture's
// preview 224.5 x 141 beside it, then the tab bar (Point & Click / Scroll & Zoom / More Gestures: 149 / 157.5 / 161.5 pt,
// AX y 210) and the tab's card, swapped in place. The Mac's values throughout: no pointer backend is wired here
// (settings/FALLBACKS.md "Trackpad"). The preview is the Mac's clip, here its frame on the still (assets/trackpad);
// the fingers the Mac animates on the outline are not drawn. Pop-ups whose other items are not on a shot show the
// Mac's value only. The secondary click's first item reads "Click with Two Fingers" with Tap to click off.
Column {
    id: pane
    spacing: Theme.content.sectionGap
    property int tab: 0
    Item {
        width: parent.width; height: 178
        Rectangle {
            x: 4; y: -Theme.content.top; width: 225; height: 142
            radius: Theme.content.cardRadius; color: Theme.cardFill; border.color: Theme.cardStroke
            Rectangle { x: 64.5; y: 35.5; width: 96; height: 73; radius: 9; color: "transparent"; border.width: 1.5; border.color: Theme.dark ? "white" : "#B9B9B9" }   // light: R13.5 nav-trackpad--tab-point-click-light.png (#B9B9B9)
        }
        Image {
            x: 239.5; y: 0.5 - Theme.content.top; width: 224.5; height: 141
            // the light frames: the same crop of the R13.5 light stills (nav-trackpad--tab-*-light.png)
            source: "../assets/trackpad/" + ["point-click", "scroll-zoom", "more-gestures"][pane.tab] + (Theme.dark ? "" : "-light") + ".png"
        }
        SegmentedControl {
            id: tabs
            objectName: "trackpadTabs"
            y: 146; width: parent.width
            model: ["Point & Click", "Scroll & Zoom", "More Gestures"]
            currentIndex: pane.tab
            onActivated: i => pane.tab = i
        }
    }
    component R: FormRow { sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14 }
    Card {
        visible: pane.tab === 0
        FormRow { implicitHeight: 51; alignTop: true; label: "Tracking speed"; Slider { width: 246.5; tickMarks: 10; onlyTicks: true; value: 1 / 3; leftText: "Slow"; rightText: "Fast"; onMoved: v => value = v } }
        FormRow { implicitHeight: 51; alignTop: true; label: "Click"; Slider { width: 246.5; tickMarks: 3; onlyTicks: true; value: 0.5; labels: [["Light", 0], ["Medium", 0.5], ["Firm", 1]]; onMoved: v => value = v } }
        R {
            label: "Force Click and haptic feedback"
            sublabel: "Click then press firmly for Quick Look, Look up, and variable speed media controls."
            LocalSwitch { checked: true }
        }
        FormRow { label: "Look up & data detectors"; LocalPopup { objectName: "trackpadLookUp"; model: ["Off", "Force Click with One Finger", "Tap with Three Fingers"]; currentIndex: 1 } }
        FormRow {
            label: "Secondary click"
            LocalPopup { objectName: "trackpadSecondary"; model: ["Off", tapClick.checked ? "Click or Tap with Two Fingers" : "Click with Two Fingers", "Click in Bottom-Right Corner", "Click in Bottom-Left Corner"]; currentIndex: 1 }
        }
        R { label: "Tap to click"; sublabel: "Tap with one finger"; LocalSwitch { id: tapClick } }
    }
    Card {
        visible: pane.tab === 1
        R { label: "Natural scrolling"; sublabel: "Content tracks finger movement"; LocalSwitch { checked: true } }
        R { label: "Zoom in or out"; sublabel: "Pinch with two fingers"; LocalSwitch { checked: true } }
        R { label: "Smart zoom"; sublabel: "Double-tap with two fingers"; LocalSwitch { checked: true } }
        R { label: "Rotate"; sublabel: "Rotate with two fingers"; LocalSwitch { checked: true } }
    }
    Card {
        visible: pane.tab === 2
        FormRow { label: "Swipe between pages"; LocalPopup { model: ["Scroll Left or Right with Two Fingers"] } }
        FormRow { label: "Swipe between spaces"; LocalPopup { model: ["Swipe Left or Right with Three Fingers"] } }
        FormRow { label: "Mission Control"; LocalPopup { model: ["Swipe Up with Three Fingers"] } }
        FormRow { label: "App Exposé"; LocalPopup { model: ["Swipe Down with Three Fingers"] } }
        R { label: "Notification Center"; sublabel: "Swipe left from the right edge with two fingers"; LocalSwitch { checked: true } }
        R { label: "Apps"; sublabel: "Pinch with thumb and three fingers"; LocalSwitch { checked: true } }
        R { label: "Show Desktop"; sublabel: "Spread with thumb and three fingers"; LocalSwitch { checked: true } }
    }
    PaneFooter { Button { text: "Set Up Bluetooth Trackpad…" } }
}
