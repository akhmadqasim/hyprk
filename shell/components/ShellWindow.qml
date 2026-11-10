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
        regions: win.glassRegions
    }
}
