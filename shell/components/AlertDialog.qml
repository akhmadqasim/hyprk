import QtQuick
import Quickshell.Widgets
import qs
import qs.HyprK
import qs.services
import "../HyprK/panels.js" as P

// macOS-style alert: regular glass (Theme.alert.radius), icon, bold title and message left-aligned,
// capsule buttons (layout below). Model: { icon, title, message, buttons: [{ label, action, isDefault, isCancel }] }.
// Enter runs the default button, Escape the cancel button.
// Motion as measured on macOS 27.2.1 (reference/re/LIVE-27.2.1.md, live/video-motion-2.json): the alert
// grows from its centre from about 4 %, easing in to an overshoot at 0.2 s, and settles by 0.37 s;
// dismissing is a 0.1 s fade without scale. Reduce motion: dissolve in and out, no scale.
Item {
    id: root

    property bool shown: false
    property real fade: 0   // glass materialize and content opacity
    property real pop: 1    // scale around the centre
    visible: shown || fade > 0
    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.pop
        yScale: root.pop
    }
    // the glass region does not follow transforms: re-measure it while the alert scales
    onPopChanged: Tokens.glassStepped(root)
    // one value per frame of the window (HyprK FrameAnim); the settle starts in the frame after the rise's last
    FrameAnim {
        id: popIn
        target: root; property: "pop"; from: Theme.alert.popFrom; to: Theme.alert.popPeak; duration: Theme.alert.popRise; ease: Easing.InQuad
        onFinished: popSettle.start()
        function halt(): void { stop(); popSettle.stop(); }
    }
    FrameAnim { id: popSettle; target: root; property: "pop"; to: 1; duration: Theme.alert.popSettle; ease: Easing.OutQuad }
    FrameAnim { id: fadeIn; target: root; property: "fade"; to: 1; duration: 150 }   // Reduce motion dissolve
    FrameAnim { id: fadeOut; target: root; property: "fade"; to: 0; duration: Theme.alert.fadeOut; ease: Easing.OutQuad }
    Component.onCompleted: if (shown) fade = 1

    property var model: null
    property real originX: 0
    property real originY: 0
    readonly property var buttons: model && model.buttons ? model.buttons : [{ label: "OK", isDefault: true }]
    // the layout's order: the default first (P.alertLayout: 2 side by side with it on the right, 3 stacked default,
    // third, second), the others as given
    readonly property var ordered: {
        const d = buttons.findIndex(b => b.isDefault);
        return d < 0 ? buttons : [buttons[d]].concat(buttons.filter((b, i) => i !== d));
    }
    readonly property bool hasIcon: !!(model && model.icon)
    // NSAlert on macOS 27.2.1, the Empty Trash alert itself (re/27.2.1/live/panels/panels-alert2-dark.json frames,
    // screens/27.2.1/panels/alert-{dark,light}.png; MAC-ANSWERS Q-panels-33): 260 wide, 64 pt icon at (20, 20),
    // bold 13 title and regular 13 message left-aligned in 220 pt, 110 x 28 capsules 16 pt from the edges. The same
    // layout as the apps' AlertPanel (HyprK panels.js). Before: everything centred, buttons sharing the width
    readonly property var layout: P.alertLayout(ordered.length, hasIcon, titleText.implicitHeight,
                                                messageText.text !== "" ? messageText.implicitHeight : 0)
    width: layout.width
    height: layout.height

    function press(b) {
        Panels.close();
        if (b && typeof b.action === "function") b.action();
    }
    function pressDefault() { press(buttons.find(b => b.isDefault) || buttons[buttons.length - 1]); }
    function pressCancel() { press(buttons.find(b => b.isCancel) || null); }

    // keyboard: Return/Enter = default button, Escape = cancel
    focus: shown
    onShownChanged: {
        if (shown) {
            fadeOut.stop();
            if (A11y.reduceMotion) {
                pop = 1;
                fadeIn.restart();
            } else {
                fade = 1;
                pop = Theme.alert.popFrom;   // before the first tick, so no full-size frame
                popSettle.stop();
                popIn.restart();
            }
            Qt.callLater(forceActiveFocus);   // after `visible` follows
        } else {
            fadeIn.stop();
            popIn.halt();   // dismissed mid-pop: fades at the size it has, no jump
            fadeOut.start();
        }
    }
    Keys.onEscapePressed: pressCancel()
    Keys.onReturnPressed: pressDefault()
    Keys.onEnterPressed: pressDefault()

    // regular glass, r 26 (LIVE-27.2.1: Alert = regular; the plugin's hyprk-overlay recipe is regular + the menu
    // shadow). No tint of our own: tintStrong only reached the QML fallback
    Glass {
        anchors.fill: parent
        radius: Theme.alert.radius
        sx: root.originX
        sy: root.originY
        tint: Theme.glass.tintStrong
        materialize: root.fade
    }
    MouseArea { anchors.fill: parent }

    Item {
        anchors.fill: parent
        opacity: root.fade
        enabled: root.shown

        IconImage {
            visible: !!root.layout.icon
            x: visible ? root.layout.icon.x : 0
            y: visible ? root.layout.icon.y : 0
            implicitSize: P.alert.icon
            source: root.hasIcon ? Apps.iconUrl(root.model.icon, "", Theme.iconLook) : ""
            mipmap: true
        }
        Text {
            id: titleText
            x: root.layout.title.x
            y: root.layout.title.y
            width: P.alert.textWidth
            wrapMode: Text.Wrap
            text: root.model ? root.model.title : ""
            // Bold 13 (".SFNS-Bold 13.0" in the dump) = the headline style, real Bold on the wght axis (Typography)
            font: Typography.headline
            color: Theme.color.label
        }
        Text {
            id: messageText
            visible: text !== ""
            x: P.alert.padding
            y: root.layout.message ? root.layout.message.y : 0
            width: P.alert.textWidth
            wrapMode: Text.Wrap
            text: root.model && root.model.message ? root.model.message : ""
            font: Typography.message   // ".SFNS-Regular 13.0"
            color: Theme.color.label
        }
        Repeater {
            model: root.ordered
            delegate: Rectangle {
                id: btn
                required property var modelData
                required property int index
                readonly property var r: root.layout.buttons[index] || { x: 0, y: 0, width: 0, height: 0 }
                x: r.x; y: r.y; width: r.width; height: r.height
                radius: height / 2
                color: modelData.isDefault ? Tokens.panel.defaultFill : Theme.alert.buttonBg
                // pressed: one more layer, instant (Q-panels-33: 71 -> 89 in dark; Q-settings-15: black a .098)
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    visible: bma.pressed && bma.containsMouse
                    color: Theme.alert.buttonPressed
                }
                Text {
                    anchors.centerIn: parent
                    width: parent.width - 16
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: btn.modelData.label
                    font: Typography.body   // 13 regular, the default too (Q-panels-33)
                    color: btn.modelData.isDefault ? Theme.color.textOnAccent : Theme.color.label
                }
                MouseArea { id: bma; anchors.fill: parent; onClicked: root.press(btn.modelData) }
            }
        }
    }
}
