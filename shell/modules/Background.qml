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
        source: Wallpaper.urlFor(screen)
        // decoded at this output's pixel size (the size wallpaper.sh cuts it to, per distinct screen size), shown
        // 1:1: at the logical size a 2x output upscaled it and 4 pt stripes had 4 px ramps (0 7 20 77 177 234 248
        // 255), so the glass sampled a softer backdrop than the Mac's. Costs 4 bytes per pixel more (PERF.md)
        sourceSize: Wallpaper.pixelSizeOf(screen)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true   // one decoded copy, shared with Mission Control's backdrop (same url and sourceSize)
    }

    // Contrast gradient over the top 100 pt behind the menu bar (MAC-ANSWERS.md Q-menubar-02,
    // shaders/topdim.frag): pushes the wallpaper away from the bar's text colour. Static: the strip is
    // re-rendered only when the wallpaper image or the text colour changes. Cost: one offscreen texture of
    // screen width x 100 pt.
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
        height: 100   // strength 0 by y 100 pt (measured)
        visible: wallImage.status === Image.Ready
        property var src: topStrip
        property real lightText: Theme.menuBarLight ? 0 : 1
        property real heightPt: height
        fragmentShader: Qt.resolvedUrl("../shaders/topdim.frag.qsb")
    }
}
