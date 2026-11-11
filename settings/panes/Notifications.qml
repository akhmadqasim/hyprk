import QtQuick
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P

// Saves everything to state/notifications.json for the shell's notification server
// to read (not wired yet; see FALLBACKS.md). Apps are those whose .desktop file declares
// X-GNOME-UsesNotifications=true (scripts/notify-apps.sh).
Column {
    id: pane
    spacing: Theme.content.sectionGap
    readonly property var n: AppState.notifications
    property var apps: []
    property string status: "loading"

    function setApp(id, patch) {
        const apps = Object.assign({}, n.apps);
        apps[id] = Object.assign({}, P.notifAppDefaults, apps[id] || {}, patch);
        AppState.set("notifications", { apps: apps });
    }
    function app(id) { return n.apps[id] || P.notifAppDefaults; }
    Component.onCompleted: Backend.run([Backend.root + "/settings/scripts/notify-apps.sh"], (c, o) => {
        status = Backend.status(c);
        apps = P.parseDesktopApps(o);
    })

    Card {
        title: "Notification Center"
        FormRow {
            label: "Show previews"
            StatePopup { stateKey: "notifications"; field: "previews"; choices: [["Always", "always"], ["When Unlocked", "unlocked"], ["Never", "never"]] }
        }
        FormRow { label: "Summarize notifications"; Switch { checked: pane.n.summarize; onToggled: on => AppState.set("notifications", { summarize: on }) } }
        FormRow { label: "Allow notifications when the display is sleeping"; Switch { checked: pane.n.whenSleeping; onToggled: on => AppState.set("notifications", { whenSleeping: on }) } }
        FormRow { label: "Allow notifications when the screen is locked"; Switch { checked: pane.n.whenLocked; onToggled: on => AppState.set("notifications", { whenLocked: on }) } }
        FormRow { label: "Allow notifications when mirroring or sharing the display"; Switch { checked: pane.n.whenMirroring; onToggled: on => AppState.set("notifications", { whenMirroring: on }) } }
    }

    Card {
        title: "Application Notifications"
        FormRow {
            visible: pane.apps.length === 0
            dim: true
            label: pane.status === "loading" ? "Loading…" : "No apps have asked to send notifications"
        }
        Repeater {
            model: pane.apps
            FormRow {
                id: appRow
                required property var modelData
                readonly property var cfg: pane.app(modelData.id)
                iconSource: Backend.iconUrl(modelData.icon)
                label: modelData.name
                sublabel: !cfg.allow ? "Off" : (cfg.style === "alerts" ? "Alerts" : "Banners") + (cfg.sounds ? ", Sounds" : "")
                Popup {
                    readonly property var keys: ["off", "banners", "alerts"]
                    model: ["Off", "Banners", "Alerts"]
                    currentIndex: !appRow.cfg.allow ? 0 : Math.max(1, keys.indexOf(appRow.cfg.style))
                    onActivated: i => pane.setApp(appRow.modelData.id, i === 0 ? { allow: false } : { allow: true, style: keys[i] })
                }
            }
        }
    }
    InlineNote { text: Backend.statusNote(pane.status, "The app list", "per-app notifications") }
    PaneFooter {}
}
