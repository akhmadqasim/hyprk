import QtQuick
import qs
import qs.HyprK
import qs.services

// App icon for the shell: resolves the icon (macOS icon when mapped, else the icon theme)
// and draws it with AppIconTile (macOS 26 squircle tile for icons that are not squircles).
AppIconTile {
    property string icon
    property string appId

    // the style's own rendition for macOS icons (Theme.iconLook), Default for the rest
    source: Apps.iconUrl(icon, appId, Theme.iconLook)
    // macOS icons, and Dock folders/Trash (macOS never puts those on a tile)
    trusted: Apps.isMacIcon(icon, appId) || /^(user-trash|folder)/.test(icon)
    // macOS icons carry the style in their file; only other icons get the styled tile and glyph effect
    style: Apps.isMacIcon(icon, appId) ? "default" : Theme.iconTileStyle
    tint: Theme.color.accent
    // Clear / Tinted in their dark form: the style's own Dark choice, or Auto in dark mode (iconStyleVariant)
    styleDark: Theme.iconStyleVariant === "dark" || (Theme.iconStyleVariant !== "light" && Theme.dark)
    // a Dark / Clear / Tinted rendition is not cached: a style switch drops the whole set, and Qt's cache only frees
    // unreferenced images a quarter every 30 s (cycling 4 styles x 2 modes left +38 MB, still +14 MB 90 s later)
    cache: !/-256-(dark|clear|tinted)-(dark|light)\.png$/.test(String(source))
    body: Theme.appIcon.body
    inner: Theme.appIcon.inner
}
