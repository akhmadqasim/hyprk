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
    // Liquid Glass materialize progress of this window's glass: 0 = the untouched backdrop,
    // 1 = the full material. The plugin ramps lensing, blur, tint, rim and shadow with it instead
    // of fading alpha (Glass.qml sends it per shape as a 1 px hole, plugin/src/Shape.hpp).
    // Glass items follow it unless they set their own `materialize`.
    property real glassMaterialize: 1
    // Windows created on open (shell.qml LazyLoader) never run a Behavior: with fadeIn, `appear`
    // goes 0 -> 1 on the SwiftUI spring from creation, for the window to drive opacity/scale from
    property bool fadeIn: false
    property real appear: 1
    // re-measure the glass on each appear frame (the window may be created after Panels changed)
    onAppearChanged: if (fadeIn && appear < 1) glassMoved()
    NumberAnimation on appear { running: win.fadeIn; from: 0; to: 1; duration: Theme.anim.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring }

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
        settle.until = Date.now() + Theme.anim.normal + 80;   // normal: the longest shell animation
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
        regions: Array.from(win.glassRegions).concat([opacityMarker])
    }
    // always in the list (only x changes per frame); width 0 = no marker = opacity 1
    Region {
        id: opacityMarker
        x: Math.round(Math.max(0, win.glassOpacity) * (win.width - 1))
        y: win.height - 1
        width: win.glassOpacity < 1 ? 1 : 0
        height: 1
    }
}
