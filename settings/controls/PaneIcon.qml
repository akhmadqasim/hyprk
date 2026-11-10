import QtQuick
import QtQuick.Effects
import ".."
import "../HyprK"
import "../Panes.js" as Panes

// System Settings pane icon. Panes use the real macOS 27.2.1 icons rendered by IconServices,
// themes/icons/settings/<iconId>@<64|128>-<light|dark>.png (reference/re/MAC-ANSWERS.md R3b); anything else
// (or a missing file) gets a coloured rounded-square tile with a Material Icons glyph.
Item {
    id: pi
    property int size: Theme.sidebar.iconSize
    property string glyph
    property string iconId
    property string imageSource          // e.g. an app icon; wins over iconId
    property color tint: Theme.tile.blue
    width: size; height: size

    // app icons: the shared macOS 26 tile (HyprK AppIconTile)
    AppIconTile {
        visible: pi.imageSource !== ""
        anchors.centerIn: parent
        size: pi.size / body               // icon body = the pane icon size
        source: pi.imageSource
        style: pi.style || "default"
    }
    // The PNG is the whole icon canvas: the tile body is 104 of 128 px (12..116), the rest is its shadow.
    // Drawn so the body is `size`, like the glyph tile; the 64 px file up to 64 device px, else the 128 px one.
    readonly property real art: size * 128 / 104
    readonly property real artPx: Math.ceil(art * Screen.devicePixelRatio)
    // Light file = coloured tile, dark file = black tile with the symbol in the tile colour (IconServices
    // appearance 0 / 1). Which one macOS shows for the "Default" style in Dark Mode was not measured: we follow
    // the appearance, and the "Dark" style always takes the dark file.
    readonly property bool darkArt: pi.style === "dark" || Theme.dark
    Image {
        id: asset
        anchors.centerIn: parent
        width: pi.art; height: pi.art
        visible: status === Image.Ready
        source: pi.imageSource === "" && Panes.hasRealIcon(pi.iconId)
            ? "file://" + Backend.root + "/themes/icons/settings/" + pi.iconId + "@" + (pi.artPx > 64 ? 128 : 64)
              + "-" + (pi.darkArt ? "dark" : "light") + ".png" : ""
        sourceSize: Qt.size(pi.artPx, pi.artPx)   // scaled once when decoded, cached per size
        smooth: true
        // "Clear" icon style shows images as monochrome glass, like macOS 26+
        layer.enabled: pi.style === "clear"
        layer.effect: MultiEffect { saturation: -1.0; brightness: 0.05 }
    }
    // Icon & widget style (Appearance pane): default = colored tile, dark = black tile with
    // a tinted glyph, clear = gray glass tile, tinted = accent-colored tile.
    readonly property string style: AppState.appearance.iconStyle
    readonly property color tileColor: style === "dark" ? "#1C1C1E"
        : style === "clear" ? (Theme.dark ? "#5A5A5E" : "#7E7E7E")   // ref (clear style)
        : style === "tinted" ? Theme.accent : tint
    Rectangle {
        visible: pi.imageSource === "" && !asset.visible
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
