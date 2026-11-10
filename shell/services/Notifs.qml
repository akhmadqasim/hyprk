pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "../lib/state.js" as State

// Own org.freedesktop.Notifications server. Keeps a history for the
// Notification Center and a short list of live banners.
Singleton {
    id: root

    property bool dnd: false                  // Focus: Do Not Disturb (suppresses banners)
    // one minute clock for every "5m ago" label, running only while cards are visible
    readonly property double now: clock.date.getTime()
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        enabled: root.banners.length > 0 || Panels.open === "nc"
    }
    property var banners: []                  // plain data of notifications shown as banners
    property ListModel history: ListModel {}  // plain data copies, newest first
    property var objects: ({})                // id -> Notification, while still tracked

    function add(n) {
        // per-app rule from state/notifications.json (Settings > Notifications)
        const rule = State.notifRule(Prefs.notifications, [n.desktopEntry, n.appName]);
        if (!rule.allow) {
            n.dismiss();
            return;
        }
        n.tracked = true;
        const o = Object.assign({}, objects);
        o[n.id] = n;
        objects = o;
        // replace an existing history row for the same id (notification update)
        let update = false;
        for (let i = 0; i < history.count; i++)
            if (history.get(i).nid === n.id) { history.remove(i); update = true; break; }
        n.closed.connect(() => root.forget(n.id));
        push({
            nid: n.id,
            appName: n.appName || "Notification",
            appIcon: n.appIcon || n.desktopEntry || "",
            image: n.image || "",
            summary: n.summary || "",
            body: n.body || "",
            time: Date.now(),
            timeout: n.expireTimeout > 0 ? n.expireTimeout : 0,
            critical: n.urgency === NotificationUrgency.Critical,
            style: rule.style,             // none: Notification Center only, alerts: stay until dismissed
            // updates (progress etc.) and apps that ask for silence don't chime
            silent: update || !rule.sounds || n.hints["suppress-sound"] === true,
        });
    }

    // add plain notification data to history and banners
    function push(d) {
        if (Prefs.notifications.previews === "never") d.body = "";   // Settings > Show previews: Never
        history.insert(0, d);
        if (dnd) return;                       // Focus: no banner, no sound
        if (d.style !== "none")
            // Banners.qml groups these by app and shows up to three stacks
            banners = [d].concat(banners.filter(b => b.nid !== d.nid)).slice(0, 12);
        if (!d.silent) Sounds.play(d.critical ? "alert" : "notification");
    }

    function hideBanner(id) {
        banners = banners.filter(b => b.nid !== id);
    }

    // a banner stack goes away as a whole (expired, swiped, clicked)
    function hideBanners(appName) {
        banners = banners.filter(b => b.appName !== appName);
    }

    // close button on a banner stack: the notifications are removed, like macOS
    function dismissBanners(appName) {
        banners.filter(b => b.appName === appName).forEach(b => dismiss(b.nid));
    }

    function forget(id) {
        hideBanner(id);
        const o = Object.assign({}, objects);
        delete o[id];
        objects = o;
    }

    function dismiss(id) {
        const n = objects[id];
        if (n) n.dismiss();
        for (let i = 0; i < history.count; i++)
            if (history.get(i).nid === id) { history.remove(i); break; }
        hideBanner(id);
    }

    function clearApp(appName) {
        for (let i = history.count - 1; i >= 0; i--)
            if (history.get(i).appName === appName) dismiss(history.get(i).nid);
    }

    function clearAll() {
        for (let i = history.count - 1; i >= 0; i--) dismiss(history.get(i).nid);
    }

    function invokeDefault(id) {
        const n = objects[id];
        if (!n) return;
        const a = n.actions.find(x => x.identifier === "default") || n.actions[0];
        if (a) a.invoke();
        else n.dismiss();
    }

    // grouped view for the Notification Center: [{appName, items:[...]}]
    function groups() {
        const order = [], map = {};
        for (let i = 0; i < history.count; i++) {
            const h = history.get(i);
            if (!map[h.appName]) { map[h.appName] = []; order.push(h.appName); }
            map[h.appName].push(h);
        }
        return order.map(a => ({ appName: a, items: map[a] }));
    }

    // `qs ipc call notifs test "Title" "Body"`: local banner without D-Bus
    // (useful when another notification daemon owns the bus, e.g. nested sessions)
    property int testId: 1000000
    IpcHandler {
        target: "notifs"
        function test(summary: string, body: string): void { testApp("Messages", summary, body); }
        function testApp(app: string, summary: string, body: string): void {
            root.push({ nid: ++root.testId, appName: app, appIcon: "", image: "", summary: summary,
                        body: body, time: Date.now(), timeout: 0, critical: false, style: "banners", silent: true });
        }
        function clear(): void { root.clearAll(); }
    }

    NotificationServer {
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true
        onNotification: n => root.add(n)
    }
}
