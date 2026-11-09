import QtQuick
import QtQuick.Effects
import ".."

// Blurred, slightly desaturated wallpaper for the sidebar's left-rounded shape.
// The sidebar's own translucent tint is drawn on top of it.
Item {
    id: bd
    property real radius: 0
    Image {
        id: wall
        anchors.fill: parent
        visible: false
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: 256      // tiny decode: it is blurred anyway
        property string path: AppState.wallpaper || Backend.root + "/themes/wallpapers/png/DefaultAerial.png"
        property bool thumbFailed: false
        source: "file://" + (thumbFailed ? path : Backend.thumbFor(path))
        onStatusChanged: if (status === Image.Error && !thumbFailed) thumbFailed = true
        onPathChanged: thumbFailed = false
    }
    Rectangle {
        id: shape
        anchors.fill: parent
        visible: false
        layer.enabled: true
        topLeftRadius: bd.radius
        bottomLeftRadius: bd.radius
    }
    MultiEffect {
        anchors.fill: parent
        source: wall
        autoPaddingEnabled: false   // keep the blur inside the sidebar
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        saturation: -0.35
        maskEnabled: true
        maskSource: shape
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }
}
