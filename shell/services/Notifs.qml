pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Own org.freedesktop.Notifications server. Keeps a history for the
// Notification Center and a short list of live banners.
Singleton {
    id: root

    property bool dnd: false                  // Focus: Do Not Disturb (suppresses banners)
    property var banners: []                  // live Notification objects shown as banners
    property ListModel history: ListModel {}  // plain data copies, newest first
    property var objects: ({})                // id -> Notification, while still tracked

    signal bannerAdded(var n)

    function add(n) {
        n.tracked = true;
        const o = Object.assign({}, objects);
        o[n.id] = n;
        objects = o;
        // replace an existing history row for the same id (notification update)
        for (let i = 0; i < history.count; i++)
            if (history.get(i).nid === n.id) { history.remove(i); break; }
        history.insert(0, {
            nid: n.id,
            appName: n.appName || "Notification",
            appIcon: n.appIcon || "",
            desktopEntry: n.desktopEntry || "",
            image: n.image || "",
            summary: n.summary || "",
            body: n.body || "",
            time: Date.now(),
        });
        n.closed.connect(() => root.forget(n.id));
        if (!dnd)
            banners = [n].concat(banners.filter(b => b.id !== n.id)).slice(0, 3);
        bannerAdded(n);
    }

    function hideBanner(id) {
        banners = banners.filter(b => b.id !== id);
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
