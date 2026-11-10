import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs

// The menu bar battery as macOS 27.2.1 draws it. It is not an SF Symbol: BatteryUIKit
// -[BUIImage _modernBatteryImageForLevel:charging:pluggedIn:] draws a 26 x 14 pt bitmap
// (reference/re/MAC-ANSWERS.md R3b-2 "Battery (menu bar)", themes/icons/sf-symbols/svg/menubar-battery-level-*).
//  - body: rounded rect (0, 1, 23, 12), radius 4; track opacity 0.498 (light) / 0.549 (dark)
//  - fill: the same rounded rect cut at max(2, round(level x 23)) pt, opacity 0.847
//  - cap: nub at x 24, opacity 0.6
//  - charging: the bolt (battery-bolt) over a knockout of the body (battery-bolt-mask)
//  - low: the fill is red (#FF383C, from the 10 % bitmap) at 10 % and below while not charging
// Not drawn: plugged-in-and-full (plug glyph), low power mode (yellow), percent inside the body.
Item {
    id: root

    property real level: 1               // 0..1
    property bool charging: false
    property color color: Theme.color.menuBarText   // the glyph colour; its alpha scales every part
    readonly property bool onLightText: color.r > 0.5
    readonly property bool low: level <= 0.1 && !charging
    readonly property color fillColor: low ? "#FF383C" : color
    readonly property real fillWidth: Math.max(2, Math.round(Math.max(0, Math.min(1, level)) * 23))

    // layers are drawn at device pixels, or the edges come out coarse
    readonly property size tex: Qt.size(Math.ceil(26 * Screen.devicePixelRatio), Math.ceil(14 * Screen.devicePixelRatio))

    implicitWidth: 26
    implicitHeight: 14

    function svg(path, fill) {
        return "data:image/svg+xml;utf8," + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 11 14"><path d="'
            + path + '" fill="' + fill + '"/></svg>');
    }

    // the body (track + fill + cap) is one layer, so the bolt can knock a hole out of all of it
    Item {
        id: body
        anchors.fill: parent
        layer.enabled: root.charging
        layer.smooth: true
        layer.samples: 4
        layer.textureSize: root.tex
        layer.effect: MultiEffect {
            maskEnabled: true
            maskInverted: true
            maskSource: boltMask
        }

        Item {   // track and fill side by side, cut to the rounded body
            x: 0; y: 1; width: 23; height: 12
            layer.enabled: true
            layer.smooth: true
        layer.samples: 4
            layer.textureSize: Qt.size(Math.ceil(23 * Screen.devicePixelRatio), Math.ceil(12 * Screen.devicePixelRatio))
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: fillMask
            }
            Rectangle {
                x: root.fillWidth; width: parent.width - root.fillWidth; height: parent.height
                color: root.color
                opacity: root.onLightText ? 0.549 : 0.498
            }
            Rectangle {
                width: root.fillWidth; height: parent.height
                color: root.fillColor
                opacity: 0.847
            }
        }
        Shape {   // cap: a nub with a flat left side at x 24 (BatteryUIKit battery-cap)
            opacity: 0.6
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillColor: root.color
                strokeColor: "transparent"
                PathSvg { path: "M24 4.8828L24 9.1172C24.9102 8.7578 25.5 7.9258 25.5 7C25.5 6.0742 24.9102 5.2422 24 4.8828Z" }
            }
        }
    }
    // The masks are laid out at device pixels (dpr x the logical size): MultiEffect stretches a mask over the
    // item it masks and rasterises it at the mask item's own size, so a logical-size mask has octagon corners.
    readonly property real dpr: Screen.devicePixelRatio
    Rectangle {   // the rounded body the fill is cut to
        id: fillMask
        width: 23 * root.dpr; height: 12 * root.dpr; radius: 4 * root.dpr
        antialiasing: true
        visible: false
        layer.enabled: true
        layer.smooth: true
        layer.samples: 4
    }
    Item {        // the knockout around the bolt, over the whole 26 x 14 body
        id: boltMask
        width: 26 * root.dpr; height: 14 * root.dpr
        visible: false
        layer.enabled: true
        layer.smooth: true
        layer.samples: 4
        Image {
            x: 6.5 * root.dpr; width: 11 * root.dpr; height: 14 * root.dpr
            sourceSize: Qt.size(width, height)
            source: root.charging ? root.svg("M8.4766 2.0625L7.3906 4.9062L9.0234 4.9062C9.8398 4.9062 10.4766 5.5352 10.4766 6.3359C10.4766 6.7031 10.3438 7.0469 10.0859 7.3594L5.0664 13.3984L4.1016 14.5586L1.5273 14.5586L2.5234 11.9414L3.6094 9.0977L1.9766 9.0977C1.1641 9.0977 0.5234 8.4688 0.5234 7.668C0.5234 7.2969 0.6562 6.9531 0.9141 6.6406L5.9336 0.5977L6.9023 -0.5586L9.4727 -0.5586Z", "#000000") : ""
        }
    }
    Image {
        visible: root.charging
        x: 6.5; y: 0; width: 11; height: 14
        sourceSize: Qt.size(width * root.dpr, height * root.dpr)
        source: root.charging ? root.svg("M7.5234 1.7266L5.9219 5.9219L9 5.9219C9.2578 5.9219 9.4453 6.0938 9.4453 6.3398C9.4453 6.4688 9.3906 6.5898 9.2891 6.7148L4.3008 12.7188C3.8828 13.2188 3.2344 12.8906 3.4766 12.2695L5.0781 8.082L2 8.082C1.7422 8.082 1.5547 7.9062 1.5547 7.6641C1.5547 7.5273 1.6094 7.4102 1.7109 7.2852L6.6992 1.2812C7.1172 0.7773 7.7656 1.1133 7.5234 1.7266Z", Qt.rgba(root.color.r, root.color.g, root.color.b, 1).toString()) : ""
        opacity: root.color.a
    }
}
