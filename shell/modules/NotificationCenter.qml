import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/nc.js" as NcLib

// Notification Center (macOS 27): grouped notifications on top, widgets below.
// Motion (lib/nc.js, MAC-ANSWERS.md PC #62): the whole column slides in from the right screen edge as one sheet and
// back out on close (slideAnim); the list reflows on one spring (stack fold, a card arriving, a stack cleared).
// Groups: one card per app with two plates peeking below; a click unfolds the stack (cards glide down from behind
// the first, the app name fades in, Show less and a clear button appear), Show less folds it back. Hover shows a
// close button; swipe right or close clears a card (or a collapsed stack).
Item {
    id: nc

    property real originX: 0
    property real originY: 0
    property real maxHeight: 800

    width: Theme.nc.width
    height: Math.min(maxHeight, flick.contentHeight - nc.bleed)
    // the list is clipped for scrolling; this much room around it keeps the close buttons whole
    readonly property int bleed: 12

    readonly property int headerHeight: Theme.nc.headerHeight
    readonly property int cardGap: Theme.notif.spacing
    property real firstSlot: 1   // slot of the first notification group (the gap under it opens and closes with it)
    property var expanded: ({})       // appName -> bool
    property string photo: ""
    readonly property string wallpaperDir: Quickshell.shellDir + "/../themes/wallpapers/png"
    // folder name as the caption, like a Photos memory; a loose file in ~/Pictures gets the generic title
    readonly property string photoTitle: {
        const folder = photo ? photo.split("/").slice(-2, -1)[0] : "";
        return photo && !photo.startsWith(nc.wallpaperDir) && folder !== "Pictures" ? folder : "Featured Photo";
    }
    Process {
        // a photo from ~/Pictures (no screenshots), else one of the macOS wallpapers; once per shell start
        running: true
        command: ["sh", "-c", 'd="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"; p=$(find "$d" -maxdepth 2 -type f \\( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \\) -not -ipath "*screenshot*" 2>/dev/null | head -n1); [ -n "$p" ] || p=$(ls "$0"/*.png 2>/dev/null | grep -vi tahoe | head -n1); echo "$p"', nc.wallpaperDir]
        stdout: StdioCollector { onStreamFinished: nc.photo = text.trim() }
    }

    // plugin glass shapes follow moving items only while the window re-measures
    function settle() {
        const w = QsWindow.window;
        if (w && w.settleGlass) w.settleGlass();
        if (buttonHost) buttonHost.settleGlass();
    }
    // the buttons' glass is _Glass.regular, not the cards' notificationCenter recipe: their shapes go to this window
    // (hyprk-overlay, same geometry; NotificationCenterWindow.qml), their text and input stay here
    property var buttonHost: null
    // changes whenever anything in the list may have moved (scroll, a stack folding, open/close)
    // layouts settle after the change that moved them, so look again a frame later too
    property int settledTick: 0
    readonly property real layoutBase: flick.contentY + content.implicitHeight + nc.height + flick.height
    readonly property real layoutTick: layoutBase + settledTick
    onLayoutBaseChanged: resettle.restart()
    Timer { id: resettle; interval: 32; onTriggered: nc.settledTick = (nc.settledTick + 1) % 2 }
    // whole item inside the scroll viewport (the compositor glass ignores QML clipping)
    function fits(item, tick) {
        const p = item.mapToItem(flick, 0, 0);
        return p.y >= -2 && p.y + item.height <= flick.height + 2;
    }
    function setExpanded(app, on) {
        const e = Object.assign({}, expanded);
        e[app] = on;
        expanded = e;
    }

    // ---------- open / close ----------
    // false on the windows of the other screens, so they do not slide a copy in and out
    property bool onThisScreen: true
    readonly property bool shown: Panels.open === "nc" && onThisScreen
    readonly property bool animating: slideAnim.running
    readonly property real progress: slide   // 0 off-screen .. 1 open
    // openProgress: 0 off screen .. 1 open. Reduce motion: fades
    property real slide: 0
    readonly property real slideX: Theme.travel((1 - slide) * NcLib.panelTravel)
    // open and close (lib/nc.js): one critically damped spring, response 0.3 s, over the 376 pt column frame; only
    // the x offset moves (no fade, scale, blur or stagger; the glass is there from the first frame). The close stops
    // 0.375 s in (the spring at 99.7 %) and the window goes, as on the Mac. The exact spring, one value per frame of
    // the window (components/SpringCurve.qml), the glass re-measured with each.
    SpringCurve {
        id: slideAnim
        target: nc
        property: "slide"
        spring: NcLib.panelSpring
        settlesGlass: true
        onRunningChanged: if (running) nc.settle()
    }
    Connections {
        target: slideAnim
        function onFinished() { if (slideAnim.goal === 0) slideAnim.snap(0); }
    }
    onSlideChanged: if (slideAnim.running) settle()
    // The window is unmapped while nothing shows, so opening maps a new layer surface and the compositor takes a few
    // frames to present it. A spring started with `shown` ran those frames unseen. So the slide starts on the window's
    // first presented frame (frameSwapped), which shows the panel still off screen; the next frame is step 1.
    property bool windowLive: false
    property bool openPending: false
    Connections {
        target: nc.Window.window   // the QQuickWindow (QsWindow.window is Quickshell's proxy, which has no frameSwapped)
        function onVisibleChanged() { if (!nc.Window.window.visible) nc.windowLive = false; }
        function onFrameSwapped() {
            if (!nc.Window.window.visible) return;     // frames of an unmapped window do not count
            nc.windowLive = true;
            if (nc.openPending) nc.startOpen();
        }
    }
    function startOpen() {
        openPending = false;
        if (!shown) return;
        slideAnim.cutAt = 0;
        slideAnim.go(1);
    }
    onShownChanged: {
        if (shown) {
            if (windowLive) startOpen();
            else openPending = true;
            refresh();
        } else {
            openPending = false;
            slideAnim.cutAt = NcLib.panelCloseCut;
            slideAnim.go(0);
            expanded = ({});         // macOS reopens with every stack collapsed
            confirmClearAll = false;
        }
    }
    // the section heading's x asked once (its "Clear All" capsule shows); a second click clears every group
    property bool confirmClearAll: false
    function clearEverything() {
        confirmClearAll = false;
        for (let i = 0; i < groupModel.count; i++) clearStack(groupModel.get(i).app);
    }
    // open and at rest: a group created now is a notification arriving (it pushes the list down and fades in)
    readonly property bool live: shown && !slideAnim.running && slide === 1

    // ---------- groups: one stable row per app, so stacks animate instead of being rebuilt ----------
    property var itemsByApp: ({})
    ListModel { id: groupModel }
    function refresh() {
        if (!shown) return;
        const gs = Notifs.groups(), by = {};
        gs.forEach(g => by[g.appName] = g.items);
        itemsByApp = by;
        for (let i = groupModel.count - 1; i >= 0; i--)
            if (!by[groupModel.get(i).app]) groupModel.remove(i);
        gs.forEach((g, i) => {
            let j = -1;
            for (let k = 0; k < groupModel.count; k++) if (groupModel.get(k).app === g.appName) { j = k; break; }
            if (j < 0) groupModel.insert(i, { app: g.appName });
            else if (j !== i) groupModel.move(j, i, 1);
        });
    }
    Connections {
        target: Notifs.history
        function onCountChanged() { nc.refresh(); }
    }
    signal clearStack(string app)
    Connections {
        target: Notifs
        function onStackRequest(app, action) {
            if (action === "clear") nc.clearStack(app);
            else nc.setExpanded(app, action === "expand");
        }
    }

    Item {
        id: stage
        width: nc.width
        height: nc.height
        transform: Translate { x: nc.slideX }
        opacity: Theme.reduceMotion ? Math.max(0, Math.min(1, nc.slide)) : 1

        Flickable {
            id: flick
            x: -nc.bleed
            y: -nc.bleed
            width: nc.width + nc.bleed
            height: nc.height + nc.bleed
            contentHeight: content.implicitHeight + nc.bleed
            clip: true
            boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
            RubberBand { flickable: flick }
            onContentYChanged: nc.settle()

            ColumnLayout {
                id: content
                x: nc.bleed
                y: nc.bleed
                width: nc.width
                spacing: Theme.nc.spacing

                // section heading over the groups (Q-panels-32: "Notification Centre", about SF 17 bold, a "Clear All"
                // glass circle with an xmark at the right edge; 24 pt in the code, MAC-ANSWERS NC button table). Its x
                // turns into a "Clear All" capsule first and a second click clears every group, as a group's x does
                // (the section's own confirm was not measured on the Mac)
                RowLayout {
                    Layout.fillWidth: true
                    visible: groupModel.count > 0
                    spacing: Theme.nc.pillGap
                    Text {
                        Layout.fillWidth: true
                        Layout.leftMargin: 4
                        text: "Notification Center"
                        elide: Text.ElideRight
                        font: Typography.font(17, Typography.bold)
                        color: Theme.color.label
                    }
                    Pill {
                        symbol: nc.confirmClearAll ? "" : "xmark"
                        text: nc.confirmClearAll ? "Clear All" : ""
                        implicitHeight: 24
                        onActivated: if (nc.confirmClearAll) nc.clearEverything(); else nc.confirmClearAll = true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: groupModel.count > 0
                    // the gaps are the groups' top margins, so they open and close with the arriving or cleared group
                    spacing: 0
                Repeater {
                    model: groupModel
                    delegate: Item {
                        id: grp
                        required property string app
                        required property int index
                        // reassigned only when this app's notifications change, so the other
                        // stacks keep their cards (a drag or hover is not cut off by a new arrival)
                        property var items: []
                        property bool confirmClear: false   // the header's x asked once (Q-panels-32)
                        function syncItems() {
                            const next = nc.itemsByApp[app] || [];
                            if (next.map(x => x.nid).join() !== items.map(x => x.nid).join()) items = next;
                        }
                        Connections {
                            target: nc
                            function onItemsByAppChanged() { grp.syncItems(); }
                            function onShownChanged() { grp.confirmClear = false; }
                        }
                        readonly property int n: items.length
                        readonly property bool open: n > 1 && nc.expanded[app] === true
                        property var heights: []
                        function measure() {
                            const h = [];
                            for (let i = 0; i < cards.count; i++) h.push(cards.itemAt(i) ? cards.itemAt(i).implicitHeight : 0);
                            heights = h;
                        }
                        function h(i) { return heights[i] || Theme.notif.iconSize + Theme.notif.padY * 2; }
                        function openY(i) {
                            let y = nc.headerHeight + nc.cardGap;
                            for (let k = 0; k < i; k++) y += h(k) + nc.cardGap;
                            return y;
                        }
                        function cardY(i) { return closedY(i) + (openY(i) - closedY(i)) * ex; }
                        // behind the first card, bottom edges where its plates are drawn
                        function closedY(i) { return i === 0 ? 0 : h(0) - h(i) + Math.min(i, 2) * Theme.notif.stackPeek; }
                        readonly property real closedHeight: h(0) + Math.min(n - 1, 2) * Theme.notif.stackPeek
                        readonly property real openHeight: n > 1 ? openY(n - 1) + h(n - 1) : h(0)
                        // the fold: 0 stacked, 1 unfolded, on the list reflow spring (lib/nc.js)
                        property real ex: 0
                        SpringCurve { id: fold; target: grp; property: "ex"; spring: NcLib.reflowSpring }
                        onOpenChanged: { fold.go(open ? 1 : 0); if (!open) confirmClear = false; }
                        // the group's share of the list: 0 -> 1 when it arrives while the panel is open (the list
                        // below is pushed down), 1 -> 0 after it was cleared (the list closes up); same spring
                        property real slot: 1
                        SpringCurve { id: slotAnim; target: grp; property: "slot"; spring: NcLib.reflowSpring }
                        // opacity of the cards: an arriving card fades in at its final place, a cleared one fades out
                        property real shade: 1
                        Component.onCompleted: {
                            syncItems();
                            if (!nc.live) return;
                            slot = 0;
                            shade = 0;
                            slotAnim.go(1);
                            arrive.start();
                        }
                        // counted in frames of the panel's window (HyprK FrameAnim, the first as a pause)
                        FrameAnim {
                            id: arrive
                            from: 0; to: 1; duration: Theme.ms(NcLib.arriveDelayMs)
                            onFinished: arriveFade.start()
                            function halt(): void { stop(); arriveFade.stop(); }
                        }
                        FrameAnim { id: arriveFade; target: grp; property: "shade"; to: 1; duration: Theme.ms(NcLib.arriveFadeMs) }
                        readonly property real liveHeight: closedHeight + (openHeight - closedHeight) * ex
                        Layout.fillWidth: true
                        // whole points: the layout rounds sizes up, so a group 0.06 pt tall still took 1 pt and the list
                        // jumped 2 pt when the cleared group went (mcap)
                        Layout.preferredHeight: Math.max(0, Math.floor(liveHeight * slot))
                        // the gap above this group grows and shrinks with it, and with the first group when that one
                        // arrives or goes. A negative margin under a group of height 0 was clamped by the layout, so
                        // the gap jumped 6 pt when a group was inserted or removed (mcap)
                        Layout.topMargin: index === 0 ? 0 : Math.round(nc.cardGap * slot * (index === 1 ? nc.firstSlot : 1))
                        onIndexChanged: if (index === 0) nc.firstSlot = slot
                        onLiveHeightChanged: nc.settle()
                        onSlotChanged: { nc.settle(); if (index === 0) nc.firstSlot = slot; removeIfClosed(); }

                        // clear the whole stack: fade out in place, then the list closes up, then remove for real
                        property bool closing: false
                        property var clearing: []
                        function clearAll() {
                            if (closing) return;
                            closing = true;
                            arrive.halt();
                            clearing = items.map(x => x.nid);       // only what is on screen now
                            vanish.start();
                        }
                        FrameAnim {
                            id: vanish
                            target: grp; property: "shade"; to: 0; duration: Theme.ms(NcLib.clearFadeMs)
                            onFinished: grp.closeUp()
                        }
                        // removed once the spring has landed on 0: a timer of the spring's length fired a frame early, with
                        // the group still 0.06 pt tall, which the layout rounded up to 1 pt (a 1 pt jump at the end, mcap)
                        function closeUp() { slotAnim.spring = NcLib.clearSpring; slotAnim.go(0); }
                        property bool removed: false
                        function removeIfClosed() {
                            if (!closing || slot > 0 || removed) return;
                            removed = true;
                            Qt.callLater(() => grp.clearing.forEach(id => Notifs.dismiss(id)));
                        }
                        Connections {
                            target: nc
                            function onClearStack(app) { if (app === grp.app) grp.clearAll(); }
                        }

                        // header of an unfolded stack: the app name fades with the fold, the buttons appear and go at
                        // once (PC #62 3d/3e); their glass waits until the front card has slid below them (touching
                        // compositor glass shapes merge into one box)
                        RowLayout {
                            width: parent.width
                            height: nc.headerHeight
                            visible: grp.ex > 0.01
                            spacing: Theme.nc.pillGap
                            Text {
                                Layout.fillWidth: true
                                Layout.leftMargin: 4
                                opacity: Math.max(0, (grp.ex - 0.4) / 0.6)
                                text: grp.app
                                elide: Text.ElideRight
                                font: Typography.font(15, Typography.semibold)
                                color: Theme.color.label
                            }
                            // while the x asks "Clear", Show less is a 20 pt circle with chevron.up
                            // (NotificationCenter 27.2.1 sub_1000700d8: Image(systemName: "chevron.up") in a 20 x 20
                            // frame when its Bool binding is set, else Text("Show less"); Q-panels-32: it shrinks to a
                            // circle while the x reads "Clear")
                            Pill {
                                text: grp.confirmClear ? "" : "Show less"
                                symbol: grp.confirmClear ? "chevron.up" : ""
                                implicitHeight: Theme.nc.pillSmall
                                visible: grp.open
                                glass: grp.cardY(0) >= nc.headerHeight
                                onActivated: nc.setExpanded(grp.app, false)
                            }
                            // the x turns into a "Clear" capsule first; a second click clears the group (Q-panels-32)
                            Pill {
                                symbol: grp.confirmClear ? "" : "xmark"
                                text: grp.confirmClear ? "Clear" : ""
                                implicitHeight: Theme.nc.pillSmall
                                visible: grp.open
                                glass: grp.cardY(0) >= nc.headerHeight
                                onActivated: if (grp.confirmClear) grp.clearAll(); else grp.confirmClear = true
                            }
                        }

                        Repeater {
                            id: cards
                            model: grp.items
                            delegate: NotifCard {
                                id: c
                                required property var modelData
                                required property int index
                                readonly property bool front: index === 0
                                // past the third card nothing peeks: those stay hidden until unfolded
                                readonly property real reveal: front ? 1 : index > 2 ? Math.max(0, (grp.ex - 0.5) / 0.5) : Math.max(0, (grp.ex - 0.15) / 0.6)
                                width: nc.width
                                y: grp.cardY(index)
                                z: -index
                                // grows from its plate (inset 17 / 24 pt per side) as it unfolds
                                scale: front ? 1 : 1 - Theme.notif.plateInset[Math.min(index, 2) - 1] * 2 / width * (1 - grp.ex)
                                transformOrigin: Item.Bottom
                                // keep the glass 1 px below the card above while unfolding (scale is about the bottom)
                                glassTop: front ? 0 : Math.max(0, (grp.cardY(index - 1) + grp.h(index - 1) + 1 - y - height * (1 - scale)) / Math.max(scale, 0.01))
                                visible: front || grp.ex > 0.01
                                opacity: grp.shade
                                materialize: grp.shade
                                nid: modelData.nid
                                appName: modelData.appName
                                appIcon: modelData.appIcon
                                image: modelData.image || ""
                                summary: modelData.summary
                                body: modelData.body
                                time: modelData.time
                                shadow: false
                                // stacked behind the first card its glass region would merge into one box
                                glass: grp.shade > 0 && (front || grp.ex > 0.05) && nc.fits(c, nc.layoutTick + y)
                                contentOpacity: Math.min(1, reveal)
                                stacked: front && grp.ex < 0.05 ? Math.max(0, Math.min(grp.n - 1, 2)) : 0
                                swipeable: front || grp.open
                                buttonHost: nc.buttonHost
                                sx: nc.originX + nc.slideX + x
                                sy: nc.originY + grp.y + y - flick.contentY
                                Component.onCompleted: grp.measure()
                                onImplicitHeightChanged: grp.measure()
                                onClicked: {
                                    if (grp.n > 1 && !grp.open) { nc.setExpanded(grp.app, true); return; }
                                    Notifs.invokeDefault(nid);
                                    Panels.close();
                                }
                                // the close button: a single card or a collapsed stack fades in place and the list closes
                                // up (PC #62 3g); it used to slide out first, which held the list ~0.32 s (mcap)
                                onClosed: grp.open ? swipeAway() : grp.clearAll()
                                onSwiped: grp.open ? Notifs.dismiss(nid) : grp.clearAll()
                            }
                        }
                    }
                }

                }

                // widgets: medium Calendar (month grid left, Up Next right), small analog Clock. "Dark" widget style
                // in light and dark appearance alike (PC #62 1b)
                Widget {
                    Layout.preferredWidth: Theme.nc.width
                    gradient: Gradient {
                        GradientStop { position: 0; color: Theme.nc.calendarTop }
                        GradientStop { position: 1; color: Theme.nc.calendarBottom }
                    }
                    // the Calendar's content fades in with the open (PC #62 2b: alpha tracks openProgress), not on close
                    Item {
                    anchors.fill: parent
                    opacity: nc.shown ? nc.slide : 1
                    // left half: month name and grid, today in a red circle
                    Column {
                        x: Theme.nc.widgetPadding
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.nc.monthGap * 2
                        Text {
                            text: Qt.formatDate(clock.date, "MMMM").toUpperCase()
                            font: Typography.font(Theme.font.widgetSmall, Typography.semibold)
                            color: Theme.color.red
                        }
                        Grid {
                            id: month
                            // ints change once a day/month, so the seconds clock does not rebuild it
                            readonly property int year: clock.date.getFullYear()
                            readonly property int mon: clock.date.getMonth()
                            readonly property int today: clock.date.getDate()
                            // The week starts where the region's does, as on the Mac (it follows the Region setting: the
                            // reference Mac, en_GB with region Indonesia, starts on Sunday, nc/widgets-light-white.png).
                            // Here: the locale of LC_TIME / LANG (Qt.locale(); en_US: Sunday, en_GB / de_DE: Monday).
                            // Qt's firstDayOfWeek is 1 = Monday .. 7 = Sunday, JS getDay() 0 = Sunday .. 6 = Saturday.
                            readonly property var loc: Qt.locale()
                            readonly property int first: loc.firstDayOfWeek % 7
                            readonly property int lead: (new Date(year, mon, 1).getDay() - first + 7) % 7
                            readonly property int days: new Date(year, mon + 1, 0).getDate()
                            // narrow names from the locale (S M T W T F S), in column order
                            readonly property var dayNames: [0, 1, 2, 3, 4, 5, 6].map(c => loc.dayName((first + c) % 7, Locale.NarrowFormat))
                            // the locale's weekend (days not in weekDays) is grey like the header row (Mac crop: Sat, Sun)
                            function weekend(column) { return loc.weekDays.indexOf((first + column) % 7 || 7) === -1; }
                            columns: 7
                            columnSpacing: Theme.nc.monthGap
                            rowSpacing: Theme.nc.monthGap / 2
                            Repeater {
                                model: 7 + month.lead + month.days
                                delegate: Item {
                                    required property int index
                                    readonly property bool isHeader: index < 7
                                    readonly property int day: index - 7 - month.lead + 1
                                    readonly property bool isToday: day === month.today
                                    width: Theme.nc.monthCell
                                    height: Theme.nc.monthCell
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        radius: width / 2
                                        color: Theme.color.red
                                        visible: parent.isToday
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.isHeader ? month.dayNames[parent.index] : parent.day > 0 ? parent.day : ""
                                        font: Typography.font(Theme.font.widgetMonth, parent.isHeader ? Typography.semibold : Typography.regular)
                                        color: parent.isToday ? Theme.nc.onImage
                                             : parent.isHeader || month.weekend(parent.index % 7) ? Theme.nc.widgetSecondary : Theme.nc.widgetLabel
                                    }
                                }
                            }
                        }
                    }
                    // right half: Up Next with today's date (no calendar source, so no events)
                    Column {
                        x: parent.width * Theme.nc.upNextSplit
                        width: parent.width * (1 - Theme.nc.upNextSplit) - Theme.nc.widgetPadding
                        y: Theme.nc.widgetPadding - 2
                        Text {
                            text: Qt.formatDate(clock.date, "dddd").toUpperCase()
                            font: Typography.font(Theme.font.widgetSmall, Typography.semibold)
                            color: Theme.color.red
                        }
                        Text {
                            text: clock.date.getDate()
                            font: Typography.font(Theme.font.widgetBig)
                            color: Theme.nc.widgetLabel
                        }
                        Text {
                            width: parent.width
                            topPadding: Theme.nc.upNextGap
                            wrapMode: Text.WordWrap
                            text: "No more events today"
                            font: Typography.font(Theme.font.widgetSmall + 1, Typography.medium)
                            color: Theme.nc.widgetSecondary
                        }
                    }
                    }
                }
                Widget {
                    color: Theme.nc.clockBg
                    // analog clock face
                    Rectangle {
                        id: face
                        anchors.centerIn: parent
                        width: parent.width - 20
                        height: width
                        radius: width / 2
                        color: Theme.nc.clockFace
                        Repeater {
                            model: 12
                            Rectangle {
                                required property int index
                                x: face.width / 2 - width / 2
                                y: 6
                                width: 3
                                height: 11
                                radius: 1.5
                                color: Qt.rgba(0, 0, 0, 0.3)
                                transform: Rotation { origin.x: 1.5; origin.y: face.height / 2 - 6; angle: index * 30 }
                            }
                        }
                        Hand { len: face.width * 0.27; thick: 5; angle: (clock.hours % 12 + clock.minutes / 60) * 30; color: Theme.nc.clockHand }
                        Hand { len: face.width * 0.40; thick: 4; angle: clock.minutes * 6; color: Theme.nc.clockHand }
                        Hand { len: face.width * 0.44; thick: 1.5; angle: clock.seconds * 6; color: Theme.nc.clockSecond }
                        Rectangle { anchors.centerIn: parent; width: 7; height: 7; radius: 3.5; color: Theme.nc.clockSecond }
                    }
                }

                // Photos widget: a picture from ~/Pictures, the wallpaper when there is none
                Widget {
                    Layout.preferredWidth: Theme.nc.width
                    Layout.preferredHeight: Theme.nc.width * Theme.nc.photoAspect
                    color: Theme.glass.solid
                    ClippingRectangle {
                        anchors.fill: parent
                        radius: Theme.nc.widgetRadius
                        color: "transparent"
                        Image {
                            anchors.fill: parent
                            // decoded once and kept (about 1 MB): loading it on open left the card
                            // black for the first 3 to 5 frames of the slide-in (PERF.md)
                            source: nc.photo ? "file://" + nc.photo : Wallpaper.url
                            sourceSize.width: Wallpaper.thumbWidth * 2
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.55; color: "transparent" }
                                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, Theme.nc.photoScrim) }
                            }
                        }
                    }
                    Column {
                        x: Theme.nc.widgetPadding
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Theme.nc.widgetPadding
                        Text {
                            text: nc.photoTitle
                            // SF Pro here is a variable font: Bold is synthesised (smeared outline), Semibold is a real instance
                            font: Typography.font(Theme.font.widgetPhotoTitle, Typography.semibold)
                            color: Theme.nc.onImage
                        }
                        Text {
                            text: Qt.formatDate(clock.date, "MMM d, yyyy").toUpperCase()
                            font: Typography.font(Theme.font.widgetSmall, Typography.semibold)
                            color: Theme.nc.onImageSecondary
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Theme.nc.editGap - content.spacing
                    spacing: Theme.nc.pillGap
                    Pill { text: "Edit Widgets" }
                    Pill { symbol: "xmark"; onActivated: Panels.close() }
                }
            }
        }
    }

    SystemClock { id: clock; precision: SystemClock.Seconds; enabled: Panels.open === "nc" }

    component Widget: Rectangle {
        Layout.preferredWidth: Theme.nc.widgetSmall
        Layout.preferredHeight: Theme.nc.widgetSmall
        radius: Theme.nc.widgetRadius
    }

    component Hand: Rectangle {
        id: hand
        property real len
        property real thick
        property real angle
        x: face.width / 2 - thick / 2
        y: face.height / 2 - len
        width: thick
        height: len
        radius: thick / 2
        antialiasing: true
        transform: Rotation { origin.x: hand.thick / 2; origin.y: hand.len; angle: hand.angle }
    }

    // glass capsule (text) or circle (symbol) with a grey lift so it stays visible over white windows
    component Pill: Item {
        id: pill
        property string text
        property string symbol
        property bool glass: true
        signal activated()
        implicitWidth: symbol ? implicitHeight : pt.implicitWidth + 20
        implicitHeight: Theme.nc.pillHeight
        Glass {
            anchors.fill: parent
            // the list clips its content, the compositor glass does not: no glass while scrolled out
            visible: pill.glass && nc.fits(pill, nc.layoutTick)
            host: nc.buttonHost
            radius: height / 2
            pluginLift: pma.pressed ? Theme.nc.pillPress : "transparent"
            shadow: false
            // fallback material samples the wallpaper at its screen position
            readonly property point pos: nc.layoutTick > -1e9 ? pill.mapToItem(null, 0, 0) : Qt.point(0, 0)
            sx: nc.originX + pos.x
            sy: nc.originY + pos.y
        }
        Text {
            id: pt
            visible: !pill.symbol
            anchors.centerIn: parent
            text: pill.text
            font: Typography.font(12, Typography.medium)
            color: Theme.color.label
        }
        Symbol { visible: !!pill.symbol; anchors.centerIn: parent; name: pill.symbol || "xmark"; surface: "nc"; size: 12; color: Theme.color.label }
        MouseArea { id: pma; anchors.fill: parent; hoverEnabled: true; onClicked: pill.activated() }
    }
}
