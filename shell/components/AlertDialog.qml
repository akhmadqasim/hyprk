import QtQuick
import Quickshell.Widgets
import qs
import qs.HyprK
import qs.services

// macOS-style alert: glass card (Theme.alert.radius), app icon, bold title, message,
// capsule buttons. Model: { icon, title, message, buttons: [{ label, action, isDefault, isCancel }] }.
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

    width: Theme.alert.width
    height: col.implicitHeight + Theme.alert.padding * 2

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

    Glass {
        anchors.fill: parent
        radius: Theme.alert.radius
        sx: root.originX
        sy: root.originY
        tint: Theme.glass.tintStrong
        materialize: root.fade
    }
    MouseArea { anchors.fill: parent }

    Column {
        id: col
        opacity: root.fade
        enabled: root.shown
        x: Theme.alert.padding
        y: Theme.alert.padding
        width: parent.width - Theme.alert.padding * 2
        spacing: Theme.alert.spacing

        IconImage {
            anchors.horizontalCenter: parent.horizontalCenter
            implicitSize: Theme.alert.iconSize
            source: Apps.iconUrl(root.model ? root.model.icon : "", "", Theme.iconLook)
            mipmap: true
        }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: root.model ? root.model.title : ""
            // Bold 13 (LIVE-27.2.1.md alert metrics) = the headline style, real Bold on the wght axis (Typography)
            font: Typography.headline
            color: Theme.color.label
        }
        Text {
            width: parent.width
            visible: text !== ""
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: root.model && root.model.message ? root.model.message : ""
            font: Typography.message   // messageFont 13 (measured)
            color: Theme.color.label
        }
        Row {
            width: parent.width
            spacing: Theme.alert.buttonGap
            Repeater {
                model: root.buttons
                delegate: Rectangle {
                    id: btn
                    required property var modelData
                    width: (col.width - Theme.alert.buttonGap * (root.buttons.length - 1)) / root.buttons.length
                    height: Theme.alert.buttonHeight
                    radius: height / 2
                    color: modelData.isDefault ? Theme.color.accent : Theme.alert.buttonBg
                    opacity: bma.pressed ? Theme.alert.pressedOpacity : 1
                    Text {
                        anchors.centerIn: parent
                        text: btn.modelData.label
                        font: Typography.font(13, Typography.medium)   // 13 measured, Medium by eye
                        color: btn.modelData.isDefault ? Theme.color.textOnAccent : Theme.color.label
                    }
                    MouseArea { id: bma; anchors.fill: parent; onClicked: root.press(btn.modelData) }
                }
            }
        }
    }
}
