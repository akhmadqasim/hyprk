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
    body: Theme.appIcon.body
    inner: Theme.appIcon.inner
}
