import QtQuick
import QtQuick.Effects
import QtQuick.Controls.Basic as C
import "motion.js" as Motion

// Pop-up button as System Settings draws it (MAC-ANSWERS.md Q-settings-19, -20; appearance-, sound-, displays-light.png):
// a 24 pt frame with nothing drawn at rest but the value in 13 pt and the up/down chevron in a 20 pt push-fill circle
// 3.5 pt from the right edge; the text ends 12 pt before the circle and starts 12 pt in (133 pt wide for "Automatic"
// with its dot: 12 + 16 + 8 + text + 12 + 20 + 3.5). Disabled: the fill at 0.5.
// Hover and press (R3.8a, settings/appearance/control-*-{rest,hover,pressed}-*.png, 2x stills): the pointer over the
// button fills the whole 24 pt frame with the push fill (228 on the 247 card light, 53 on 37 dark: the circle's own
// colour), radius 6 (a circular fit of the continuous corner, rms .03 on the coverage; 5.5 and 6.5 worse) and the
// circle is not drawn on it; pressed, and while the menu is up, the frame darkens to 206 (light: black a.098 over the
// fill, 228 x .902 = 205.7). Dark pressed has no still (the menu covers it 30 ms in); white a.098 over the fill as the
// alert's dark pressed (Tokens.panel.alertButtonPressed), 53 -> 73: the R3.5 clip reads 48 -> 66 over 34 (the same
// ratio, video levels). After the menu the pointer has to leave the button before it lights again (R3.5, light 4.500 s).
// A dot (`dots`) is 16 pt in the button, 8 pt before the text, and 16 pt in the menu.
// The menu (R3.8a control-*-open-*.png): rows 24, separators 11 (`separators`: the rows a line follows) with a 1 pt
// line from the text column's 25 pt to 11 pt before the row's end, padding 5 inside a 0.5 pt rim, radius 12, its rim
// 12.5 pt left of the button, the checked row's highlight on the button's top, as wide as its widest row asks (the
// colour menus are wider than the button: 169 / 147 pt against 133), accent highlight pill (inset 5, radius 6) with
// white text; checkmark ink 8.5 pt into the highlight (7.5 when the rows have dots), dots 16 pt at 24, text at 25
// (47 with dots). Motion as the Mac's (popup-menu-open-close-{light,dark}.mov, R3.5): the menu shows 3 frames after
// the press, complete in one frame; a chosen item blinks (off 4 frames, on 3), then the menu fades on CA default over
// 236 ms. The menu is glass that may leave the window: with the liquidglass plugin its own popup surface on the plugin's
// `menu` glass (`_glass`), else drawn flat in the window with the Mac's colour over a neutral window (FALLBACKS.md).
// Controlled: it shows `currentIndex` and emits activated(index); the caller owns the state.
Item {
    id: pop
    property var model: []          // array of strings
    property var dots: []           // optional paint per item: "" = none, a colour, or gradient stops left to right
    // the dot on the button and its gap to the text (the menu's dots stay 16): Firewall > Options' state dots are
    // 10 pt, 6 before the text (live/settings-r13/dest-network--firewall--options-dark.png: px 743..762, text from 774)
    property real dotSize: 16
    property real dotGap: 8
                                    // as [[position, colour], ...] (up to four; Automatic's NSMulticolorHighlight)
    property var separators: []     // indices of the rows a separator follows (the colour menus: [0] after Automatic)
    property int currentIndex: 0
    // bordered: the push fill always drawn, the value left-aligned 12 pt in and no circle around the chevron, for a
    // pop-up given a width (27.2.1 Desktop & Dock > Hot Corners…: 228 x 24, live/settings-r12/nav-desktopAndDock--hot-corners-dark.png)
    property bool bordered: false
    signal activated(int index)
    // the top of row i in the menu's column: rows above it and the separators between them
    function _rowTop(i: int): real {
        let y = i * Tokens.control.menuItemHeight;
        for (let k = 0; k < separators.length; k++) if (separators[k] < i) y += _sepHeight;
        return y;
    }
    readonly property real _sepHeight: 11
    readonly property real _rim: 0.5
    // hover: off from the menu's opening until the pointer has left the button
    property bool _hoverOff: false
    readonly property bool _down: ma.pressed || menu.visible || _opening || afterglow.running
    readonly property bool _bezel: enabled && (_down || ma.containsMouse && !_hoverOff)
    readonly property var _dot: dots.length > currentIndex && currentIndex >= 0 ? dots[currentIndex] : ""
    readonly property bool _hasDot: Array.isArray(_dot) || (_dot !== "" && _dot !== undefined)
    implicitHeight: Tokens.control.popupHeight
    implicitWidth: 12 + (_hasDot ? dotSize + dotGap : 0) + label.implicitWidth + 12 + Tokens.control.popupChevron + 3.5

    component Dot: Rectangle {
        property var paint: ""
        readonly property bool many: Array.isArray(paint)
        function stop(i) { return many ? paint[Math.min(i, paint.length - 1)] : [i / 3, "transparent"]; }
        radius: width / 2
        color: many || !paint ? "transparent" : paint
        gradient: many ? grad : null
        Rectangle {   // light: the outer half point is about 5 % darker (appearance-light.png: 206,144,162 against
            visible: !Tokens.dark   // 217,156,173 inside); dark has no rim
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 0.5; border.color: Qt.rgba(0, 0, 0, 0.055)
        }
        Gradient {
            id: grad
            orientation: Gradient.Horizontal
            GradientStop { position: stop(0)[0]; color: stop(0)[1] }
            GradientStop { position: stop(1)[0]; color: stop(1)[1] }
            GradientStop { position: stop(2)[0]; color: stop(2)[1] }
            GradientStop { position: stop(3)[0]; color: stop(3)[1] }
        }
    }

    Rectangle {   // the hover / pressed frame (see the header)
        objectName: "bezel"
        anchors.fill: parent
        visible: pop._bezel || pop.bordered
        radius: 6
        color: Tokens.control.pushFill
        Rectangle {
            anchors.fill: parent; radius: parent.radius
            visible: pop._down
            color: Tokens.dark ? Qt.rgba(1, 1, 1, 0.098) : Tokens.control.pressOverlay
        }
    }
    Dot {
        objectName: "dot"
        visible: pop._hasDot
        anchors.right: label.left; anchors.rightMargin: pop.dotGap; anchors.verticalCenter: parent.verticalCenter
        width: pop.dotSize; height: pop.dotSize
        paint: pop._dot
    }
    Text {
        id: label
        anchors.right: pop.bordered ? undefined : chev.left; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
        anchors.left: pop.bordered ? parent.left : undefined; anchors.leftMargin: 12
        text: pop.model.length > pop.currentIndex && pop.currentIndex >= 0 ? pop.model[pop.currentIndex] : ""
        font: Typography.control
        color: pop.enabled ? Tokens.label : Tokens.control.disabledText
    }
    Rectangle { // round chevron button
        id: chev
        anchors.right: parent.right; anchors.rightMargin: 3.5; anchors.verticalCenter: parent.verticalCenter
        width: Tokens.control.popupChevron; height: width; radius: width / 2
        // on the frame (hover, press) the circle is not drawn: the frame has its colour
        color: pop._bezel || pop.bordered ? "transparent" : Qt.alpha(Tokens.control.pushFill, Tokens.control.pushFill.a * (pop.enabled ? 1 : Tokens.control.disabledOpacity))
        SfSymbol {   // semibold, 10.25 pt: ink 15 x 21 px on appearance-{light,dark}.png, alpha rms 0.039 (10.0 and 10.5: 0.063)
            anchors.centerIn: parent; anchors.alignWhenCentered: false
            name: "chevron.up.chevron.down"; weight: "semibold"; pointSize: 10.25
            color: pop.enabled ? Tokens.label : Tokens.control.disabledText
        }
    }
    // NSPopUpButton: the menu opens on mouse-down; press-drag-release picks the item under
    // the pointer, a plain click leaves the menu open.
    property int _dragIndex: -1
    // R3.5 (popup-menu-open-close-{dark,light}.mov, 60 fps): the button's pressed look is on screen 3 (dark) and 4
    // (light) frames before the menu, which then shows complete in one frame. Counted in frames of this window
    // (FrameAnim as a pause, as MenuDropdown's blink: Tokens.panel.menuOpenDelay ends with the 3rd frame)
    // _opening keeps the pressed look from the press until the menu is up (a quick click is released at once; the
    // pause's last frame is not running any more)
    property bool _opening: false
    property bool _closing: false
    FrameAnim { id: openWait; from: 0; to: 1; duration: Tokens.panel.menuOpenDelay; onFinished: menu.open() }
    // Choosing an item: its highlight goes off for 4 frames and back on for 3 (R3.5, both clips; the menu bar's
    // Q-menubar-24 blink), then the value is sent and the menu fades. _blinkIndex holds the row till the menu is gone
    property int _blinkIndex: -1
    property bool _blinkOff: false
    function _choose(i: int): void {
        if (_blinkIndex >= 0) return;
        _blinkIndex = i;
        _blinkOff = true;
        blinkOffWait.start();
    }
    FrameAnim { id: blinkOffWait; from: 0; to: 1; duration: Tokens.panel.menuBlinkOff; onFinished: { pop._blinkOff = false; blinkOnWait.start(); } }
    FrameAnim {
        id: blinkOnWait; from: 0; to: 1; duration: Tokens.panel.menuBlinkOn
        onFinished: {
            if (pop._blinkIndex !== pop.currentIndex) pop.activated(pop._blinkIndex);
            if (!menu.opened) return;
            pop._fadeLead = 2;
            menu.close();
        }
    }
    // The close: the menu's opacity on the Mac's curve (CA default over Tokens.panel.menuFadeOut), one value per frame of
    // this window (FrameClock): frame k after the close shows the curve k + _fadeLead refresh intervals in.
    // Not Qt's exit Transition: its animation steps after each frame's sync, so the two frames built after the click
    // still had opacity 1 and the fade's first value reached the screen in the third (mcap + WAYLAND_DEBUG: click 1.0 ms,
    // commits at 2.3 and 17.0 unchanged, .95 committed at 33.1; best shift 58-63 ms, judge #19), against 26-30 ms for
    // Finder's menu, which the plugin fades from the event. A click outside (or Escape): lead 1, the first frame after
    // the click already moves. After the blink: lead 2, the Mac's fade shows .153 / .147 in the 7th frame after the
    // blink went off, the curve 1.9 frames in (R3.5; lead 1 would draw .055 there)
    property int _fadeLead: 1
    // With the liquidglass plugin (Tokens.popupGlass: Settings is in its popup_classes) the menu is a popup surface of
    // its own, as the Mac's menu window: it may leave the window (a colour menu near the window's bottom was cut off)
    // and the compositor draws the `menu` glass, its radius 12 and its shadow behind it, so the menu draws no fill
    // (Finder's PopupMenu, TextMenu). Closing is then the plugin's fade of the last frame and its glass, the same CA
    // default over 236 ms (plugin/src/PopupGlass.cpp); `afterglow` keeps the pressed look for that fade + 50 ms.
    // Without it (no plugin, Reduce Transparency, Increase Contrast): the in-window menu, drawn flat, and `fade` below
    readonly property bool _glass: Tokens.popupGlass && !Tokens.reduceTransparency && !Tokens.increaseContrast
    Timer { id: afterglow; interval: Tokens.panel.menuFadeOut + 50 }
    FrameClock {
        id: fade
        watchdog: true
        onTick: {
            const p = (elapsed + pop._fadeLead * interval) / Tokens.panel.menuFadeOut;
            if (p > 0.98) stop();   // a run of n frames must not take n + 1 for a rounding error (FrameAnim)
            menu.opacity = p > 0.98 ? 0 : 1 - Motion.bezierSpline(Tokens.panel.popoverFadeCurve, p);
        }
        onStalled: { stop(); menu.opacity = 0; }
    }
    MouseArea {
        id: ma; anchors.fill: parent; hoverEnabled: true
        property point pressAt
        property bool moved: false
        // the row under a point (-1 off the rows: outside, or on a separator)
        // (from the menu's geometry, not mapToItem: as its own popup surface the menu is another window's scene)
        function itemAt(m) {
            const p = Qt.point(m.x - menu.x - menu.padding, m.y - menu.y - menu.padding);
            if (p.x < 0 || p.x >= col.width || p.y < 0 || p.y >= col.height) return -1;
            for (let i = 0; i < pop.model.length; i++) {
                const t = pop._rowTop(i);
                if (p.y >= t && p.y < t + Tokens.control.menuItemHeight) return i;
            }
            return -1;
        }
        onContainsMouseChanged: if (!containsMouse && !menu.visible) pop._hoverOff = false
        // a press that reached the button with the menu up (`inMenu`): the menu came up under a held press and Hyprland
        // hands the pointer to its surface only when the pointer moves, so the next click of a pointer that did not move
        // (a touchpad tap) still comes here, over the menu's checked row (WAYLAND_DEBUG). It is a click in the menu, as
        // on the Mac: the row under it on release is chosen, off the rows the menu closes. It never restarts the open
        property bool inMenu: false
        onPressed: m => {
            pressAt = Qt.point(m.x, m.y); moved = false; pop._dragIndex = -1;
            inMenu = menu.opened;
            if (inMenu || pop._closing) return; // _closing: this press closed the open menu (Qt's press outside): it stays closed
            pop._opening = true;
            openWait.start();
        }
        onCanceled: inMenu = false
        onPositionChanged: m => {
            if (!pressed) return;
            if (Math.abs(m.x - pressAt.x) + Math.abs(m.y - pressAt.y) > 3) moved = true;
            if (menu.opened) pop._dragIndex = itemAt(m);   // the row under the held pointer lights (R3.8a open shots)
        }
        onReleased: m => {
            if (inMenu) {
                inMenu = false;
                const k = itemAt(m);
                if (k >= 0) pop._choose(k);
                else menu.close();
                return;
            }
            const i = moved ? itemAt(m) : -1;
            // a plain click leaves the menu open, the row under the pointer lit
            if (!moved) return;
            pop._dragIndex = -1;
            openWait.stop();                    // let go before the menu showed: it does not open
            pop._opening = false;
            if (i >= 0 && menu.opened) pop._choose(i);
            else menu.close();                  // released outside the menu
        }
    }

    C.Popup {
        id: menu
        objectName: "menu"
        y: -pop._rowTop(pop.currentIndex) - padding
        x: -12.5
        padding: Tokens.control.menuPadding + pop._rim
        width: Math.max(pop.width, col.widest + 2 * padding)
        popupType: pop._glass ? C.Popup.Window : C.Popup.Item
        // the fade runs on `fade` above; the exit only keeps the menu (and the button's pressed look) up while it runs:
        // the Mac's pressed look goes 33 (light) / 83 (dark) ms after the fade's last frame (R3.5), here 50 ms after
        // the curve's end. Qt puts the opacity back to 1 when the exit ends
        exit: Transition { PauseAnimation { duration: pop._glass ? 0 : Tokens.panel.menuFadeOut + 50 } }
        onAboutToHide: {
            if (pop._glass) afterglow.restart();
            else fade.start();
            pop._closing = true;
            Qt.callLater(() => pop._closing = false);
        }
        onAboutToShow: {
            pop._opening = false;
            pop._hoverOff = true;
            // the menu comes up under the pointer: its row is lit at once (R3.8a: Automatic lit 1 s into the hold, the
            // pointer not moved since the press), until the pointer moves over the rows. As a popup surface the menu
            // takes the pointer from the button (the press is cancelled), so a press-drag-release does not choose: the
            // menu stays up as after a click, as Finder's pull-downs
            const at = Qt.point(ma.mouseX, ma.mouseY);
            if (ma.pressed || ma.containsMouse) Qt.callLater(() => pop._dragIndex = ma.itemAt(at));
            fade.stop();
            afterglow.stop();
            blinkOffWait.stop();
            blinkOnWait.stop();
            pop._blinkIndex = -1;
            pop._blinkOff = false;
            pop._fadeLead = 1;
            opacity = 1;
        }
        // Over a neutral window the Mac's menu glass reads 249 light and (63,64,70) dark (R3.8a open shots, the rows
        // over the pane; Tokens.control.menuFill's #F6F6F6 / #2C2C2E were not measured), its rim the 0.5 pt outer line
        // (157 between 224 outside and 249 inside light: black a.33; 12 between 33 and 68 dark: black a.75). Shadow,
        // fitted on the light shot's left side (9.7 % at the rim, 6.5 % 7.5 pt out, 2.8 % at 18, 0.8 % at 30: a
        // Gaussian of sigma 17 pt and 0.2); dark keeps the same shadow (no reading over the dark window: 33 on 37)
        background: Item {
            visible: !pop._glass
            RectangularShadow {
                anchors.fill: parent
                radius: Tokens.control.menuRadius
                blur: 34
                color: Qt.rgba(0, 0, 0, 0.2)
            }
            Rectangle {
                anchors.fill: parent
                radius: Tokens.control.menuRadius
                color: Tokens.dark ? Qt.rgba(63 / 255, 64 / 255, 70 / 255, 1) : Qt.rgba(249 / 255, 249 / 255, 249 / 255, 1)
                border.width: pop._rim
                border.color: Tokens.dark ? Qt.rgba(0, 0, 0, 0.75) : Qt.rgba(0, 0, 0, 0.33)
            }
        }
        Column {
            id: col
            // the widest row's own need (a Column's implicitWidth follows the rows' width, which follows the menu's)
            readonly property real widest: { let w = 0; for (let i = 0; i < children.length; i++) w = Math.max(w, children[i].need || 0); return w; }
            Repeater {
                model: pop.model
                Column {
                    id: entry
                    required property int index
                    required property string modelData
                    readonly property real need: row.need
                    Rectangle {
                        id: row
                        readonly property int index: entry.index
                        width: menu.width - 2 * menu.padding; height: Tokens.control.menuItemHeight
                        radius: Tokens.control.menuHighlightRadius
                        readonly property real need: t.x + t.implicitWidth + 12
                        readonly property bool hot: pop._blinkIndex >= 0 ? pop._blinkIndex === index && !pop._blinkOff
                                                  : pop._dragIndex >= 0 ? pop._dragIndex === index : im.containsMouse
                        color: hot ? Tokens.accent : "transparent"
                        SfSymbol {   // semibold, 10.7 pt (alpha rms 0.076 on popup-menu-open-*.png), ink 8.1 .. 17.0 pt down;
                            // ink 8.5 pt into the highlight, 7.5 in a menu with dots (R3.8a: 193 / 191 px from 176)
                            x: pop.dots.length ? 7.5 : 8.5; y: (parent.height - height) / 2 + 0.5
                            visible: row.index === pop.currentIndex
                            name: "checkmark"; weight: "semibold"; pointSize: 10.7
                            color: row.hot ? "white" : Tokens.label
                        }
                        Dot {   // R3.8a: 16 pt (32 px) from 24 pt into the highlight, centred on the row
                            visible: pop.dots.length > 0
                            x: 24; anchors.verticalCenter: parent.verticalCenter
                            width: 16; height: 16
                            paint: pop.dots.length > row.index ? pop.dots[row.index] : ""
                        }
                        Text {
                            id: t
                            // ink 26.0 pt into the highlight ("Medium", popup-menu-open-*.png); with dots "Automatic" from
                            // 47 (R3.8a: 270 px from the highlight's 176, 7 pt after the dot)
                            x: pop.dots.length ? 47 : 25; anchors.verticalCenter: parent.verticalCenter
                            text: entry.modelData; font: Typography.menu
                            color: row.hot ? "white" : Tokens.label
                        }
                        MouseArea {
                            id: im; anchors.fill: parent; hoverEnabled: true
                            onContainsMouseChanged: if (containsMouse && !ma.pressed) pop._dragIndex = -1   // hover takes over
                            onClicked: pop._choose(row.index)
                        }
                    }
                    Item {   // R3.8a: the line 1 pt (2 px) at 5 pt into the 11, from 25 pt to 11 pt before the row's end;
                        // light 222 on 249 (black a.10), dark 95 on 65 (white a.14): the menus' separator (TextMenu)
                        visible: pop.separators.indexOf(entry.index) >= 0
                        width: row.width; height: visible ? pop._sepHeight : 0
                        Rectangle {
                            x: 25; y: 5; width: parent.width - 25 - 11; height: 1
                            color: Tokens.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.10)
                        }
                    }
                }
            }
        }
    }
}
