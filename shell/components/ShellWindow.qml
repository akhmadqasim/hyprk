import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Base for every shell layer surface. Glass items inside register their
// shapes here; with the liquidglass compositor plugin active the union is
// sent as the ext-background-effect blur region, so the plugin draws real
// Liquid Glass behind exactly those rounded rects.
PanelWindow {
    id: win

    property string namespace: "hyprk"
    property list<QtObject> glassRegions
    // Opacity of the compositor glass, for panels that fade in/out: the plugin cannot see QML
    // opacity, so it is sent as a 1x1 marker in the bottom row of the region, x = opacity x (width - 1),
    // committed with the same frame (plugin/src/Shape.hpp takeOpacityMarker). 1 sends no marker.
    property real glassOpacity: 1

    // Glass items call these on creation/destruction
    function registerGlass(r) { glassRegions.push(r); }
    function unregisterGlass(r) { glassRegions = Array.from(glassRegions).filter(x => x !== r); }

    // Region only follows its own item's geometry, not parents moving or
    // transforms (slide/scale animations). While things may be animating,
    // Glass items re-measure their shape on every glassMoved().
    signal glassMoved()
    // Re-measure on every rendered frame while something may animate (was a 40 ms timer = 25 Hz,
    // so the compositor glass stepped behind the 60 Hz content and looked choppy).
    function settleGlass() {
        if (!Theme.compositorGlass || !visible || glassRegions.length === 0) return;
        settle.until = Date.now() + Math.max(Theme.anim.bannerIn, Theme.anim.normal) + 80;
        settle.running = true;
    }
    FrameAnimation {
        id: settle
        property double until: 0
        onTriggered: { win.glassMoved(); if (Date.now() >= until) stop(); }
    }
    onVisibleChanged: settleGlass()
    Connections {
        target: Panels
        function onOpenChanged() { win.settleGlass(); }
    }
    Connections {
        target: Notifs
        function onBannersChanged() { win.settleGlass(); }
    }

    color: "transparent"
    WlrLayershell.namespace: namespace
    BackgroundEffect.blurRegion: Theme.compositorGlass ? glassUnion : null

    Region {
        id: glassUnion
        regions: win.glassOpacity < 1 ? Array.from(win.glassRegions).concat([opacityMarker]) : win.glassRegions
    }
    Region {
        id: opacityMarker
        x: Math.round(Math.max(0, win.glassOpacity) * (win.width - 1))
        y: win.height - 1
        width: 1
        height: 1
    }
}
