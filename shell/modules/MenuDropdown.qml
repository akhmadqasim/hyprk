import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.components
import qs.services
import qs.HyprK

// Pull-down menu of the menu bar, macOS 26 style: rounded glass, inset
// rounded selection, shortcut column on the right.
// Motion as measured on macOS 27.2.1 (reference/re/LIVE-27.2.1.md): an AppKit menu appears at once,
// without scale or fade, and fades out in about 0.2 s (ease-out) with the last items it showed. The
// selection glides from row to row instead of jumping (Reduce motion: no glide).
Item {
    id: root

    property var items: []
    property bool shown: false
    property real originX: 0       // screen position of this item, for the glass backdrop
    property real originY: 0
    property real anchorX: 0       // the menu bar title or click point, local (menus do not scale: unused)
    property real anchorY: 0

    // the items stay while the menu fades out. The menu bar clears them on close, and that arrives
    // while `shown` is still true (Panels resets menuIndex first), so an empty list is never taken
    property var shownItems: []
    function latchItems() { if (shown && items.length > 0) shownItems = items; }
    onItemsChanged: latchItems()
    // 1 while shown, then down to 0 on close: glass materialize and content opacity
    property real fade: 0
    visible: shown || fade > 0
    NumberAnimation { id: fadeOut; target: root; property: "fade"; to: 0; duration: Theme.anim.menuFadeOut; easing.type: Easing.OutQuad }
    Component.onCompleted: { latchItems(); if (shown) fade = 1; }

    readonly property real contentWidth: Math.max(Theme.menu.minWidth, maxTextWidth + Theme.menu.itemHPadding * 2 + Theme.menu.itemInset * 2 + 40)
    width: contentWidth
    height: list.height + Theme.menu.padding * 2

    signal triggered()

    function trigger(action) {
        Panels.close();
        triggered();
        if (typeof action === "function") {
            action();
            return;
        }
        switch (action) {
        case "settings": Apps.openSettings(); break;
        case "about": Panels.showAlert({
            icon: Distro.aboutIcon,
            title: "About This Computer",
            message: Distro.prettyName + (Distro.kernel ? "\nLinux " + Distro.kernel : ""),
            buttons: [{ label: "More Info…", action: Apps.openSettings }, { label: "OK", isDefault: true }],
        }); break;
        case "forcequit": Hyprland.dispatch("hl.dsp.window.kill()"); break;
        case "close": Hyprland.dispatch("hl.dsp.window.close()"); break;
        case "fullscreen": Hyprland.dispatch("hl.dsp.window.fullscreen()"); break;
        case "zoom": Hyprland.dispatch("hl.dsp.window.fullscreen({ mode = \"maximized\" })"); break;
        case "spotlight": Panels.open = "spotlight"; break;
        case "apps": AppsView.show(); break;
        case "sleep": Power.sleep(); break;
        case "restart": Power.restart(); break;
        case "shutdown": Power.shutdown(); break;
        case "lock": Power.lock(); break;
        case "logout": Power.logout(); break;
        case "widgets": Panels.open = "nc"; break;
        case "desktop-new-folder":
            Quickshell.execDetached(["sh", "-c", 'd="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"; n="$d/untitled folder"; i=2; while [ -e "$n" ]; do n="$d/untitled folder $i"; i=$((i+1)); done; mkdir -p "$n"']);
            break;
        }
    }

    // width of the widest label + shortcut
    FontMetrics { id: metrics; font: Typography.menu }
    readonly property real maxTextWidth: {
        let w = 0;
        for (const it of shownItems)
            if (!it.sep) w = Math.max(w, metrics.advanceWidth(it.label) + (it.shortcut ? metrics.advanceWidth(it.shortcut) + Theme.menu.shortcutGap : 0));
        return w;
    }

    Glass {
        anchors.fill: parent
        radius: Theme.menu.radius
        sx: root.originX
        sy: root.originY
        tint: Theme.glass.tintStrong
        materialize: root.fade
    }

    // selection: one inset pill that glides to the hovered row; it appears in place when the
    // pointer comes in from outside the menu
    property int hover: -1
    property real hoverY: 0
    property real hoverH: Theme.menu.itemHeight
    function enterRow(i, y, h) {
        const fresh = hover < 0;
        hover = i;
        hoverY = y;
        hoverH = h;
        if (fresh || A11y.reduceMotion) selY.snap();
    }
    // leaving a row and entering the next arrive in one pointer event: clear only if none took over
    // (a closing menu keeps its selection while it fades out)
    function leaveRow(i) { Qt.callLater(() => { if (root.shown && root.hover === i) root.hover = -1; }); }
    onShownItemsChanged: hover = -1
    onShownChanged: {
        if (shown) {
            latchItems();
            hover = -1;
            fadeOut.stop();
            fade = 1;
        } else {
            fadeOut.start();
        }
    }
    Spring { id: selY; target: root.hoverY; response: Theme.anim.menuTrackResponse; damping: Theme.anim.menuTrackDamping; epsilon: 0.3 }
    Rectangle {
        visible: root.hover >= 0
        x: Theme.menu.itemInset
        y: list.y + selY.value
        width: parent.width - Theme.menu.itemInset * 2
        height: root.hoverH
        radius: Theme.menu.itemRadius
        color: Theme.color.menuSelection
        opacity: root.fade
    }

    Column {
        id: list
        y: Theme.menu.padding
        width: parent.width
        opacity: root.fade

        Repeater {
            model: root.shownItems
            delegate: Item {
                id: row
                required property var modelData
                required property int index
                readonly property bool enabled: !modelData.sep && !modelData.disabled
                readonly property bool hovered: ma.containsMouse && enabled
                readonly property bool selected: root.hover === index
                onHoveredChanged: hovered ? root.enterRow(index, y, height) : root.leaveRow(index)
                width: list.width
                height: modelData.sep ? Theme.menu.separatorHeight : Theme.menu.itemHeight

                Rectangle {
                    visible: row.modelData.sep === true
                    anchors.centerIn: parent
                    width: parent.width - Theme.menu.itemInset * 2 - Theme.menu.itemHPadding
                    height: 1
                    color: Theme.color.separator
                }
                Text {
                    visible: !row.modelData.sep
                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.menu.itemInset + Theme.menu.itemHPadding
                    text: row.modelData.label || ""
                    font: Typography.menu
                    color: !row.enabled ? Theme.color.tertiaryLabel : row.selected ? Theme.color.menuSelectionText : Theme.color.label
                }
                Text {
                    visible: !row.modelData.sep && (row.modelData.shortcut !== undefined)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.menu.itemInset + Theme.menu.itemHPadding
                    text: row.modelData.shortcut || ""
                    font: Typography.menu
                    color: row.selected ? Theme.color.menuSelectionText : Theme.color.tertiaryLabel
                }
                Symbol {
                    visible: row.modelData.submenu === true
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.menu.itemInset + Theme.menu.itemHPadding - 4
                    name: "chevron.right"
                    size: 11
                    color: row.selected ? Theme.color.menuSelectionText : Theme.color.secondaryLabel
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.shown
                    onClicked: if (row.enabled) root.trigger(row.modelData.action)
                }
            }
        }
    }
}
