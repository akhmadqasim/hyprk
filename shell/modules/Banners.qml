import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services

// Notification banners, top-right below the menu bar (macOS 27):
// - one banner per app; more from the same app stack behind it (edges peek below)
// - slide in from the right edge on the SwiftUI spring (0.5 s, critically damped), the glass
//   materializing as it comes (Liquid Glass: lensing, blur and rim ramp in with the slide)
// - expire after Theme.notif.timeout unless hovered, then slide back out to the right
//   (dematerializing); Reduce motion: they dissolve in place instead
// - the others glide up into the gap; swipe right sends the stack to Notification Center
// - close button (hover, top-left) removes the notifications; a click opens the app
ShellWindow {
    id: win

    required property var modelData
    screen: modelData

    readonly property int maxStacks: 3
    readonly property int edge: 24                     // room for shadow and close button
    readonly property real slideOut: Theme.notif.width + Theme.notif.marginRight + edge

    visible: stacks.count > 0 && Panels.open !== "nc"
    anchors { top: true; right: true }
    margins.top: Theme.notif.marginTop
    margins.right: Theme.notif.marginRight - edge
    implicitWidth: Theme.notif.width + edge * 2
    implicitHeight: Math.max(1, list.contentHeight + edge * 2)
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    namespace: "hyprk-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    // one row per app, newest first; rows that leave stay until their slide-out ends
    ListModel { id: stacks }
    Connections {
        target: Notifs
        function onBannersChanged() { win.sync(); }
    }
    Component.onCompleted: sync()

    function find(app) {
        for (let i = 0; i < stacks.count; i++)
            if (stacks.get(i).app === app && !stacks.get(i).leaving) return i;
        return -1;
    }
    function sync() {
        const order = [], by = {};
        for (const d of Notifs.banners) {
            if (!by[d.appName]) { by[d.appName] = { top: d, n: 0 }; order.push(d.appName); }
            by[d.appName].n++;
        }
        const want = order.slice(0, maxStacks);
        // backwards: a swiped row removes itself right away
        for (let i = stacks.count - 1; i >= 0; i--) {
            const e = stacks.get(i);
            if (!e.leaving && want.indexOf(e.app) === -1) stacks.setProperty(i, "leaving", true);
        }
        // oldest wanted first, so the newest ends up on top
        for (const app of want.slice().reverse()) {
            const g = by[app], d = g.top;
            const row = { app: app, nid: d.nid, appIcon: d.appIcon || "", image: d.image || "", summary: d.summary,
                          body: d.body, time: d.time, timeout: d.timeout || 0, sticky: !!d.critical || d.style === "alerts",
                          stack: g.n, leaving: false };
            const i = find(app);
            if (i < 0) { stacks.insert(0, row); continue; }
            const fresh = stacks.get(i).nid !== d.nid;
            stacks.set(i, row);
            if (fresh && i !== 0) stacks.move(i, 0, 1);
        }
        // newest first, also when an older app comes back into the top three
        for (let k = 1; k < want.length; k++) {
            const prev = find(want[k - 1]), i = find(want[k]);
            if (i < prev) stacks.move(i, prev, 1);
        }
    }

    ListView {
        id: list
        x: win.edge
        y: 8
        width: Theme.notif.width
        // a fixed tall view: ListView only runs `add` for rows inside its height
        height: 800
        interactive: false
        spacing: Theme.notif.spacing
        model: stacks

        // The compositor glass merges touching shapes into one box, so the older banners make
        // room first (faster spring) and the new one enters just behind them from off-screen.
        add: Transition {
            SequentialAnimation {
                PropertyAction { property: "x"; value: A11y.reduceMotion ? 0 : win.slideOut }
                PropertyAction { property: "fade"; value: A11y.reduceMotion ? 0 : 1 }
                PauseAnimation { duration: list.count > 1 ? 150 : 0 }
                ParallelAnimation {
                    NumberAnimation { property: "x"; to: 0; duration: Theme.anim.bannerIn; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring }
                    NumberAnimation { property: "fade"; to: 1; duration: Theme.anim.crossfade * 1000 }
                }
            }
        }
        displaced: Transition {
            NumberAnimation { property: "y"; duration: 360; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring }
            NumberAnimation { property: "x"; to: 0; duration: 360; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring }
        }
        move: Transition {
            NumberAnimation { property: "y"; duration: Theme.anim.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring }
        }

        delegate: Item {
            id: row
            required property int index
            required property string app
            required property int nid
            required property string appIcon
            required property string image
            required property string summary
            required property string body
            required property double time
            required property int timeout
            required property bool sticky
            required property int stack
            required property bool leaving

            width: Theme.notif.width
            height: card.height + Math.min(stack - 1, 2) * Theme.notif.stackPeek
            property bool swipedAway: false
            property bool armed: true
            property real fade: 1                  // Reduce motion: dissolve instead of the slide

            transform: Translate { id: out; x: 0 }
            onLeavingChanged: {
                if (!leaving) return;
                if (swipedAway) { stacks.remove(index); win.settleGlass(); }
                else leave.start();
            }
            SequentialAnimation {
                id: leave
                ParallelAnimation {
                    NumberAnimation { target: out; property: "x"; to: A11y.reduceMotion ? 0 : win.slideOut; duration: 380; easing.type: Easing.InOutCubic }
                    NumberAnimation { target: row; property: "fade"; to: A11y.reduceMotion ? 0 : 1; duration: Theme.anim.crossfade * 1000 }
                }
                ScriptAction { script: { stacks.remove(row.index); win.settleGlass(); } }
            }
            onXChanged: win.settleGlass()
            onYChanged: win.settleGlass()

            NotifCard {
                id: card
                width: Theme.notif.width
                nid: row.nid
                appName: row.app
                appIcon: row.appIcon
                image: row.image
                summary: row.summary
                body: row.body
                time: row.time
                stacked: row.stack - 1
                swipeable: !row.leaving
                opacity: row.fade
                materialize: row.fade * Math.max(0, Math.min(1, 1 - (row.x + out.x) / win.slideOut))
                // banner window origin: right-aligned below the menu bar
                sx: win.screen.width - win.width - (Theme.notif.marginRight - win.edge) + list.x + row.x + out.x
                sy: Theme.menuBar.height + Theme.notif.marginTop + list.y + row.y
                onClicked: { Notifs.invokeDefault(nid); Notifs.hideBanners(row.app); }
                onClosed: Notifs.dismissBanners(row.app)
                onSwiped: { row.swipedAway = true; Notifs.hideBanners(row.app); }

                // a newer notification of the same app replaces the text: quick refocus
                onNidChanged: { refocus.restart(); row.armed = false; row.armed = true; }   // and a fresh timeout
                NumberAnimation { id: refocus; target: card; property: "contentOpacity"; from: 0.25; to: 1; duration: 260; easing.type: Easing.OutCubic }
            }

            Timer {
                interval: row.timeout > 0 ? row.timeout : Theme.notif.timeout
                // critical and "Alerts" style stay until dismissed, like macOS alerts
                running: row.armed && !card.hovered && !row.sticky && !row.leaving && card.swipeX === 0
                onTriggered: Notifs.hideBanners(row.app)
            }
        }
    }
}
