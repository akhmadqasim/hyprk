import QtQuick
import ".."
import "../HyprK"
import "../Panes.js" as Panes

// System Settings pane icon. Panes use the real macOS 27.2.1 icons rendered by IconServices,
// themes/icons/settings/<iconId>@<64|128>-<default|dark|clear|tinted>-<light|dark>.png, one set per "Icon & widget
// style" (Appearance pane, AppState.appearance.iconStyle) and appearance (reference/re/MAC-ANSWERS.md R3b, names.json
// settingsIconStyles). Row icons (Panes.isRowIcon: the 24 pt tiles built from Apple's graphic icon configurations) come
// as one 48 px file, the Mac's 24 pt icon at 2x. Anything else (or a missing file) gets a plain coloured tile.
Item {
    id: pi
    property int size: Theme.sidebar.iconSize
    property string iconId
    property string imageSource          // e.g. an app icon; wins over iconId
    property color tint: Theme.tile.blue
    readonly property bool macIcon: /\/themes\/icons\/(apps|system)\/[^\/]+\.png$/.test(imageSource)
    width: size; height: size

    // app icons: the shared macOS 26 tile (HyprK AppIconTile)
    AppIconTile {
        visible: pi.imageSource !== ""
        anchors.centerIn: parent
        size: pi.size / body               // icon body = the pane icon size
        source: pi.imageSource
        // a macOS icon carries the style in its file (Backend.appIconUrl): drawn as it is, as the shell's AppIcon
        trusted: pi.macIcon
        style: pi.macIcon ? "default" : pi.style || "default"
        dpr: pi.dpr
    }
    // The PNG is the whole icon canvas: the tile body is 104 of 128 px (12..116), the rest is its shadow.
    // Drawn so the body is `size`, like the glyph tile; the 64 px file up to 64 device px, else the 128 px one.
    // A row icon is drawn as the Mac draws it, a 24 pt icon for the 20 pt tile (accessibility-light.png: tile body
    // 40 px, image 48 px), so at 2x its file lands on whole pixels.
    // A crop icon (Panes.cropIcons) is the Mac's own tile with its shadow, cut from a row at 2x.
    readonly property bool crop: Panes.isCropIcon(iconId)
    readonly property real art: crop ? size * Panes.cropScale(iconId) : Panes.isRowIcon(iconId) ? size * 1.2 : size * 128 / 104
    // the window's real ratio (1.6 on a fractional output, where Screen.devicePixelRatio says 2), as Finder passes
    // its display.dpr: the art is decoded at the pixels it is drawn on
    readonly property real dpr: Theme.dpr > 0 ? Theme.dpr : Screen.devicePixelRatio
    readonly property real artPx: Math.ceil(art * dpr)
    // Measured on 27.2.1: style Default shows the coloured light tiles also in Dark Mode (the -default-dark files are
    // byte-identical to -default-light); dark tiles only with style Dark (the same in both appearances); Clear and
    // Tinted differ between light and dark. Tinted is rendered with the default (blue) accent, it does not follow ours.
    // Clear and Tinted follow their own Light / Dark / Auto choice (Q-settings-27, #35); Dark is dark in both
    // appearances; Auto follows the window mode
    readonly property string variant: AppState.appearance.iconStyleVariant || "auto"
    readonly property bool darkArt: pi.style !== "default" && (pi.style === "dark" || variant === "auto" ? Theme.dark : variant === "dark")
    Image {
        id: asset
        anchors.centerIn: parent
        width: pi.art; height: pi.art
        visible: status === Image.Ready
        source: pi.imageSource !== "" ? ""
            : pi.crop ? "file://" + Backend.root + "/themes/icons/settings/crops/" + pi.iconId + "-" + (Theme.dark ? "dark" : "light") + ".png"
            : Panes.hasRealIcon(pi.iconId)
            ? "file://" + Backend.root + "/themes/icons/settings/" + pi.iconId + "@" + Panes.iconPx(pi.iconId, pi.artPx)
              + "-" + pi.style + "-" + (pi.darkArt ? "dark" : "light") + ".png" : ""
        sourceSize: pi.crop ? undefined : Qt.size(pi.artPx, pi.artPx)   // scaled once when decoded, cached per size
        smooth: true
    }
    // Icon & widget style (Appearance pane): default = colored tile, dark = black tile with
    // a tinted glyph, clear = gray glass tile, tinted = accent-colored tile. Also picks the pane icon file above.
    readonly property string style: AppState.appearance.iconStyle || "default"
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
    }
}
