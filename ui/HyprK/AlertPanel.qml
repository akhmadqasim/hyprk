import QtQuick
import QtQuick.Effects
import QtQuick.Window
import "panels.js" as P

// NSAlert as on macOS 27.2.1 (MAC-ANSWERS.md Q-panels-33/34; layout in panels.js alertLayout): 260 wide, r 26,
// 64 pt icon top-left, bold 13 title and regular 13 message left-aligned. buttons[0] is the default (accent,
// white text); 2 buttons sit side by side with the default on the right, 3 stack (default, third, second).
// A destructive button has red text on a red-tinted capsule; no hover. `sheet`: the alert-sheet form (no icon,
// no pop; the caller's Sheet dims and fades). Return = default, Escape = the cancel button.
// The caller places it (P.alertTop for app-modal alerts: no dim) and sets `shown`; `activated(index)` follows.
// Motion (Tokens.panel, panels.js; AppKit 27.2.1, re/27.2.1/MOTION-AUDIT.md "Alert, Round R3.1"): PopIn, 0.4 s of
// linear progress v, opacity v, scale 1 % -> 1.2 -> 1; the cancel button (Esc) closes it with a 0.25 s spring to
// opacity 0 and scale 0.98, any other button at once. The sheet form keeps the Sheet's linear fades.
Item {
    id: root
    property bool shown: false
    property bool sheet: false
    property url icon: ""
    property string title
    property string message
    // [{ text, cancel: bool, destructive: bool }]; index 0 = default
    property var buttons: [{ text: "OK" }]
    signal activated(int index)

    readonly property var layout: P.alertLayout(buttons.length, !sheet && icon != "", titleText.implicitHeight,
                                                message !== "" ? messageText.implicitHeight : 0)
    width: layout.width
    height: layout.height
    visible: shown || opacity > 0
    opacity: 0
    focus: shown

    // NSAlert runModal: the Cancel button orders out with ScaleDownAndOut, every other way out with none
    property bool _cancel: false
    function press(i) {
        if (!shown) return;
        _cancel = !!(buttons[i] && buttons[i].cancel);
        activated(i);
        _cancel = false;
    }
    function cancelIndex() {
        const i = buttons.findIndex(b => b.cancel);
        return i >= 0 ? i : buttons.length - 1;
    }
    Keys.onReturnPressed: press(0)
    Keys.onEnterPressed: press(0)
    Keys.onEscapePressed: press(cancelIndex())

    property real pop: 1
    transform: Scale { origin.x: root.width / 2; origin.y: root.height / 2; xScale: root.pop; yScale: root.pop }
    property real appear: 1   // PopIn progress v (linear)
    property real outMs: 0    // ms into the cancel order-out
    property bool _outActive: false
    property real _fade0: 1
    property real _pop0: 1
    // Cancel's blur on the text, icon and buttons, a Gaussian sigma in pt (shell Theme.alert.cancelBlur x p, MOTION-AUDIT.md
    // "Alert, Round R3.1": the Mac's dismiss frame has text sigma 0.80 pt at alpha .835, 5 p = 0.83)
    readonly property real cancelBlur: 5
    property real soften: 0
    NumberAnimation { id: popIn; target: root; property: "appear"; from: 0; to: 1; duration: Tokens.panel.alertPopIn }
    onAppearChanged: {   // only popIn moves it
        pop = P.alertPopScale(appear, Tokens.panel.alertPopAmount);
        opacity = appear;
    }
    NumberAnimation {
        id: cancelOut
        target: root; property: "outMs"; from: 0; to: Tokens.panel.alertCancelOut; duration: Tokens.panel.alertCancelOut
        onFinished: { root._outActive = false; root.opacity = 0; root.soften = 0; }
    }
    onOutMsChanged: {
        if (!_outActive) return;
        const p = outMs >= Tokens.panel.alertCancelOut ? 1
                : P.alertCancelProgress(outMs, Tokens.panel.alertCancelDuration, Tokens.panel.alertCancelVelocity);
        opacity = _fade0 * (1 - p);
        if (!Tokens.reduceMotion) {
            pop = _pop0 * (1 - (1 - Tokens.panel.alertCancelScale) * p);
            soften = root.cancelBlur * p;
        }
    }
    NumberAnimation { id: fadeIn; target: root; property: "opacity"; to: 1; duration: root.sheet ? Tokens.panel.sheetIn : 150 }
    NumberAnimation { id: fadeOut; target: root; property: "opacity"; to: 0; duration: Tokens.panel.sheetOut }   // sheet form
    onShownChanged: {
        if (shown) {
            fadeOut.stop();
            _outActive = false;
            cancelOut.stop();
            soften = 0;
            if (sheet || Tokens.reduceMotion) {
                pop = 1;
                fadeIn.restart();
            } else {
                popIn.restart();   // sets v = 0 first: opacity 0 at 1 %, no full-size flash
            }
            forceActiveFocus();
        } else {
            fadeIn.stop();
            popIn.stop();
            if (sheet) {
                fadeOut.restart();
            } else if (_cancel) {
                soften = 0;
                _fade0 = opacity;
                _pop0 = pop;
                _outActive = true;
                cancelOut.restart();
            } else {
                opacity = 0;   // order-out type 2: no animation
                pop = 1;
            }
        }
    }
    Component.onCompleted: if (shown) { opacity = 1; forceActiveFocus(); }

    PanelShadow { anchors.fill: parent; cornerRadius: Tokens.panel.alertRadius }
    Rectangle {
        anchors.fill: parent
        radius: Tokens.panel.alertRadius
        color: Tokens.panel.alertFill
        border.width: 0.5
        border.color: Tokens.control.menuStroke
    }
    MouseArea { anchors.fill: parent }   // swallow clicks on the body

    // the content only: the PanelShadow and fill above stay outside the layer, so its texture (clipped to the
    // alert's bounds) never cuts the shadow. Switched on with the cancel order-out, before its first frame; at rest
    // and on the sheet path no layer, so the still is drawn as before. MultiEffect's blur reaches blurMax px at
    // blur 1 and that radius r gave a sigma of r / 2.7 to r / 4 on text (shell AlertDialog.qml, blurfit2.py): r = 4 sigma
    Item {
        id: content
        anchors.fill: parent
        readonly property real blurPx: root.Window.window && root.Window.window.devicePixelRatio > 0
                                       ? root.Window.window.devicePixelRatio : 1   // device px per pt
        layer.enabled: root._outActive && !root.sheet && !Tokens.reduceMotion
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 32
            blur: Math.min(1, 4 * root.soften * content.blurPx / 32)
        }

        Image {
            visible: !!root.layout.icon
            x: visible ? root.layout.icon.x : 0
            y: visible ? root.layout.icon.y : 0
            width: P.alert.icon
            height: P.alert.icon
            sourceSize: Qt.size(2 * width, 2 * height)
            source: root.icon
            mipmap: true
        }
        Text {
            id: titleText
            x: root.layout.title.x
            y: root.layout.title.y
            width: P.alert.textWidth
            text: root.title
            wrapMode: Text.Wrap
            font: Typography.headline        // SF Bold 13
            color: Tokens.label
        }
        Text {
            id: messageText
            visible: root.message !== ""
            x: P.alert.padding
            y: root.layout.message ? root.layout.message.y : 0
            width: P.alert.textWidth
            text: root.message
            wrapMode: Text.Wrap
            font: Typography.body            // SF Regular 13
            color: Tokens.label
        }
        Repeater {
            model: root.buttons
            Rectangle {
                id: btn
                required property var modelData
                required property int index
                readonly property var r: root.layout.buttons[index] || { x: 0, y: 0, width: 0, height: 0 }
                readonly property bool isDefault: index === 0 && !modelData.destructive
                x: r.x; y: r.y; width: r.width; height: r.height
                radius: height / 2
                color: isDefault ? Tokens.panel.defaultFill : modelData.destructive ? Tokens.panel.destructiveFill : Tokens.panel.alertButton
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    visible: ma.pressed && ma.containsMouse
                    color: Tokens.panel.alertButtonPressed
                }
                Text {
                    anchors.centerIn: parent
                    width: parent.width - 16
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: btn.modelData.text
                    font: Typography.body
                    color: btn.isDefault ? "white" : btn.modelData.destructive ? Tokens.panel.destructiveText : Tokens.label
                }
                MouseArea { id: ma; anchors.fill: parent; onClicked: root.press(btn.index) }
            }
        }
    }
}
