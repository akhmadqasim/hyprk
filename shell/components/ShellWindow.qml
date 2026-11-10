import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.HyprK

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
    // Windows created on open (shell.qml LazyLoader) set `lingerAs` to their Panels name and
    // `lingering` while they dematerialize after closing: Panels keeps them loaded until then.
    // input region: `inputMask` (null = the whole window) while `acceptsInput`, else none, so a
    // surface animating out never eats the click that opened the next one
    property bool acceptsInput: true
    property Region inputMask: null
    mask: acceptsInput ? inputMask : noInput
    Region { id: noInput }

    property string lingerAs: ""
    property bool lingering: false
    onLingeringChanged: if (lingerAs !== "" && !lingering) Panels.release(lingerAs)
    Component.onDestruction: if (lingerAs !== "") Panels.release(lingerAs)

    // Glass items call these on creation/destruction
    function registerGlass(r) { glassRegions.push(r); }
    function unregisterGlass(r) { glassRegions = Array.from(glassRegions).filter(x => x !== r); }

    // Region only follows its own item's geometry, not parents moving or
    // transforms (slide/scale animations). While things may be animating,
    // Glass items re-measure their shape on every glassMoved().
    signal glassMoved()
    // Re-measure on every rendered frame while something may animate (was a 40 ms timer = 25 Hz,
    // so the compositor glass stepped behind the 60 Hz content and looked choppy).
    // tail: how long to keep going (default covers a panel's open animation; springs that call
    // this on every frame pass a couple of frames, so it stops right after they settle)
    function settleGlass(tail) {
        if (!Theme.compositorGlass || !visible || glassRegions.length === 0) return;
        settle.until = Math.max(settle.until, Date.now() + (tail === undefined ? Theme.anim.normal + 80 : tail));
        settle.running = true;
    }
    FrameAnimation {
        id: settle
        property double until: 0
        onTriggered: { win.glassMoved(); if (Date.now() >= until) { stop(); until = 0; } }
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
    // a glass-moving Spring (settlesGlass) stepped somewhere: if it is in this window, keep the glass
    // re-measuring for two frames past its last step
    Connections {
        target: Tokens
        function onGlassStepped(spring) {
            if (!win.visible || !Theme.compositorGlass || win.glassRegions.length === 0) return;
            for (let p = spring; p; p = p.parent)
                if (p === win.contentItem) { win.settleGlass(50); return; }
        }
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
