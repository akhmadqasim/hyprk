import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/dockstack.js" as Stack
import "../HyprK/motion.js" as Motion

// The Downloads stack's popup, as macOS 27.2.1's Dock opens it on a click (reference/re/27.2.1/MOTION-REA-27.2.1.md
// section 3, GAPS-REA-dock.md section 4, MAC-ANSWERS.md Q-dock-12; layout math in lib/dockstack.js, metrics in
// Theme.dock.stack). Created by Dock.qml (a LazyLoader) for one open and gone after its close.
//   Fan: the items rise from the tile along a 3000 pt circle, newest at the bottom, each 64 pt, with its name in a glass
//        pill to its left; the top slot "Open in Finder" or "N More in Finder".
//   Grid: a glass bubble with a tail at the tile, the folder's name on top, 128 pt cells, the last "Open in Finder";
//        more cells than the stage holds scroll.
// A click on an item opens it (a folder in our Finder, a file with xdg-open, like Spotlight's files); a click anywhere
// else or Esc closes it. Motion: fan, every item along its arc at once (no stagger), the position ease-in-out, the
// turn on CA's default curve, the size 64 all through the open and shrinking on "default" in the close (measured,
// MOTION-REA Round 4), the label's scale ease-in-out and its opacity linear; grid, a zoom out of
// the tile's centre with the opacity, CA's default curve. Both 0.25 s, the CATransaction default (MOTION-REA Round 3).
// Reduce Motion: shown and hidden at once (both animators, axReduceMotion). Glass: on the plugin the namespace of the
// Dock's hover label (hyprk-dock-label, Apple's Regular recipe, the cartouche's material: the label and the grid bubble
// are both ECCartoucheGlassLayerController); without it the QML glass, with Reduce Transparency the solid material.
// Differences from the Mac, known: the plugin draws the grid's tail at the hover label's size (16 pt square, Mac 24),
// the fallback draws the decoded 24 pt one; fan labels stay level (a glass region cannot turn), the Mac turns them with
// their item; no hover highlight, no drag out of the stack, no keyboard selection.
ShellWindow {
    id: win

    required property var host            // the Dock window
    required property string view          // "fan" | "grid"
    required property var files            // [{path, name, dir, image, zip}], in the stack's order (newest first)
    required property string title
    required property bool folderMode      // Display as Folder (the close fades every item)
    required property real tile
    required property real tileCX          // the tile's centre, this screen's x
    required property real tileBottom      // the tile's bottom edge, this screen's y
    required property real dockTop         // the Dock background's top edge
    required property bool magnification
    required property var stageSize        // lib/dockstack.js stage
    property bool open: false
    signal stackDone()

    screen: host.screen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-dock-label"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    acceptsInput: open

    // the window's ratio (the screen's says 2 on a 1.6 output: SCALING-AUDIT.md)
    readonly property real dpr: devicePixelRatio > 0 ? devicePixelRatio : screen && screen.devicePixelRatio > 0 ? screen.devicePixelRatio : 1
    readonly property bool fan: view === "fan"
    readonly property int duration: Theme.dock.stack.duration

    // ---------- motion ----------
    // `ms` runs 0 -> duration on open and 0 -> duration + 50 on close (the fan's last fade ends 0.05 s after the
    // move); `p` is the eased position, 0 = in the tile, 1 = in place
    property real ms: 0
    property bool closing: false
    readonly property real t: Math.max(0, Math.min(1, ms / duration))
    readonly property real eased: fan ? Motion.bezierSpline([0.42, 0, 0.58, 1, 1, 1], t)     // kCAMediaTimingFunctionEaseInEaseOut
                                      : Motion.bezierSpline(Theme.dock.stack.gridCurve, t)
    readonly property real p: closing ? 1 - eased : eased
    // the fan's other parts on their own curves (lib/dockstack.js fanChannels: the rotation and the item size are
    // implicit animations on CA's "default" curve, the label's opacity is linear, its scale ease-in-out like `p`)
    readonly property var ch: Stack.fanChannels(ms, duration, closing)
    FrameAnim {
        id: clock
        target: win
        property: "ms"
        from: 0
        ease: Easing.Linear
        settlesGlass: true
        onFinished: if (win.closing) win.stackDone()
    }
    function play(closeIt) {
        closing = closeIt;
        clock.stop();
        if (A11y.reduceMotion) {
            ms = duration + 50;
            if (closeIt) Qt.callLater(win.stackDone);
            return;
        }
        clock.to = duration + (closeIt ? 50 : 0);
        clock.duration = clock.to;
        clock.start();
        win.settleGlass(clock.duration + 80);
    }
    onOpenChanged: play(!open)
    // the open starts on the window's first frame: started at creation, its frame clock had no frames until the
    // surface was mapped and the watchdog jumped it to the end (the grid showed at once)
    property bool drawn: false
    Connections {
        target: drawnProbe.Window.window
        enabled: !win.drawn
        function onFrameSwapped() { win.drawn = true; if (win.open) win.play(false); }
    }
    Item { id: drawnProbe }

    function activate(f) {
        Panels.close();
        if (!f || f.finder) Apps.openFinder(Quickshell.env("HOME") + "/Downloads");
        else if (f.dir) Apps.openFinder(f.path);
        else Quickshell.execDetached(["xdg-open", f.path]);
    }

    // a click outside the items closes; Esc too
    MouseArea {
        anchors.fill: parent
        onPressed: Panels.close()
    }
    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: Panels.close()
    }

    // ---------- fan ----------
    readonly property var fanSlots: {
        if (!fan) return [];
        const s = Stack.fanSlots(files.length, stageSize.h);
        return files.slice(0, s.items).concat([{ finder: true, name: s.extra }]);
    }
    readonly property real fanHalf: Theme.dock.stack.fanItem / 2
    Repeater {
        model: win.fanSlots
        Item {
            id: fanItem
            required property var modelData
            required property int index
            readonly property var at: Stack.fanAt(win.tile, index, win.p, win.ch.turn)
            width: Theme.dock.stack.fanItem
            height: width
            x: win.tileCX + at.dx - win.fanHalf
            y: win.tileBottom - at.up - win.fanHalf
            rotation: at.angle
            // 64 at rest, from the pile's size while it opens and closes (lib/dockstack.js fanSize): drawn as a scale
            // of the 64 box so the art is not re-rendered every frame
            scale: Stack.fanSize(win.tile, index, win.ch.size) / Theme.dock.stack.fanItem
            opacity: win.closing ? Stack.fanCloseOpacity(index, win.ms, win.duration, win.folderMode) : 1
            StackArt {
                file: fanItem.modelData
                size: parent.width
                dpr: win.dpr
            }
            MouseArea {
                anchors.fill: parent
                enabled: win.open
                onClicked: win.activate(fanItem.modelData)
            }
        }
    }
    // the labels, level: the item's left-centre turned with it, then 5 pt further out along the item's x axis
    Repeater {
        model: win.fanSlots
        Glass {
            id: pill
            required property var modelData
            required property int index
            readonly property var at: Stack.fanAt(win.tile, index, win.p, win.ch.turn)
            readonly property real reach: Stack.fanSize(win.tile, index, win.ch.size) / 2 + Theme.dock.stack.fanLabelGap
            readonly property real ax: win.tileCX + at.dx - reach * Math.cos(at.angle * Math.PI / 180)
            readonly property real ay: win.tileBottom - at.up - reach * Math.sin(at.angle * Math.PI / 180)
            readonly property real grow: Math.max(1e-5, win.ch.labelScale)     // label scale 1e-5 -> 1 (0x100258060)
            width: Stack.fanLabelWidth(pillText.implicitWidth)
            height: Theme.dock.stack.fanLabelHeight
            x: Math.round(ax - width)
            y: Math.round(ay - height / 2)
            transformOrigin: Item.Right
            scale: grow
            radius: height / 2
            sx: x
            sy: y
            tint: Theme.glass.tintClear
            solidColor: Theme.glass.solidDock
            pluginLift: "transparent"
            shadow: false
            // its own scale (= p): Glass reads materialize while it registers, before the delegate can see `win`, and a
            // binding that failed there would never re-run
            materialize: scale
            // the whole label (textBackgroundLayer) fades linearly over the transaction, on top of the item's own fade
            opacity: win.ch.labelOpacity * (win.closing ? Stack.fanCloseOpacity(index, win.ms, win.duration, win.folderMode) : 1)
            Text {
                id: pillText
                anchors.centerIn: parent
                width: Math.min(implicitWidth, 500)
                elide: Text.ElideMiddle
                text: pill.modelData.name || ""
                font: Typography.font(Theme.dock.stack.itemFont)
                color: Theme.dock.labelText
            }
            MouseArea {
                anchors.fill: parent
                enabled: win.open
                onClicked: win.activate(pill.modelData)
            }
        }
    }

    // ---------- grid ----------
    readonly property var gridCells: fan ? [] : files.concat([{ finder: true, name: "Open in Finder" }])
    readonly property var g: Stack.gridSize(gridCells.length, stageSize.w, stageSize.h, title !== "")
    // the grid's edge is the tile's icon box top (lib/dockstack.js gridPlace), not the Dock background's top
    readonly property var place: Stack.gridPlace(tileCX, 0, width > 0 ? width : (screen ? screen.width : 0), g.width, g.height, tileBottom - tile, magnification)
    readonly property real bodyHeight: g.height - Theme.dock.stack.gridTailBand
    readonly property real tailAt: Stack.tailX(tileCX, place.x, g.width, Theme.dock.stack.gridRadius, Theme.dock.stack.gridTail)
    Item {
        id: panel
        visible: !win.fan
        x: win.place.x
        y: win.place.y
        width: win.g.width
        height: win.g.height
        // from the tile's centre at scale 1e-5 to its place at 1 (-[DOCKStackGridAnimator expand:] 0x10001f9c0)
        readonly property real grow: Math.max(1e-5, win.p)
        opacity: win.p
        transform: [
            Scale { origin.x: panel.width / 2; origin.y: panel.height / 2; xScale: panel.grow; yScale: panel.grow },
            Translate {
                x: (1 - win.p) * (win.tileCX - (panel.x + panel.width / 2))
                y: (1 - win.p) * (win.tileBottom - win.tile / 2 - (panel.y + panel.height / 2))
            }
        ]

        // the tail without the plugin: a 24 pt square turned 45 deg, corner 5, its centre 5 above the body's bottom,
        // under the body (Theme.dock.stack). On the plugin the pointer marker below is the tail.
        Glass {
            visible: !(Theme.compositorGlass && !Theme.solidMaterial)
            width: Theme.dock.stack.gridTail
            height: width
            x: win.tailAt - width / 2
            y: win.bodyHeight - Theme.dock.stack.gridTailOffset - height / 2
            rotation: 45
            radius: Theme.dock.stack.gridTailCorner
            sx: panel.x + x
            sy: panel.y + y
            tint: Theme.glass.tintClear
            solidColor: Theme.glass.solidDock
            pluginLift: "transparent"
            shadow: false
            materialize: win.p
        }
        Glass {
            id: body
            width: parent.width
            height: win.bodyHeight
            radius: Theme.dock.stack.gridRadius
            sx: panel.x
            sy: panel.y
            tint: Theme.glass.tintClear
            solidColor: Theme.glass.solidDock
            pluginLift: "transparent"
            materialize: win.p
        }
        // the plugin's cartouche pointer (plugin/README.md "Dock label pointer"), as under the hover label
        Glass {
            visible: Theme.compositorGlass && !Theme.solidMaterial && !win.fan
            width: Theme.dock.labelPointer.width
            height: Theme.dock.labelPointer.height
            x: Math.round(win.tailAt) - width / 2
            y: body.height + 1
            sx: panel.x + x
            sy: panel.y + y
            radius: 0
            shadow: false
            pointer: true
            tint: Theme.glass.tintClear
            solidColor: Theme.glass.solidDock
            pluginLift: "transparent"
        }
        // swallow clicks on the bubble (outside the cells it does nothing, as on the Mac)
        MouseArea { width: body.width; height: body.height }

        Text {
            x: (parent.width - width) / 2
            y: Theme.dock.stack.titleTop
            width: Math.min(implicitWidth, parent.width * 0.75)
            height: Theme.dock.stack.titleHeight
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideMiddle
            text: win.title
            font: Typography.font(Theme.dock.stack.titleFont, Typography.bold)
            color: Theme.dock.labelText
        }

        Flickable {
            id: flick
            x: Theme.dock.stack.gridSide
            y: Theme.dock.stack.gridTop
            width: win.g.cols * win.g.cell
            height: win.g.rows * win.g.cell
            contentWidth: width
            contentHeight: win.g.allRows * win.g.cell
            interactive: win.g.scroll
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            Repeater {
                model: win.gridCells
                Item {
                    id: cellItem
                    required property var modelData
                    required property int index
                    readonly property var at: Stack.gridCell(index, win.g.cols, win.g.cell)
                    x: at.x
                    y: at.y
                    width: win.g.cell
                    height: win.g.cell
                    StackArt {
                        x: Theme.dock.stack.gridInset
                        y: win.g.cell - Theme.dock.stack.gridNameHeight - win.g.icon
                        file: cellItem.modelData
                        size: win.g.icon
                        dpr: win.dpr
                        finderLook: "grid"   // the "Open in Finder" cell: a ring, not the fan's disc (StackArt)
                    }
                    Text {
                        x: 1
                        y: win.g.cell - Theme.dock.stack.gridNameHeight
                        width: win.g.cell - 2
                        height: Theme.dock.stack.gridNameHeight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideMiddle
                        text: cellItem.modelData.name || ""
                        font: Typography.font(Theme.dock.stack.itemFont)
                        color: Theme.dock.labelText
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: win.open
                        onClicked: win.activate(cellItem.modelData)
                    }
                }
            }
        }
        // 1 pt lines above and below the grid (-[DOCKStackGridLayer layout]); drawn only while it scrolls (guessed:
        // the Mac shot of 11 items shows none)
        Repeater {
            model: win.g.scroll ? [flick.y - 1, flick.y + flick.height] : []
            Rectangle {
                required property real modelData
                x: flick.x
                y: modelData
                width: flick.width
                height: Pixel.stroke(1, win.dpr)   // exact, antialiased at a fractional scale like the Mac's downsample (HyprK pixel.js, SCALING-AUDIT R3.3)
                antialiasing: Pixel.soft(win.dpr)
                color: Theme.color.separator
            }
        }
    }
}
