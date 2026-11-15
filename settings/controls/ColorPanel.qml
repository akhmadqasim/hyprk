import QtQuick
import QtQuick.Effects
import ".."
import "../HyprK"

// The system Colors panel a colour well opens (27.2.1, MAC-ANSWERS-14.md R14.4, live/settings-r14/
// acc-display--colour-well-dark.png): 266 x 430. A title bar with three window buttons (9.5 pt, 17 apart, grey on the
// capture: the panel is not key) and the title; five mode pictures 44 apart (24 pt, the first on a 44 x 28 highlight);
// the colour wheel, 177.5 pt, with a cross-hair on the colour; the brightness capsule 226.5 x 23 with a 22 pt ring knob
// (full brightness at the left); a hairline; the colour's swatch 32 x 28, the eyedropper under it, and 4 x 10 empty
// 16 pt wells, 19 apart.
// On the Mac it is a floating window of its own. Here it is drawn inside the Settings window, at its left, and moves
// by its title bar within the window (a second window of the same class would be picked up by the session's window
// rules and by the minimize / zoom dispatchers of shell.qml; settings/FALLBACKS.md). Only the wheel is on the capture:
// the other four modes, the eyedropper and the wells take the press only. Only the dark look is on the capture.
// open(well): `well` needs a `value` colour; it is written while the panel is open for it. The first window button
// closes the panel.
Item {
    id: host
    visible: false; width: 0; height: 0
    property var well: null
    readonly property bool shown: panel.visible
    // the colour as the wheel holds it (hue and saturation survive a brightness of 0)
    property real hue: 0
    property real saturation: 0
    property real brightness: 1
    readonly property color value: Qt.hsva(hue, saturation, brightness, 1)
    signal closed()
    function open(w) {
        let p = host;
        while (p.parent) p = p.parent;
        if (panel.parent !== p) {
            panel.parent = p;
            panel.x = 8; panel.y = Math.max(8, p.height - panel.height - 8);
        }
        well = w;
        const c = w.value;
        hue = Math.max(0, c.hsvHue); saturation = c.hsvSaturation; brightness = c.hsvValue;
        panel.visible = true;
    }
    function close() { if (!panel.visible) return; panel.visible = false; well = null; closed(); }
    function _push() { if (well) well.value = value; }

    Rectangle {
        id: panel
        objectName: host.objectName !== "" ? host.objectName + "Panel" : "colorPanel"
        visible: false
        z: 900
        width: 266; height: 430; radius: 12
        color: "#1E1E1E"
        border.width: 0.5; border.color: Qt.rgba(1, 1, 1, 0.2)
        RectangularShadow { z: -1; anchors.fill: parent; radius: 12; blur: 40; offset.y: 12; color: Qt.rgba(0, 0, 0, 0.35) }
        MouseArea { anchors.fill: parent }   // nothing behind the panel takes its presses

        // ---------- title bar ----------
        MouseArea {
            width: parent.width; height: 24
            drag.target: panel
            drag.minimumX: 0; drag.maximumX: panel.parent ? Math.max(0, panel.parent.width - panel.width) : 0
            drag.minimumY: 0; drag.maximumY: panel.parent ? Math.max(0, panel.parent.height - panel.height) : 0
        }
        Repeater {
            model: 3
            Rectangle {
                required property int index
                objectName: index === 0 ? "colorPanelClose" : ""
                x: 8.25 + 17 * index; y: 8.25; width: 9.5; height: 9.5; radius: 4.75
                color: "#4C4C4E"
                MouseArea { anchors.fill: parent; anchors.margins: -2; enabled: parent.index === 0; onClicked: host.close() }
            }
        }
        Text {
            x: 61; y: 5; width: parent.width - 61 - 10; elide: Text.ElideRight
            text: "Colors"
            font: Typography.font(13, Typography.semibold); color: Qt.rgba(1, 1, 1, 0.32)
        }

        // ---------- modes ----------
        Rectangle { x: 23; y: 24; width: 44; height: 28; radius: 8; color: Qt.rgba(1, 1, 1, 0.07) }
        Repeater {
            model: ["wheel", "sliders", "palettes", "image", "pencils"]
            Image {
                required property string modelData
                required property int index
                objectName: "colorMode" + index
                x: 33 + 44 * index; y: 26; width: 24; height: 24
                source: "../assets/r14/colors-" + modelData + ".png"
            }
        }

        // ---------- wheel ----------
        Item {
            id: wheel
            objectName: "colorWheel"
            x: 43.75; y: 87.75; width: 177.5; height: 177.5
            Canvas {
                id: disc
                // painted once on the device's pixels, then laid on the 177.5 pt disc
                readonly property int px: Math.ceil(wheel.width * Math.max(1, Tokens.dpr > 0 ? Tokens.dpr : Screen.devicePixelRatio))
                width: px; height: px
                transformOrigin: Item.TopLeft
                scale: wheel.width / px
            onPaint: {
                const ctx = getContext("2d");
                const n = px, r = n / 2, img = ctx.createImageData(n, n), d = img.data;
                for (let y = 0; y < n; y++) {
                    for (let x = 0; x < n; x++) {
                        const dx = x + 0.5 - r, dy = r - (y + 0.5), rr = Math.sqrt(dx * dx + dy * dy);
                        const i = (y * n + x) * 4;
                        if (rr > r + 0.5) { d[i + 3] = 0; continue; }
                        let h = Math.atan2(dy, dx) / (2 * Math.PI);
                        if (h < 0) h += 1;
                        const s = Math.min(1, rr / r), k = h * 6, f = k - Math.floor(k), q = 1 - s, t = 1 - s * (1 - f), u = 1 - s * f;
                        const c = [[1, t, q], [u, 1, q], [q, 1, t], [q, u, 1], [t, q, 1], [1, q, u]][Math.floor(k) % 6];
                        d[i] = c[0] * 255; d[i + 1] = c[1] * 255; d[i + 2] = c[2] * 255;
                        d[i + 3] = Math.max(0, Math.min(1, r + 0.5 - rr)) * 255;
                    }
                }
                ctx.drawImage(img, 0, 0);
            }
            }
            // the wheel darkens with the brightness
            Rectangle { anchors.fill: parent; radius: width / 2; color: "black"; opacity: 1 - host.brightness }
            Item {   // the cross-hair: a 13 pt ring with four ticks
                objectName: "colorCross"
                x: wheel.width / 2 + Math.cos(host.hue * 2 * Math.PI) * host.saturation * wheel.width / 2 - width / 2
                y: wheel.height / 2 - Math.sin(host.hue * 2 * Math.PI) * host.saturation * wheel.height / 2 - height / 2
                width: 15; height: 15
                Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: "transparent"; border.width: 1; border.color: Qt.rgba(0, 0, 0, 0.7) }
                Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 1; height: 15; color: Qt.rgba(0, 0, 0, 0.7) }
                Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 15; height: 1; color: Qt.rgba(0, 0, 0, 0.7) }
            }
            MouseArea {
                anchors.fill: parent
                function pick(mx, my) {
                    const dx = mx - width / 2, dy = height / 2 - my, r = width / 2;
                    let h = Math.atan2(dy, dx) / (2 * Math.PI);
                    if (h < 0) h += 1;
                    host.hue = h; host.saturation = Math.min(1, Math.sqrt(dx * dx + dy * dy) / r);
                    host._push();
                }
                onPressed: mouse => { const dx = mouse.x - width / 2, dy = mouse.y - height / 2; if (dx * dx + dy * dy > width * width / 4) mouse.accepted = false; else pick(mouse.x, mouse.y); }
                onPositionChanged: mouse => { if (pressed) pick(mouse.x, mouse.y); }
            }
        }

        // ---------- brightness ----------
        Rectangle {
            id: track
            objectName: "colorBrightness"
            x: 20; y: 286.5; width: 226.5; height: 23; radius: 11.5
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Qt.hsva(host.hue, host.saturation, 1, 1) }
                GradientStop { position: 1; color: "black" }
            }
            Rectangle {
                x: (1 - host.brightness) * (track.width - width); y: 0.5; width: 22; height: 22; radius: 11
                color: "transparent"; border.width: 2.5; border.color: "white"
                Rectangle { anchors.fill: parent; anchors.margins: -0.5; radius: width / 2; color: "transparent"; border.width: 0.5; border.color: Qt.rgba(0, 0, 0, 0.35) }
            }
            MouseArea {
                anchors.fill: parent
                function pick(mx) { host.brightness = 1 - Math.max(0, Math.min(1, (mx - 11) / (width - 22))); host._push(); }
                onPressed: mouse => pick(mouse.x)
                onPositionChanged: mouse => { if (pressed) pick(mouse.x); }
            }
        }
        Rectangle { x: 20; y: 321; width: 226; height: 1; color: Qt.rgba(1, 1, 1, 0.1) }

        // ---------- swatch, eyedropper, wells ----------
        Rectangle { objectName: "colorSwatch"; x: 20; y: 333; width: 32; height: 28; radius: 6; color: host.value }
        Image { x: 25; y: 369; width: 21; height: 20; source: "../assets/r14/eyedropper-dark.png" }
        Repeater {
            model: 40
            Rectangle {
                required property int index
                x: 57.5 + 19 * (index % 10); y: 334 + 19 * Math.floor(index / 10); width: 16; height: 16; radius: 4
                color: "transparent"; border.width: 1; border.color: Qt.rgba(1, 1, 1, 0.22)
            }
        }
    }
}
