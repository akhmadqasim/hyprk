import QtQuick
import QtQuick.Effects
import ".."

// Image clipped to a rounded rectangle (Rectangle.clip only clips to the bounding box).
Item {
    id: ri
    property string source
    // Local path; uses the freedesktop thumbnail when one exists (see scripts/thumbs.sh).
    property string path
    readonly property string thumb: path ? Backend.thumbFor(path) : ""
    property real radius: 8
    property int decodeWidth: 300
    // Bump after thumbnails were (re)generated to retry the thumbnail path.
    property int generation: 0
    onGenerationChanged: img.thumbFailed = false
    Image {
        id: img
        anchors.fill: parent
        property bool thumbFailed: false
        source: ri.path ? "file://" + (thumbFailed ? ri.path : ri.thumb) : ri.source
        onStatusChanged: if (status === Image.Error && ri.path && !thumbFailed) thumbFailed = true
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: ri.decodeWidth
        visible: false
    }
    Rectangle { id: mask; anchors.fill: parent; radius: ri.radius; visible: false; layer.enabled: true }
    MultiEffect {
        anchors.fill: parent
        source: img
        maskEnabled: true
        maskSource: mask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }
}
