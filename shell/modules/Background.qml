import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services
import "../lib/menus.js" as Menus

// Desktop wallpaper on the background layer. The same image (blurred) is
// the backdrop of every glass surface, so both stay in sync.
ShellWindow {
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    color: Theme.dark ? "#1c1c1e" : "#3a6fb0"
    namespace: "hyprk-wallpaper"
    WlrLayershell.layer: WlrLayer.Background

    // desktop right-click: Finder desktop menu
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: m => Panels.openContext(Menus.desktop(), m.x, m.y, false, screen)
    }

    // Launchpad's first page of icons, decoded ahead (LaunchpadPreload.qml)
    LaunchpadPreload { screen: modelData }

    Image {
        id: wallImage
        z: -1
        anchors.fill: parent
        source: Wallpaper.url
        // decoded at the logical size: the wallpaper is soft, and at 4K/1.5 the full
        // pixel size costs ~18 MB more for no visible gain (PERF.md)
        sourceSize: Qt.size(screen ? screen.width : 1920, screen ? screen.height : 1080)   // known before layout
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
    }

    // Top-of-screen dimming of bright wallpaper pixels behind the menu bar (MAC-ANSWERS.md Q9.1,
    // shaders/topdim.frag). Static: the strip is re-rendered only when the wallpaper image changes.
    // Cost: one offscreen texture of screen width x 100 pt.
    ShaderEffectSource {
        id: topStrip
        sourceItem: wallImage
        sourceRect: Qt.rect(0, 0, wallImage.width, topDim.height)
        hideSource: false
        visible: false
    }
    ShaderEffect {
        id: topDim
        z: -1
        width: parent.width
        height: 100                    // measured: white is undimmed from about 100 pt down
        visible: wallImage.status === Image.Ready
        property var src: topStrip
        property rect srcRect: Qt.rect(0, 0, 1, 1)
        property size sizePt: Qt.size(width, height)
        property real topPt: 0
        property real radius: 0
        property real saturation: 1
        property real gain: 1
        fragmentShader: Qt.resolvedUrl("../shaders/topdim.frag.qsb")
    }
}
