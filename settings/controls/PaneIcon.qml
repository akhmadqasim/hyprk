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
    // Icon & widget style (Appearance pane): default = colored tile, dark = black tile with
    // a tinted glyph, clear = gray glass tile, tinted = accent-colored tile.
    readonly property string style: AppState.appearance.iconStyle
    readonly property color tileColor: style === "dark" ? "#1C1C1E"
        : style === "clear" ? (Theme.dark ? "#5A5A5E" : "#7E7E7E")   // ref (clear style)
        : style === "tinted" ? Theme.accent : tint
    Rectangle {
        visible: !asset.visible
        anchors.fill: parent
        radius: pi.size * 0.27
        border.width: pi.style === "clear" ? 1 : 0
        border.color: Qt.rgba(1, 1, 1, 0.55)
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.lighter(pi.tileColor, pi.style === "clear" ? 1.04 : 1.12) }
            GradientStop { position: 1; color: pi.tileColor }
        }
        Text {
            anchors.centerIn: parent
            text: pi.glyph
            font.family: Theme.fontGlyph; font.pixelSize: Math.round(pi.size * 0.68)
            color: pi.style === "dark" ? Qt.lighter(pi.tint, 1.15) : "white"
        }
    }
}
