import QtQuick
import "panels.js" as P

// NSAlert as on macOS 27.2.1 (MAC-ANSWERS.md Q-panels-33/34; layout in panels.js alertLayout): 260 wide, r 26,
// 64 pt icon top-left, bold 13 title and regular 13 message left-aligned. buttons[0] is the default (accent,
// white text); 2 buttons sit side by side with the default on the right, 3 stack (default, third, second).
// A destructive button has red text on a red-tinted capsule; no hover. `sheet`: the alert-sheet form (no icon,
// no pop; the caller's Sheet dims and fades). Return = default, Escape = the cancel button.
// The caller places it (P.alertTop for app-modal alerts: no dim) and sets `shown`; `activated(index)` follows.
// Motion (Tokens.panel): grows from 4 % to a 1.15 peak in 0.2 s (in-quad), back to 1 in 0.17 s; out = 0.1 s fade.
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

    function press(i) { if (shown) activated(i); }
    function cancelIndex() {
        const i = buttons.findIndex(b => b.cancel);
        return i >= 0 ? i : buttons.length - 1;
    }
    Keys.onReturnPressed: press(0)
    Keys.onEnterPressed: press(0)
    Keys.onEscapePressed: press(cancelIndex())

    property real pop: 1
    transform: Scale { origin.x: root.width / 2; origin.y: root.height / 2; xScale: root.pop; yScale: root.pop }
    SequentialAnimation {
        id: popIn
        NumberAnimation { target: root; property: "pop"; from: Tokens.panel.alertPopFrom; to: Tokens.panel.alertPopPeak; duration: Tokens.panel.alertPopRise; easing.type: Easing.InQuad }
        NumberAnimation { target: root; property: "pop"; to: 1; duration: Tokens.panel.alertPopSettle; easing.type: Easing.OutQuad }
    }
    NumberAnimation { id: fadeIn; target: root; property: "opacity"; to: 1; duration: root.sheet ? Tokens.panel.sheetIn : 150 }
    NumberAnimation { id: fadeOut; target: root; property: "opacity"; to: 0; duration: root.sheet ? Tokens.panel.sheetOut : Tokens.panel.alertFadeOut; easing.type: root.sheet ? Easing.Linear : Easing.OutQuad }
    onShownChanged: {
        if (shown) {
            fadeOut.stop();
            if (sheet || Tokens.reduceMotion) {
                pop = 1;
                fadeIn.restart();
            } else {
                opacity = 1;
                pop = Tokens.panel.alertPopFrom;   // before the first frame: no full-size flash
                popIn.restart();
            }
            forceActiveFocus();
        } else {
            fadeIn.stop();
            popIn.stop();
            fadeOut.restart();
        }
    }
    Component.onCompleted: if (shown) { opacity = 1; forceActiveFocus(); }

    Rectangle {
        anchors.fill: parent
        radius: Tokens.panel.alertRadius
        color: Tokens.panel.alertFill
        border.width: 0.5
        border.color: Tokens.control.menuStroke
    }
    MouseArea { anchors.fill: parent }   // swallow clicks on the body

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
