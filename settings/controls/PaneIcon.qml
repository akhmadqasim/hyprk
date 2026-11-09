import QtQuick
import ".."

// Colored rounded-square tile with a white glyph. Uses themes/icons/settings/<iconId>.png
// when the assets agent provides it, else a Material Icons glyph (generic fallback).
Item {
    id: pi
    property int size: Theme.sidebar.iconSize
    property string glyph
    property string iconId
    property color tint: Theme.tile.blue
    width: size; height: size

    Image {
        id: asset
        anchors.fill: parent
        visible: status === Image.Ready
        source: pi.iconId !== "" ? Backend.root + "/themes/icons/settings/" + pi.iconId + ".png" : ""
        sourceSize: Qt.size(pi.size * 2, pi.size * 2)
        smooth: true; mipmap: true
    }
    Rectangle {
        visible: !asset.visible
        anchors.fill: parent
        radius: pi.size * 0.27
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.lighter(pi.tint, 1.12) }
            GradientStop { position: 1; color: pi.tint }
        }
        Text {
            anchors.centerIn: parent
            text: pi.glyph
            font.family: Theme.fontGlyph; font.pixelSize: Math.round(pi.size * 0.68)
            color: "white"
        }
    }
}
