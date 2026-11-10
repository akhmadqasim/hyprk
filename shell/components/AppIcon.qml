import QtQuick
import qs
import qs.services

// App icon for the shell: resolves the icon (macOS icon when mapped, else the icon theme)
// and draws it with AppIconTile (macOS 26 squircle tile for icons that are not squircles).
AppIconTile {
    property string icon
    property string appId

    source: Apps.iconUrl(icon, appId)
    trusted: Apps.isMacIcon(icon, appId)
    style: Theme.iconStyle
    tint: Theme.color.accent
    body: Theme.appIcon.body
    inner: Theme.appIcon.inner
}
