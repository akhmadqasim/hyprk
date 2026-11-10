import QtQuick
import qs
import qs.services

// The distro logo as a single-colour glyph (what the Apple logo is on macOS).
// The icon theme's logo is used as a mask tinted with `color`; when the theme
// has none (or shaders cannot run), the bundled generic mark from symbols.js is drawn instead.
Item {
    id: root

    property real size: 16
    property color color: Theme.color.label
    property var logo: Distro.logo
    // software renderer or shader load error: the generic mark instead
    readonly property bool noShader: GraphicsInfo.api === GraphicsInfo.Software || fx.status === ShaderEffect.Error

    implicitWidth: size
    implicitHeight: size

    Symbol {
        visible: Distro.scanned && (!root.logo || root.noShader)
        anchors.centerIn: parent
        name: "distro"
        size: root.size
        color: root.color
    }

    Image {
        id: img
        visible: false
        width: root.size
        height: root.size
        source: root.logo ? root.logo.source : ""
        sourceSize: Qt.size(Math.ceil(root.size * 4), Math.ceil(root.size * 4))
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
        mipmap: true
    }
    ShaderEffect {
        id: fx
        visible: root.logo !== null && img.status === Image.Ready && !root.noShader
        anchors.fill: img
        property var src: img
        property color tint: root.color
        fragmentShader: Qt.resolvedUrl("../shaders/logomask.frag.qsb")
    }
}
