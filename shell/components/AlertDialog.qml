import QtQuick
import Quickshell.Widgets
import qs
import qs.HyprK
import qs.services
import "../HyprK/panels.js" as P

// macOS-style alert: regular glass (Theme.alert.radius), icon, bold title and message left-aligned,
// capsule buttons (layout below). Model: { icon, title, message, buttons: [{ label, action, isDefault, isCancel }] }.
// Enter runs the default button, Escape the cancel button.
// Motion as AppKit 27.2.1 runs it (Theme.alert, HyprK panels.js; re/27.2.1/MOTION-AUDIT.md "Alert, Round R3.1"):
// appears with PopIn, 0.4 s of linear progress v: glass and content at v, scale from the centre 1 % -> 1.2 at 0.24 s
// -> 1; the Cancel button (Esc) dismisses with a 0.25 s spring to alpha 0 and scale 0.98, any other button hides it
// at once. Reduce motion: dissolve in, no scale.
Item {
    id: root

    property bool shown: false
    property real fade: 0   // glass materialize and content opacity
    property real pop: 1    // scale around the centre
    property real appear: 1 // PopIn progress v (linear)
    property real outMs: 0  // ms into the Cancel order-out
    // Cancel's whole-window blur, pt (Theme.alert.cancelBlur x p): the content by a layer effect, the glass by the plugin
    // (the host ShellWindow's glassSoften; its glassShadowSize follows `pop`, Overlay.qml)
    property real soften: 0
    // the host fades its glass with `fade` as a window alpha (ShellWindow.glassOpacity, Overlay.qml): the glass then stays
    // at full material. Without it the glass materializes with `fade`
    property bool windowAlpha: false
    property bool _cancel: false   // the button that closes it is the cancel one
    property bool _outActive: false
    property real _fade0: 1
    property real _pop0: 1
    visible: shown || fade > 0
    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.pop
        yScale: root.pop
        // the glass region does not follow transforms: re-measure it while the alert scales. From the Scale's own
        // change, not root's onPopChanged: that handler ran before this binding, so Glass measured the last frame's
        // scale and the glass drew one frame behind the content (mcap: glass .59 .72 .86 1.0 under content .71 .84
        // 1.0 1.15, the buttons past its edge from 165 to 265 ms, JUDGE-95-17 3f)
        onYScaleChanged: Tokens.glassStepped(root)
    }
    // one value per frame of the window (HyprK FrameAnim): PopIn's progress, scale and alpha follow it in the same frame
    FrameAnim { id: popIn; target: root; property: "appear"; from: 0; to: 1; duration: Theme.alert.popIn }
    onAppearChanged: {   // only popIn moves it
        pop = P.alertPopScale(appear, Theme.alert.popAmount);
        fade = appear;
    }
    // Cancel: ScaleDownAndOut from the alpha and size it has (dismissed mid-pop: no jump)
    FrameAnim {
        id: cancelOut
        target: root; property: "outMs"; from: 0; to: Theme.alert.cancelOut; duration: Theme.alert.cancelOut
        onFinished: { root._outActive = false; root.fade = 0; root.soften = 0; }
    }
    // FrameAnim shows frame k at (k + 1) frames; the spring is read at (k + cancelPhase) frames (Theme.alert.cancelPhase)
    readonly property real _frameMs: 1000 / (Screen.refreshRate > 0 ? Screen.refreshRate : 60)
    onOutMsChanged: {
        if (!_outActive) return;
        const ms = outMs - (1 - Theme.alert.cancelPhase) * _frameMs;
        const p = outMs >= Theme.alert.cancelOut ? 1 : P.alertCancelProgress(ms, Theme.alert.cancelDuration, Theme.alert.cancelVelocity);
        fade = _fade0 * (1 - p);
        if (!A11y.reduceMotion) {
            pop = _pop0 * (1 - (1 - Theme.alert.cancelScale) * p);
            soften = Theme.alert.cancelBlur * p;
        }
    }
    FrameAnim { id: fadeIn; target: root; property: "fade"; to: 1; duration: 150 }   // Reduce motion dissolve
    Component.onCompleted: if (shown) fade = 1

    property var model: null
    property real originX: 0
    property real originY: 0
    readonly property var buttons: model && model.buttons ? model.buttons : [{ label: "OK", isDefault: true }]
    // the layout's order: the default first (P.alertLayout: 2 side by side with it on the right, 3 stacked default,
    // third, second), the others as given
    readonly property var ordered: {
        const d = buttons.findIndex(b => b.isDefault);
        return d < 0 ? buttons : [buttons[d]].concat(buttons.filter((b, i) => i !== d));
    }
    readonly property bool hasIcon: !!(model && model.icon)
    // NSAlert on macOS 27.2.1, the Empty Trash alert itself (re/27.2.1/live/panels/panels-alert2-dark.json frames,
    // screens/27.2.1/panels/alert-{dark,light}.png; MAC-ANSWERS Q-panels-33): 260 wide, 64 pt icon at (20, 20),
    // bold 13 title and regular 13 message left-aligned in 220 pt, 110 x 28 capsules 16 pt from the edges. The same
    // layout as the apps' AlertPanel (HyprK panels.js). Before: everything centred, buttons sharing the width
    readonly property var layout: P.alertLayout(ordered.length, hasIcon, titleText.implicitHeight,
                                                messageText.text !== "" ? messageText.implicitHeight : 0)
    width: layout.width
    height: layout.height

    function press(b) {
        // NSAlert runModal: the Cancel button orders out with ScaleDownAndOut, every other way out with none
        root._cancel = !!(b && b.isCancel);
        Panels.close();
        if (b && typeof b.action === "function") b.action();
    }
    function pressDefault() { press(buttons.find(b => b.isDefault) || buttons[buttons.length - 1]); }
    function pressCancel() { press(buttons.find(b => b.isCancel) || null); }

    // keyboard: Return/Enter = default button, Escape = cancel
    focus: shown
    onShownChanged: {
        if (shown) {
            _outActive = false;
            cancelOut.stop();
            soften = 0;
            _cancel = false;
            if (A11y.reduceMotion) {
                pop = 1;
                fadeIn.restart();
            } else {
                popIn.restart();   // sets v = 0 first: alpha 0 at 1 %, no full-size frame
            }
            Qt.callLater(forceActiveFocus);   // after `visible` follows
        } else {
            fadeIn.stop();
            popIn.stop();
            if (_cancel) {
                _fade0 = fade;
                _pop0 = pop;
                _outActive = true;
                cancelOut.restart();
            } else {
                fade = 0;   // order-out type 2: no animation
                pop = 1;
                soften = 0;
            }
            _cancel = false;
        }
    }
    Keys.onEscapePressed: pressCancel()
    Keys.onReturnPressed: pressDefault()
    Keys.onEnterPressed: pressDefault()

    // regular glass, r 26 (LIVE-27.2.1: Alert = regular; the plugin's hyprk-overlay recipe is regular + the menu
    // shadow). No tint of our own: tintStrong only reached the QML fallback
    Glass {
        anchors.fill: parent
        radius: Theme.alert.radius
        sx: root.originX
        sy: root.originY
        tint: Theme.glass.tintStrong
        materialize: root.windowAlpha ? 1 : root.fade
    }
    MouseArea { anchors.fill: parent }

    Item {
        anchors.fill: parent
        opacity: root.fade
        enabled: root.shown
        // Cancel's blur on the text, icon and buttons (the glass gets it from the plugin). Switched on with the order-out,
        // before its first frame (an effect created by the first blur value shows one empty frame: Spotlight.qml); at rest
        // no layer, so the still is drawn as before. `soften` is a Gaussian sigma in pt (the Mac's dismiss frame: text
        // sigma 0.80 pt at alpha .83, 5 p = 0.78), drawn as one: two passes of shaders/gausspass.frag. MultiEffect's blur
        // (r = 4 sigma before) mixes pre-blurred levels; fitted as a Gaussian its first frame read 1.15 pt dark and 1.75
        // light for the same value, the text at .64 of its alpha in dark
        layer.enabled: root._outActive && !A11y.reduceMotion
        layer.smooth: true
        layer.effect: Item {
            id: blurFx
            property var source
            ShaderEffect {
                id: blurX
                anchors.fill: parent
                visible: false
                layer.enabled: true
                layer.smooth: true
                property var source: blurFx.source
                property vector2d delta: Qt.vector2d(root.soften / Math.max(1, width), 0)
                fragmentShader: Qt.resolvedUrl("../shaders/gausspass.frag.qsb")
            }
            ShaderEffect {
                anchors.fill: parent
                property var source: blurX
                property vector2d delta: Qt.vector2d(0, root.soften / Math.max(1, height))
                fragmentShader: Qt.resolvedUrl("../shaders/gausspass.frag.qsb")
            }
        }

        IconImage {
            visible: !!root.layout.icon
            x: visible ? root.layout.icon.x : 0
            y: visible ? root.layout.icon.y : 0
            implicitSize: P.alert.icon
            source: root.hasIcon ? Apps.iconUrl(root.model.icon, "", Theme.iconLook) : ""
            mipmap: true
        }
        Text {
            id: titleText
            x: root.layout.title.x
            y: root.layout.title.y
            width: P.alert.textWidth
            wrapMode: Text.Wrap
            text: root.model ? root.model.title : ""
            // Bold 13 (".SFNS-Bold 13.0" in the dump) = the headline style, real Bold on the wght axis (Typography)
            font: Typography.headline
            color: Theme.color.label
        }
        Text {
            id: messageText
            visible: text !== ""
            x: P.alert.padding
            y: root.layout.message ? root.layout.message.y : 0
            width: P.alert.textWidth
            wrapMode: Text.Wrap
            text: root.model && root.model.message ? root.model.message : ""
            font: Typography.message   // ".SFNS-Regular 13.0"
            color: Theme.color.label
        }
        Repeater {
            model: root.ordered
            delegate: Rectangle {
                id: btn
                required property var modelData
                required property int index
                readonly property var r: root.layout.buttons[index] || { x: 0, y: 0, width: 0, height: 0 }
                x: r.x; y: r.y; width: r.width; height: r.height
                radius: height / 2
                color: modelData.isDefault ? Tokens.panel.defaultFill : Theme.alert.buttonBg
                // pressed: one more layer, instant (Q-panels-33: 71 -> 89 in dark; Q-settings-15: black a .098)
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    visible: bma.pressed && bma.containsMouse
                    color: Theme.alert.buttonPressed
                }
                Text {
                    anchors.centerIn: parent
                    width: parent.width - 16
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: btn.modelData.label
                    font: Typography.body   // 13 regular, the default too (Q-panels-33)
                    color: btn.modelData.isDefault ? Theme.color.textOnAccent : Theme.color.label
                }
                MouseArea { id: bma; anchors.fill: parent; onClicked: root.press(btn.modelData) }
            }
        }
    }
}
