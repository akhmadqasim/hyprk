import QtQuick

// Minimal alert sheet for errors (rename clash, trash failure).
Item {
    id: root

    property string message: ""
    visible: message !== ""

    function show(msg) { message = msg; ok.forceActiveFocus(); }

    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }

    Rectangle {
        anchors.centerIn: parent
        width: 300
        height: column.height + 32
        radius: 20
        color: Theme.color.alert
        border.width: 1
        border.color: Theme.color.separator

        Column {
            id: column
            y: 16
            x: 20
            width: parent.width - 40
            spacing: 16
            // first line is the headline, the rest is detail (Finder alert layout)
            TextLabel {
                width: parent.width
                text: root.message.split("\n")[0]
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                color: Theme.color.label
                font.pixelSize: 13
                weight: Font.DemiBold
            }
            Text {
                width: parent.width
                visible: text !== ""
                text: root.message.split("\n").slice(1).join("\n")
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                color: Theme.color.secondaryLabel
                font.family: Theme.fontText
                font.pixelSize: 11
            }
            Rectangle {
                id: ok
                width: parent.width
                height: 28
                radius: 14
                color: Theme.color.accent
                Keys.onReturnPressed: root.message = ""
                Keys.onEscapePressed: root.message = ""
                Keys.onSpacePressed: root.message = ""
                Text {
                    anchors.centerIn: parent
                    text: "OK"
                    color: "white"
                    font.family: Theme.fontText
                    font.pixelSize: 13
                }
                TapHandler { onTapped: root.message = "" }
            }
        }
    }
}
