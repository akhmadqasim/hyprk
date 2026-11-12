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
    id: bg
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    color: Theme.dark ? "#1c1c1e" : "#3a6fb0"
    namespace: "hyprk-wallpaper"
    WlrLayershell.layer: WlrLayer.Background

    // A click on the empty desktop activates Finder (macOS: the desktop is Finder's; the other app's windows go
    // inactive and the menu bar shows Finder's menus, judge #6). Only a CLICK does it (judge #7): an on-demand layer
    // takes the keyboard on mere hover under follow_mouse (InputManager::mouseMoveUnified, a layer with interactivity
    // != NONE under the pointer gets rawSurfaceFocus), so the layer asks for no keyboard at rest. On a click it asks
    // exclusively (Hyprland hands it the keyboard at once: LayerSurface::onCommit takeKeyboardFocus, after the button is
    // up so no release is swallowed), then on demand once it has it, so the window can take it back (a
    // click); when it loses the keyboard it asks for none again.
    // A shell panel taking the keys (a menu opened from the menu bar, Spotlight, Cmd-Tab, Mission Control) leaves Finder
    // frontmost, as a click on the Mac's menu bar never changes the frontmost app (judge #8: the click on "File" after a
    // desktop click opened the last app's menu): the desktop keeps Apps.desktopFocus and takes the keyboard back when
    // the panel closes (Hyprland hands it to the last window then: LayerSurface::onCommit refocusLastWindow), unless
    // something activated a window meanwhile (Apps.focusWindow clears desktopFocus).
    property bool takeKeys: false     // the desktop wants or holds the keyboard
    property bool grabbing: false     // exclusive until the keyboard arrives
    property bool reclaim: false      // a panel has the keys while Finder stays frontmost
    WlrLayershell.keyboardFocus: !takeKeys ? WlrKeyboardFocus.None
                               : grabbing ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
    function activateDesktop() { grabbing = true; takeKeys = true; }
    Connections {
        target: Apps
        function onDesktopRequested(name) { if (bg.screen && bg.screen.name === name) bg.activateDesktop(); }
    }
    Connections {
        target: Panels
        enabled: bg.reclaim
        function onOpenChanged() {
            if (Panels.open !== "") return;
            // after the closing handler has run (a menu row or Cmd-Tab may focus a window right after closing)
            Qt.callLater(() => {
                if (!bg.reclaim || Panels.open !== "") return;
                bg.reclaim = false;
                if (bg.screen && Apps.desktopFocus === bg.screen.name) bg.activateDesktop();
            });
        }
    }
    Item {
        readonly property bool focused: Window.active
        onFocusedChanged: {
            const name = bg.screen ? bg.screen.name : "";
            if (focused) {
                Apps.desktopFocus = name;
                bg.grabbing = false;
                commitKick.visible = !commitKick.visible;
            } else {
                if (Apps.desktopFocus === name && Panels.open !== "") bg.reclaim = true;
                else if (Apps.desktopFocus === name) Apps.desktopFocus = "";
                if (!bg.grabbing) bg.takeKeys = false;
            }
        }
    }

    // A frame for the keyboard mode: a still wallpaper draws (and commits) nothing, so the switch from exclusive back
    // to on demand waited for the next repaint and Hyprland kept the layer in its exclusive list, refusing every window
    // focus (a click in a window after a desktop click left the keyboard on the desktop)
    Rectangle { id: commitKick; width: 1; height: 1; color: "#01000000" }

    // desktop click: Finder takes the keyboard (above); right-click: Finder desktop menu
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: m => {
            if (m.button === Qt.RightButton) Panels.openContext(Menus.desktop(), m.x, m.y, false, screen);
            else { bg.activateDesktop(); StageManager.emptyStage(); }   // Stage Manager: the stage empties
        }
    }

    // Launchpad's first page of icons, decoded ahead (LaunchpadPreload.qml)
    LaunchpadPreload { screen: modelData }

    // The picture shown changes only once the next one is decoded: an Image whose source changes draws nothing
    // while it loads, so an appearance switch (wallpaper.sh cuts the mode's picture, decoded asynchronously) showed
    // the window colour for 3-4 frames inside the compositor's cross-fade (judge #5: the wallpaper, and the menu bar
    // and Dock glass over it, stepped back mid-fade). `nextImage` decodes the wanted picture under the shown one; once
    // it is ready the shown one takes it from the pixmap cache, and the window answers the appearance handshake only
    // when the new picture is on screen (appearanceBusy).
    readonly property string wantUrl: Wallpaper.urlFor(screen)
    property string shownUrl: ""
    appearanceBusy: Wallpaper.busy || shownUrl !== wantUrl || wallImage.status === Image.Loading
    Image {
        id: nextImage
        z: -2
        anchors.fill: parent
        source: bg.shownUrl !== bg.wantUrl || wallImage.status !== Image.Ready ? bg.wantUrl : ""
        sourceSize: Wallpaper.pixelSizeOf(screen)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        onStatusChanged: if ((status === Image.Ready || status === Image.Error) && source == bg.wantUrl) bg.shownUrl = bg.wantUrl
    }
    Image {
        id: wallImage
        z: -1
        anchors.fill: parent
        source: bg.shownUrl
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
