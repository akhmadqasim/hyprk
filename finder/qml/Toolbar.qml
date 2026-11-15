import QtQuick
import HyprK
import "lib/symbols.js" as Symbols

// Unified toolbar over the content area: back/forward, title, view switcher, group,
// actions (share, tag, more) and search. Empty space drags the window. The strip itself has no fill and
// no glass; only the capsules are drawn (macOS 27.2.1, MAC-ANSWERS.md Q9.2).
Item {
    id: root

    required property var browser
    required property var window
    property string view: "icons"
    property bool searching: false
    property bool menuUp: false   // Main.qml's menu is up or this press is closing it
    signal viewRequested(string view)
    signal moreRequested(Item anchor)
    signal groupRequested(Item anchor)
    signal tagRequested(Item anchor)
    signal viewMenuRequested(Item anchor)
    readonly property Item tagAnchor: tagButton
    readonly property Item moreAnchor: more

    height: Theme.toolbar.height

    // window drag / double-click zoom on empty toolbar space. The double tap counts within the style hint's interval, set
    // to the Mac's 0.5 s in main.cpp (NSEvent.doubleClickInterval); the zoom is Main.zoom (Hyprland's maximized mode:
    // showMaximized asks for xdg maximize, which the session suppresses, so a double-click did nothing: judge-95-14)
    TapHandler {
        // not on a capsule: two quick clicks on a button are two clicks (this handler sees them too, and a second
        // click on Group within the double-click time zoomed the window and left the menu up, live)
        onDoubleTapped: {
            const p = point.position;
            for (let i = 0; i < root.children.length; i++) {
                const c = root.children[i];
                if (c.visible && c.lightHovers !== undefined && p.x >= c.x && p.x <= c.x + c.width && p.y >= c.y && p.y <= c.y + c.height) return;
            }
            root.window.zoom();
        }
    }
    HoverHandler { id: stripHover }
    DragHandler {
        target: null
        onActiveChanged: if (active) root.window.startSystemMove()
    }

    Capsule {
        id: nav
        lights: true
        x: Theme.toolbar.leftPad
        y: Theme.toolbar.capsuleY
        ToolButton {
            id: backButton
            implicitWidth: (Theme.toolbar.navWidth - 1) / 2
            icon: "chevron.left"
            enabled: root.browser.canGoBack
            onClicked: root.browser.back()
        }
        // the divider hides while either half is hovered or pressed (Q-finder-10); a disabled half lights nothing
        Rectangle {
            width: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); height: Theme.toolbar.dividerHeight; anchors.verticalCenter: parent.verticalCenter
            color: Theme.color.toolbarSeparator
            opacity: nav.lit ? 0 : 1
        }
        ToolButton {
            id: forwardButton
            implicitWidth: (Theme.toolbar.navWidth - 1) / 2
            icon: "chevron.right"
            enabled: root.browser.canGoForward
            onClicked: root.browser.forward()
        }
    }

    TextLabel {
        x: nav.x + nav.width + Theme.toolbar.titleGap
        width: Math.max(0, views.x - x - 12)
        anchors.verticalCenter: nav.verticalCenter
        text: root.browser.title
        elide: Text.ElideRight
        color: Theme.color.title
        font: Typography.toolbarTitle   // 15 Semibold (27.2.1)
    }

    Capsule {
        id: views
        anchors.right: group.left
        anchors.rightMargin: Theme.toolbar.viewsGap
        y: Theme.toolbar.capsuleY
        visible: root.width > 524 && !root.searching
        // the segments sit 2 pt in, 39.6 apart: the glyph centres on 27.2.1 are 21.3 / 60.9 / 100.7 / 139.6 pt into the
        // capsule (crops/toolbar-*-active.png, ink centroids; even 40.25 segments put them 1.1 pt rms off, this 0.4)
        width: Theme.toolbar.viewsWidth
        padding: 2
        // the whole capsule lifts while the switcher is held (viewsLift below)
        transform: Scale {
            origin.x: views.width / 2; origin.y: views.height / 2
            xScale: 1 + Theme.toolbar.viewsLift / Math.max(views.width, 1) * viewsLift.value
            yScale: xScale
        }
        SegmentedControl {
            id: viewSwitcher
            readonly property var modes: ["icons", "list", "columns", "gallery"]
            readonly property string iconHex: Qt.rgba(Theme.color.toolbarIcon.r, Theme.color.toolbarIcon.g, Theme.color.toolbarIcon.b, 1).toString()
            segmentWidth: Theme.toolbar.segmentWidth
            width: implicitWidth
            height: Theme.toolbar.capsuleHeight
            iconSize: Theme.toolbar.iconSize
            iconOpacity: Theme.color.toolbarIcon.a
            // a separator at every boundary, hidden next to the selected segment: with Columns selected
            // the 27.2.1 Finder shows only the one between Icons and List
            separatorColor: Theme.color.toolbarSeparator
            separatorHeight: Theme.toolbar.segmentSeparator
            selectionInset: Theme.toolbar.segmentInsetY
            selectionInsetX: Theme.toolbar.segmentInsetX
            trackRadius: height / 2                       // the glass capsule and its inner pill (Q-finder-11)
            selectionRadius: height / 2 - Theme.toolbar.segmentInsetY
            trackColor: "transparent"
            selectionColor: Theme.color.capsuleSelected
            // the selected segment hovered / pressed, each in one frame (R6.3 controls/segmented-drag-*.mov, pill interior
            // left of the glyph, green, two sampling boxes): light 223.4 -> 212.2 / 202.8 = black .049-.050 / .091-.092;
            // dark, over the plain selected + toolbar wash 77.1, 93.2-93.9 / 99.0-99.1 = white .090-.094 / .123-.124
            // (before the wash 70.0 -> 87.8). On screen: light .049 / .091, dark .095 / .119. A press dragged onto another
            // segment: SegmentedControl draws it in the plain selected colour
            hoverOverlay: Theme.dark ? Qt.rgba(1, 1, 1, 0.090) : Qt.rgba(0, 0, 0, 0.049)
            pressOverlay: Theme.dark ? Qt.rgba(1, 1, 1, 0.123) : Qt.rgba(0, 0, 0, 0.091)
            model: modes.map(m => ({ icon: Symbols.url("view." + m, iconHex, "white") }))
            currentIndex: modes.indexOf(root.view)
            onActivated: i => root.viewRequested(modes[i])
            Accessible.name: "View"
        }
    }
    // The view switcher's capsule lifts from mouse-down to mouse-up (R6.3, controls/segmented-drag-{light,dark}.mov at 2x,
    // edge half-crossings on rows 56-70 px): 322.0 -> 326.2 px wide, Theme.toolbar.viewsLift, uniform (the top and bottom
    // edges move 0.5 px); 35-47 % of it in the first frame, settled in about 50 ms. The rim stays where it settles
    // within 0.1 px through the press (the 4-11 % "overshoot" of the half-crossings is the edge blurring while it
    // scales), so a critically damped spring: response 0.065 s, damping 0.96 fits both clips (rms 1.7 % of the lift;
    // FlexInteraction's 0.25 s / 0.375 for 161 x 37 pt, motion.js pressDamping, 7.7 % and a 28 % bounce the Mac lacks).
    // Mouse-up: back in one frame (326.1 -> 322.0). Reduce Motion: no lift
    Spring { id: viewsLift; response: 0.065; damping: 0.96 }
    Connections {
        target: viewSwitcher
        function onHeldChanged() {
            viewsLift.target = viewSwitcher.held && !Tokens.reduceMotion ? 1 : 0;
            if (!viewSwitcher.held) viewsLift.snap();
        }
    }

    // while the search field is open the switcher collapses into a popup button, the current view's glyph and an up/down
    // chevron, laid out like the group button (crops/search-expand-frames-light.png, in one frame: Q-finder-30)
    Capsule {
        id: viewPopup
        lights: true
        anchors.right: group.left
        anchors.rightMargin: Theme.toolbar.viewsGap
        y: Theme.toolbar.capsuleY
        padding: 3
        visible: root.width > 524 && root.searching
        ToolButton {
            id: viewPopupButton
            implicitWidth: 28
            hoverWidth: 28
            icon: "view." + root.view
            hitRight: viewPopup.width - 6 - width      // the chevron opens the menu too
            // with its menu up a click closes it and does not reopen it (the ⋯ button's inMenu below; judge #21)
            property bool inMenu: false
            onDownChanged: if (down) inMenu = root.menuUp
            onClicked: if (!inMenu) root.viewMenuRequested(viewPopupButton)
        }
        Symbol {
            anchors.verticalCenter: parent.verticalCenter
            name: "chevron.up.chevron.down"
            weight: "semibold"
            size: 11
            color: Theme.color.toolbarIcon
        }
        Item { width: Theme.toolbar.groupWidth - 6 - 28 - 11; height: 1 }
    }

    Capsule {
        id: group
        lights: true
        anchors.right: actions.left
        anchors.rightMargin: Theme.toolbar.gap
        y: Theme.toolbar.capsuleY
        // 27.2.1: 46 pt capsule, group glyph centred at 17, chevron at 36.5
        padding: 3
        visible: root.width > 622
        ToolButton {
            id: groupButton
            implicitWidth: 28
            hoverWidth: 28
            icon: "group"
            iconDx: 0.7      // ink centre 556.2 pt on 27.2.1 (crops/toolbar-*-active.png), centred here 555.5
            hitRight: group.width - 6 - width          // the chevron opens the menu too
            // with its menu up a click closes it and does not reopen it (the ⋯ button's inMenu below; judge #21)
            property bool inMenu: false
            onDownChanged: if (down) inMenu = root.menuUp
            onClicked: if (!inMenu) root.groupRequested(groupButton)
        }
        Symbol {
            anchors.verticalCenter: parent.verticalCenter
            name: "chevron.down"
            weight: "semibold"
            size: 11
            transform: Translate { x: -0.4 }    // ink centre 0.4 pt left of the Row slot (same crops)
            color: Theme.color.toolbarIcon
        }
        Item { width: Theme.toolbar.groupWidth - 6 - 28 - 11; height: 1 }
    }

    Capsule {
        id: actions
        lights: true
        anchors.right: search.left
        anchors.rightMargin: Theme.toolbar.gap
        y: Theme.toolbar.capsuleY
        visible: root.width > 458
        // AX widths 36 / 38 / 37 in the 112 pt capsule (Q-finder-02)
        ToolButton {
            implicitWidth: 36.5
            icon: "share"
            enabled: root.browser.selectedCount > 0
            onClicked: root.browser.openSelection()
        }
        ToolButton {
            id: tagButton
            implicitWidth: 38
            icon: "tag"
            enabled: root.browser.selectedCount > 0 && root.browser.userFiles
            onClicked: root.tagRequested(tagButton)
        }
        ToolButton {
            id: more
            implicitWidth: Theme.toolbar.actionsWidth - 36.5 - 38
            icon: "ellipsis"
            // a pull-down's button clicked with its menu up closes the menu and does not reopen it (ui/HyprK/Popup.qml
            // inMenu): decided on the press, which the menu's close-on-press-outside sees first
            property bool inMenu: false
            onDownChanged: if (down) inMenu = root.menuUp
            onClicked: if (!inMenu) root.moreRequested(more)
        }
    }

    Capsule {
        id: search
        anchors.right: parent.right
        anchors.rightMargin: Theme.toolbar.rightPad
        y: Theme.toolbar.capsuleY
        width: root.searching ? Theme.toolbar.searchWidth : Theme.toolbar.capsuleHeight
        // the circle widens into a capsule in about 0.16 s, ease-out (Q-finder-30)
        Behavior on width { NumberAnimation { duration: Theme.toolbar.searchDuration; easing.type: Easing.OutCubic } }
        // held (closed): the disc and its glyph grow to 40 pt in the press frame, about the centre (R11.5)
        scale: root.searching ? 1 : 1 + (Theme.toolbar.searchPressScale - 1) * searchButton.held

        // open: the glyph shrinks to 13 pt at the default scale, centred 17 pt in, and the text starts at 33
        // (crops/search-expand-frames-light.png: ink 12 vs 16 pt wide closed, centre 17, "Search" ink from 33.5)
        ToolButton {
            id: searchButton
            pressLook: !root.searching
            pressColor: Theme.color.searchPress
            pressIconColor: Theme.color.searchPressIcon
            pressRim: Theme.color.searchPressRim
            pressRimSide: Theme.color.searchPressRimSide
            releaseMs: Theme.toolbar.searchReleaseMs
            implicitWidth: root.searching ? 33 : Theme.toolbar.buttonWidth
            iconDx: root.searching ? 0.5 : 0
            hoverWidth: Theme.toolbar.buttonWidth      // the whole circle lightens on hover
            // the capsule's own height (dark, active: 36 pt, Capsule.inset): the held disc is the capsule grown by
            // searchPressScale, not a 37 pt one (it stood 40 pt tall on a 36 pt capsule, x1.11, live)
            hoverHeight: Theme.toolbar.capsuleHeight - 2 * search.inset
            hoverColor: Theme.color.searchHover
            iconColor: root.searching ? Theme.color.searchPlaceholder : Theme.color.searchIcon
            iconDy: root.searching ? 0 : -0.5   // closed: ink centre 0.5 pt above the capsule's on 27.2.1 (same crops)
            icon: "magnifyingglass"
            iconWeight: "medium"       // 13 pt, .large, medium (names.json finder.toolbarGlyph, likely)
            iconScale: root.searching ? "" : "large"
            iconPointSize: 13
            onClicked: {
                root.searching = true;
                field.forceActiveFocus();
            }
        }
        Item {
            visible: root.searching
            width: search.width - 33 - 8
            height: Theme.toolbar.capsuleHeight
            TextInput {
                id: field
                MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }   // TextInput sets no I-beam itself
                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                clip: true
                color: Theme.color.label
                selectionColor: Theme.color.textSelection
                selectedTextColor: Theme.color.label
                font: Typography.body
                text: root.browser.query
                onTextEdited: root.browser.query = text
                // Return/arrows must not reach the window's key handler (rename, cursor moves)
                Keys.onReturnPressed: root.window.focusContent()
                Keys.onEnterPressed: root.window.focusContent()
                Keys.onUpPressed: {}
                Keys.onDownPressed: {}
                Keys.onEscapePressed: {
                    root.browser.query = "";
                    root.searching = false;
                }
                Text {
                    visible: !field.text
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Search"
                    color: Theme.color.searchPlaceholder
                    font: field.font
                }
            }
            // the field editor's right-click menu (HyprK textmenu.js), as the other Finder fields; an NSSearchField's
            // editor is the same NSTextView (MENUS-REA "Text field context menu")
            TextMenu { target: field }
        }
    }

    FocusRing { parent: search; visible: field.activeFocus; shapeRadius: search.height / 2 }

    function focusSearch() {
        searching = true;
        field.forceActiveFocus();
    }

    Rectangle {   // dark: the whole strip lightens while the pointer is in it (Theme.color.toolbarHoverWash, Q-finder-10)
        // and under a sheet, where the window is not key: finder/sheet-dark.png reads the strip (27,28,32) over the
        // content's (25,26,29) through the veil, the washed (39,39,44) before it (System Settings' strip does the
        // same, SettingsApp.qml); ours read (24,25,29), the content's tone
        anchors.fill: parent
        z: 10
        visible: Theme.dark && (Theme.sheet || (stripHover.hovered && Theme.active))
        color: Theme.color.toolbarHoverWash
    }
}
