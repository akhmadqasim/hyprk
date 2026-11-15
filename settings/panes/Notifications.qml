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
    // Sub-panes (MAC-ANSWERS-12.md R12.3; live/settings-r12/nav-notifications--{summarise,app-finder}-dark.png and their
    // AX dumps), pushed on the window's navigation (SettingsApp.qml): "summarize", or "app:<id>" for an application
    property string page: ""
    readonly property var pageApp: page.indexOf("app:") === 0 ? apps.find(a => "app:" + a.id === page) || null : null
    readonly property string pageTitle: page === "summarize" ? "Summarize Notifications" : pageApp ? pageApp.name : ""
    component Sub: FormRow { leftInset: 31 }   // the "Show Notifications:" rows, 31 pt further in

    function setApp(id, patch) {
        const apps = Object.assign({}, n.apps);
        apps[id] = Object.assign({}, P.notifAppDefaults, apps[id] || {}, patch);
        AppState.set("notifications", { apps: apps });
    }
    function app(id) { return n.apps[id] || P.notifAppDefaults; }
    Component.onCompleted: Backend.run([Backend.root + "/settings/scripts/notify-apps.sh"], (c, o) => {
        apps = P.parseDesktopApps(o);
    })

    // 27.2.1 (R3.8b notifications-{00..06}-light.png, ax-notifications-light.jsonl; the Mac's en_GB "Centre" /
    // "Customise" / "Summarise" in US spelling as the rest of the app): a compact hero, the Notification Center heading with
    // its line, Show previews, "Show Notifications:" and three indented rows (labels 31 pt further in: x 61 against 30).
    // Ours keeps a switch for mirroring: the Mac's row is a pop-up ("Notifications Off", its other item not on a shot).
    // Summarize and each application are rows into their sub-panes (below). Not here: "Allow notifications from
    // iPhone" (its sub-pane lists the Mac's own phone apps, redacted on the still).
    HeroCard {
        visible: pane.page === ""
        compact: true
        iconId: "notifications"
        title: "Notifications"
        text: "Customize when and how notifications appear, if they play a sound and which apps can send them."
        link: "Learn more…"
        helpAnchor: "mchl205da693"   // ax-notifications-light.jsonl
    }
    Card {
        visible: pane.page === ""
        title: "Notification Center"
        subtitle: "Notification Center shows your notifications in the top-right corner of your screen. You can show and hide Notification Center by clicking the clock in the menu bar."
        FormRow {
            label: "Show previews"
            StatePopup { objectName: "notifPreviews"; stateKey: "notifications"; field: "previews"; choices: [["Always", "always"], ["When Unlocked", "unlocked"], ["Never", "never"]] }
        }
        FormRow { label: "Show Notifications:" }
        Sub { label: "when display is sleeping"; Switch { checked: pane.n.whenSleeping; onToggled: on => AppState.set("notifications", { whenSleeping: on }) } }
        Sub { label: "when screen is locked"; Switch { checked: pane.n.whenLocked; onToggled: on => AppState.set("notifications", { whenLocked: on }) } }
        // a pop-up on the Mac (R13.2 popups.json: Notifications Off / Allow Notifications, 147 wide), on the same state
        Sub { label: "when mirroring or sharing the display"; Popup { objectName: "notifMirroring"; model: ["Notifications Off", "Allow Notifications"]; currentIndex: pane.n.whenMirroring ? 1 : 0; onActivated: i => AppState.set("notifications", { whenMirroring: i === 1 }) } }
        // a row into its sub-pane, the value at its end (ax-notifications-light.jsonl: "Off", 468 x 36)
        FormRow { objectName: "notifSummarizeRow"; implicitHeight: 37; label: "Summarize notifications"; value: pane.n.summarize ? "On" : "Off"; onClicked: pane.page = "summarize"; NavChevron {} }
    }

    Card {
        visible: pane.apps.length > 0 && pane.page === ""
        title: "Application Notifications"
        Repeater {
            model: pane.apps
            FormRow {
                id: appRow
                required property var modelData
                readonly property var cfg: pane.app(modelData.id)
                iconSource: Backend.appIconUrl(modelData.icon, modelData.id, Theme.iconLook)
                implicitHeight: index > 0 ? 53 : 52   // 27.2.1: app rows 52 (+ the separator), ax-notifications-light.jsonl
                required property int index
                label: modelData.name
                sublabel: !cfg.allow ? "Off" : (cfg.style === "alerts" ? "Alerts" : "Banners") + (cfg.sounds ? ", Sounds" : "")
                objectName: "notifAppRow" + index
                onClicked: pane.page = "app:" + modelData.id
                NavChevron {}
            }
        }
    }
    PaneFooter { visible: pane.page === ""; helpAnchor: "mh40583" }   // NotificationsSettings.appex: "Notifications settings"

    // ---------- Summarize Notifications ----------
    // one card: the name, two lines and "Summaries may contain errors." (13 pt lines 16 / 14 / 13), the switch at the top
    Card {
        visible: pane.page === "summarize"
        FormRow {
            sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
            label: "Summarize Notifications"
            sublabel: "Summarize content in direct messages and groups of notifications, making them more succinct and easier to read.\nSummaries may contain errors."
            Switch { objectName: "notifSummarizeSwitch"; checked: pane.n.summarize; onToggled: on => AppState.set("notifications", { summarize: on }) }
        }
    }

    // ---------- an application ----------
    // [icon, Allow notifications, the app's name, a regular switch] [where they show: three pictures 88 x 58 with a
    // name and a checkbox each; Alert Style Temporary / Persistent] [Badge application icon, Play sound for
    // notification] [Show previews, Notification grouping, Summarize notifications (disabled, on)], Help.
    // state/notifications.json holds allow, style (banners = Temporary, alerts = Persistent) and sounds; the rest keeps
    // the Mac's values (settings/FALLBACKS.md "Notifications"). The pop-ups' other items are not on a shot.
    readonly property var pageCfg: pageApp ? app(pageApp.id) : P.notifAppDefaults
    component Where: Item {
        id: where
        property string title
        property int kind: 0   // 0 Desktop, 1 Notification Center, 2 Lock Screen
        property bool on: true
        width: 88; height: 104
        Rectangle {
            width: 88; height: 58; radius: 3
            gradient: Gradient {
                GradientStop { position: 0; color: "#5F93CC" }
                GradientStop { position: 1; color: "#8B6BA8" }
            }
            Repeater {   // the banners: one at the top right, or Notification Center's column
                model: where.kind === 1 ? 6 : 1
                Rectangle { required property int index; x: 63; y: 5 + index * 7.5; width: 23; height: 6; radius: 2; color: Qt.rgba(1, 1, 1, 0.9) }
            }
            Rectangle { visible: where.kind !== 2; x: 27; y: 52; width: 34; height: 4; radius: 2; color: Qt.rgba(0.85, 0.75, 0.95, 0.9) }
            Text { visible: where.kind === 2; x: 34; y: 6; text: "9:41"; font: Typography.font(9, 590); color: Qt.rgba(1, 1, 1, 0.75) }
        }
        MacText { anchors.horizontalCenter: parent.horizontalCenter; y: 66; text: where.title }
        Checkbox { x: 36; y: 88; checked: where.on; onToggled: v => where.on = v }
    }
    Card {
        visible: pane.pageApp !== null
        Item {
            width: parent.width; height: 52
            PaneIcon { x: 11.5; anchors.verticalCenter: parent.verticalCenter; size: 25; imageSource: pane.pageApp ? Backend.appIconUrl(pane.pageApp.icon, pane.pageApp.id, Theme.iconLook) : "" }
            MacText { x: 48; y: 10; text: "Allow notifications" }
            Text { x: 48; y: 28; text: pane.pageApp ? pane.pageApp.name : ""; font: Typography.subheadline; color: Theme.secondaryLabel }
            Switch {
                objectName: "notifAllowSwitch"
                controlSize: "small"
                anchors.right: parent.right; anchors.rightMargin: 10; y: 9
                checked: pane.pageCfg.allow
                onToggled: on => pane.setApp(pane.pageApp.id, { allow: on })
            }
        }
    }
    Card {
        visible: pane.pageApp !== null
        Item {
            width: parent.width; height: 144.5
            Where { x: 52.5; y: 20; title: "Desktop"; kind: 0 }
            Where { x: 190; y: 20; title: "Notification Center"; kind: 1 }
            Where { x: 327.5; y: 20; title: "Lock Screen"; kind: 2 }
        }
        FormRow {
            implicitHeight: 36.5
            label: "Alert Style"
            Checkbox { objectName: "notifStyleTemporary"; radio: true; text: "Temporary"; checked: pane.pageCfg.style !== "alerts"; onToggled: pane.setApp(pane.pageApp.id, { style: "banners" }); anchors.verticalCenter: parent.verticalCenter }
            Checkbox { objectName: "notifStylePersistent"; radio: true; text: "Persistent"; checked: pane.pageCfg.style === "alerts"; onToggled: pane.setApp(pane.pageApp.id, { style: "alerts" }); anchors.verticalCenter: parent.verticalCenter }
        }
    }
    Card {
        visible: pane.pageApp !== null
        FormRow { label: "Badge application icon"; LocalSwitch { checked: true } }
        FormRow { label: "Play sound for notification"; Switch { checked: pane.pageCfg.sounds; onToggled: on => pane.setApp(pane.pageApp.id, { sounds: on }) } }
    }
    Card {
        visible: pane.pageApp !== null
        FormRow { label: "Show previews"; LocalPopup { model: ["Default"] } }
        FormRow { label: "Notification grouping"; LocalPopup { model: ["Automatic"] } }
        FormRow { label: "Summarize notifications"; dim: true; Switch { enabled: false; checked: true } }
    }
    PaneFooter { visible: pane.pageApp !== null }
}
