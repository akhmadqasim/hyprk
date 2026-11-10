import QtQuick
import Quickshell.Widgets
import qs
import qs.services

// macOS-style alert: glass card (Theme.alert.radius), app icon, bold title, message,
// capsule buttons. Model: { icon, title, message, buttons: [{ label, action, isDefault, isCancel }] }.
// Enter runs the default button, Escape the cancel button.
// Liquid Glass: materializes in around its centre while `shown`, out after (Reduce motion: dissolve).
Item {
    id: root

    property bool shown: false
    visible: mat.active
    Materializer { id: mat; shown: root.shown }
    transform: MaterializeScale {
        mat: mat
        origin.x: root.width / 2
        origin.y: root.height / 2
        w: root.width
        h: root.height
    }

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
    onShownChanged: if (shown) Qt.callLater(forceActiveFocus)   // after `visible` follows
    Keys.onEscapePressed: pressCancel()
    Keys.onReturnPressed: pressDefault()
    Keys.onEnterPressed: pressDefault()

    Glass {
        anchors.fill: parent
        radius: Theme.alert.radius
        sx: root.originX
        sy: root.originY
        tint: Theme.glass.tintStrong
        materialize: mat.progress
    }
    MouseArea { anchors.fill: parent }

    Column {
        id: col
        opacity: mat.progress
        enabled: root.shown
        x: Theme.alert.padding
        y: Theme.alert.padding
        width: parent.width - Theme.alert.padding * 2
        spacing: Theme.alert.spacing

        IconImage {
            anchors.horizontalCenter: parent.horizontalCenter
            implicitSize: Theme.alert.iconSize
            source: Apps.iconUrl(root.model ? root.model.icon : "", "")
            mipmap: true
        }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: root.model ? root.model.title : ""
            font.family: Theme.fontText
            font.pixelSize: Theme.alert.titleSize
            font.weight: Font.Bold
            color: Theme.color.label
        }
        Text {
            width: parent.width
            visible: text !== ""
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: root.model && root.model.message ? root.model.message : ""
            font.family: Theme.fontText
            font.pixelSize: Theme.alert.messageSize
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
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.menu
                        font.weight: Font.Medium
                        color: btn.modelData.isDefault ? Theme.color.textOnAccent : Theme.color.label
                    }
                    MouseArea { id: bma; anchors.fill: parent; onClicked: root.press(btn.modelData) }
                }
            }
        }
    }
}
