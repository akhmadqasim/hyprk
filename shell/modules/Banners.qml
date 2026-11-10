import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/nc.js" as NcLib

// Notification banners, top-right below the menu bar, in the Notification Center card column (macOS 27.2.1, PC #62 3a/3b,
// lib/nc.js):
// - one banner per app; more from the same app stack behind it (plates below)
// - slide in from the right (spring 0.43 s, ratio 0.9, from 462 pt out) while fading in and growing from 0.85; the
//   glass materializes with the fade. One progress value (`enter`) drives offset, opacity and scale
// - expire after Theme.notif.timeout (4.97 s) unless hovered, then slide back out to the right on Spring(0.3, -0.2),
//   fading out, gone after 0.15 s (`leave`); they do not fly into Notification Center. Reduce motion: they dissolve
// - the others glide up into the gap; swipe right sends the stack to Notification Center
// - close button (hover, top-left) removes the notifications; a click opens the app
ShellWindow {
    id: win

    required property var modelData
    screen: modelData

    readonly property int maxStacks: 3
    readonly property int edge: 24                     // room for shadow and close button

    visible: stacks.count > 0 && Panels.open !== "nc"
    anchors { top: true; right: true }
    margins.top: Theme.notif.marginTop - list.y
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

        displaced: Transition {
            NumberAnimation { property: "y"; duration: 360; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring }
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

            // 0 off to the right .. 1 in place; Reduce motion: a fade only
            property real enter: 0
            SpringCurve { id: enterAnim; target: row; property: "enter"; spring: NcLib.bannerInSpring }
            // 0 in place .. 1 gone to the right (cut at 0.15 s, where the Mac's banner is gone)
            property real leave: 0
            SpringCurve {
                id: leaveAnim
                target: row; property: "leave"; spring: NcLib.bannerOutSpring; cutAt: NcLib.bannerOutCut
                onFinished: { stacks.remove(row.index); win.settleGlass(); }
            }
            readonly property real offset: Theme.travel((1 - enter) * NcLib.bannerInTravel + leave * NcLib.bannerOutTravel)
            readonly property real fade: NcLib.bannerInOpacity(enter) * NcLib.bannerOutOpacity(leave)
            // The compositor glass merges touching shapes into one box, so the older banners make room first and the
            // new one enters just behind them
            Component.onCompleted: {
                if (index > 0 || list.count < 2) enterAnim.go(1);
                else enterLater.start();
                win.settleGlass(enterAnim.duration + 200);
            }
            Timer { id: enterLater; interval: 150; onTriggered: { enterAnim.go(1); win.settleGlass(enterAnim.duration + 50); } }
            onLeavingChanged: {
                if (!leaving) return;
                if (swipedAway) { stacks.remove(index); win.settleGlass(); return; }
                leaveAnim.go(1);
                win.settleGlass(leaveAnim.duration + 50);
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
                materialize: row.fade
                scale: Theme.reduceMotion ? 1 : NcLib.bannerInScale(row.enter)
                transform: Translate { x: row.offset }
                // banner window origin: right-aligned below the menu bar
                sx: win.screen.width - win.width - (Theme.notif.marginRight - win.edge) + list.x + row.x + row.offset
                sy: Theme.menuBar.height + Theme.notif.marginTop + row.y
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
