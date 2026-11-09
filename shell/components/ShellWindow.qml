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
    function settleGlass() {
        if (!Theme.compositorGlass) return;
        settle.ticks = Math.ceil(Theme.anim.bannerIn / settle.interval) + 2;
        settle.restart();
    }
    Timer {
        id: settle
        property int ticks: 0
        interval: 40
        repeat: true
        onTriggered: { win.glassMoved(); if (--ticks <= 0) stop(); }
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
