import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs
import qs.components
import qs.services
import qs.HyprK

// Notification Center (macOS 27): grouped notifications on top, widgets below.
// Motion: the whole column slides in from the right screen edge and back out on close (springs fitted
// to MAC-ANSWERS.md R2 (27.2.1), see openSpring).
// Groups: one card per app with the edges of up to two more peeking below; a click
// unfolds the stack (cards glide down from behind the first, header with the app
// name, Show Less and a clear button fades in), Show Less folds it back. Hover shows
// a close button; swipe right or close clears a card (or a collapsed stack).
Item {
    id: nc

    property real originX: 0
    property real originY: 0
    property real maxHeight: 800

    width: Theme.nc.width
    height: Math.min(maxHeight, flick.contentHeight - nc.bleed)
    // the list is clipped for scrolling; this much room around it keeps the close buttons whole
    readonly property int bleed: 12

    readonly property int headerHeight: 28
    readonly property int cardGap: 8
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
    function settle() { const w = QsWindow.window; if (w && w.settleGlass) w.settleGlass(); }
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
    // false on the Overlays of the other screens, so they do not slide a copy in and out
    property bool onThisScreen: true
    readonly property bool shown: Panels.open === "nc" && onThisScreen
    readonly property bool animating: openSpring.moving
    readonly property real progress: openSpring.value   // 0 off-screen .. 1 open (Overlay: glass materialize)
    // value = share of the panel on screen (0 = its left edge at the screen edge). Reduce motion: fades
    readonly property real slideX: Theme.travel((1 - openSpring.value) * (nc.width + Theme.nc.marginRight))
    // MAC-ANSWERS.md R2 (27.2.1), share on screen per 17 ms frame:
    //   open  0.11 0.14 0.29 0.43 0.54 0.64 0.71 0.78 0.83 0.87 0.90 0.92 0.94 ... 0.99 (~0.3 s, ease-out,
    //         no overshoot): spring response 0.30, damping 1.0 fits within 0.012 RMS (OutCubic 330 ms: 0.025)
    //   close 0.92 0.80 0.66 0.50 0.41 0.28 0.20 0.14 0.11 then gone (~0.15 s): spring response 0.295,
    //         damping 0.85 fits within 0.011 RMS; the spring would take another ~0.1 s to creep the
    //         last 10 % off screen, so like the Mac the panel is gone once less than 0.1 shows
    // The panel only slides: its glass is at full material all the way (Overlay.qml).
    Spring {
        id: openSpring
        onStarted: nc.settle()
        onValueChanged: {
            if (!moving) return;
            if (!nc.shown && target === 0 && value < 0.1) snap();
            else nc.settle();
        }
    }
    onShownChanged: {
        openSpring.response = shown ? 0.30 : 0.295;
        openSpring.damping = shown ? 1.0 : 0.85;
        openSpring.target = shown ? 1 : 0;
        if (shown) refresh();
        else expanded = ({});         // macOS reopens with every stack collapsed
    }

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
        opacity: Theme.reduceMotion ? Math.max(0, Math.min(1, openSpring.value)) : 1

        Flickable {
            id: flick
            x: -nc.bleed
            y: -nc.bleed
            width: nc.width + nc.bleed
            height: nc.height + nc.bleed
            contentHeight: content.implicitHeight + nc.bleed
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            onContentYChanged: nc.settle()

            ColumnLayout {
                id: content
                x: nc.bleed
                y: nc.bleed
                width: nc.width
                spacing: Theme.nc.spacing

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: groupModel.count > 0
                    spacing: nc.cardGap
                Repeater {
                    model: groupModel
                    delegate: Item {
                        id: grp
                        required property string app
                        // reassigned only when this app's notifications change, so the other
                        // stacks keep their cards (a drag or hover is not cut off by a new arrival)
                        property var items: []
                        function syncItems() {
                            const next = nc.itemsByApp[app] || [];
                            if (next.map(x => x.nid).join() !== items.map(x => x.nid).join()) items = next;
                        }
                        Component.onCompleted: syncItems()
                        Connections {
                            target: nc
                            function onItemsByAppChanged() { grp.syncItems(); }
                        }
                        readonly property int n: items.length
                        readonly property bool open: n > 1 && nc.expanded[app] === true
                        property bool closing: false
                        property var heights: []
                        function measure() {
                            const h = [];
                            for (let i = 0; i < cards.count; i++) h.push(cards.itemAt(i) ? cards.itemAt(i).implicitHeight : 0);
                            heights = h;
                        }
                        function h(i) { return heights[i] || Theme.notif.iconSize + Theme.notif.padding * 2; }
                        function openY(i) {
                            let y = nc.headerHeight + nc.cardGap;
                            for (let k = 0; k < i; k++) y += h(k) + nc.cardGap;
                            return y;
                        }
                        function cardY(i) { return closedY(i) + (openY(i) - closedY(i)) * ex; }
                        // behind the first card, bottom edges where its peek strips are drawn
                        function closedY(i) { return i === 0 ? 0 : h(0) - h(i) + Math.min(i, 2) * Theme.notif.stackPeek; }
                        readonly property real closedHeight: h(0) + Math.min(n - 1, 2) * Theme.notif.stackPeek
                        readonly property real openHeight: n > 1 ? openY(n - 1) + h(n - 1) : h(0)
                        // one spring drives the whole fold: 0 stacked, 1 unfolded
                        Spring {
                            id: fold
                            target: grp.open ? 1 : 0
                            onStarted: nc.settle()
                        }
                        readonly property real ex: fold.value
                        // shrinks the stack while it is cleared (idle otherwise)
                        Spring {
                            id: size
                            epsilon: 0.3
                            onStarted: nc.settle()
                        }
                        // follow the fold exactly while it runs, so content below moves with the cards
                        readonly property real liveHeight: grp.closing ? size.value
                            : closedHeight + (openHeight - closedHeight) * ex
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(0, liveHeight)
                        // while clearing, the gap below closes with the height
                        property real startHeight: 1
                        readonly property real remain: grp.closing ? Math.max(0, size.value) / startHeight : 1
                        Layout.bottomMargin: -nc.cardGap * (1 - remain)
                        opacity: remain
                        onLiveHeightChanged: nc.settle()

                        // clear the whole stack: shrink and fade, then remove for real
                        function clearAll() {
                            if (closing) return;
                            startHeight = Math.max(1, liveHeight);   // also mid-fold: no jump
                            size.target = startHeight;
                            size.snap();
                            closing = true;
                            size.target = 0;
                            clearing = items.map(x => x.nid);       // only what is on screen now
                            clearLater.start();
                        }
                        property var clearing: []
                        Timer { id: clearLater; interval: 380; onTriggered: grp.clearing.forEach(id => Notifs.dismiss(id)) }
                        Connections {
                            target: nc
                            function onClearStack(app) { if (app === grp.app) grp.clearAll(); }
                        }

                        // header of an unfolded stack
                        RowLayout {
                            width: parent.width
                            height: nc.headerHeight
                            opacity: Math.max(0, (grp.ex - 0.4) / 0.6)
                            visible: opacity > 0.01
                            Text {
                                Layout.fillWidth: true
                                Layout.leftMargin: 4
                                text: grp.app
                                elide: Text.ElideRight
                                font.family: Theme.fontText
                                font.pixelSize: 15
                                font.weight: Theme.font.semibold
                                color: Theme.color.label
                            }
                            // no glass until the front card has slid below the header (overlapping
                            // regions would merge into one box)
                            Pill { text: "Show Less"; glass: grp.cardY(0) >= nc.headerHeight; onActivated: nc.setExpanded(grp.app, false) }
                            Pill { symbol: "xmark"; glass: grp.cardY(0) >= nc.headerHeight; onActivated: grp.clearAll() }
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
                                scale: front ? 1 : 1 - Math.min(index, 2) * 0.045 * (1 - grp.ex)
                                transformOrigin: Item.Bottom
                                // keep the glass 1 px below the card above while unfolding (scale is about the bottom)
                                glassTop: front ? 0 : Math.max(0, (grp.cardY(index - 1) + grp.h(index - 1) + 1 - y - height * (1 - scale)) / Math.max(scale, 0.01))
                                visible: front || grp.ex > 0.01
                                nid: modelData.nid
                                appName: modelData.appName
                                appIcon: modelData.appIcon
                                image: modelData.image || ""
                                summary: modelData.summary
                                body: modelData.body
                                time: modelData.time
                                shadow: false
                                // stacked behind the first card its glass region would merge into one box
                                glass: !grp.closing && (front || grp.ex > 0.05) && nc.fits(c, nc.layoutTick + y)
                                contentOpacity: Math.min(1, reveal)
                                stacked: front && grp.ex < 0.05 && !grp.closing ? Math.min(grp.n - 1, 2) : 0
                                swipeable: front || grp.open
                                sx: nc.originX + nc.slideX + x
                                sy: nc.originY + grp.y + y - flick.contentY
                                Component.onCompleted: grp.measure()
                                onImplicitHeightChanged: grp.measure()
                                onClicked: {
                                    if (grp.n > 1 && !grp.open) { nc.setExpanded(grp.app, true); return; }
                                    Notifs.invokeDefault(nid);
                                    Panels.close();
                                }
                                onClosed: grp.n > 1 && !grp.open ? grp.clearAll() : swipeAway()
                                onSwiped: grp.open ? Notifs.dismiss(nid) : grp.clearAll()
                            }
                        }
                    }
                }

                }

                // widgets: medium Calendar (month grid left, Up Next right), small analog Clock
                Widget {
                    Layout.preferredWidth: Theme.nc.width
                    color: Theme.nc.calendarBg
                    // left half: month name and grid, today in a red circle
                    Column {
                        x: Theme.nc.widgetPadding
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.nc.monthGap * 2
                        Text {
                            text: Qt.formatDate(clock.date, "MMMM").toUpperCase()
                            font.family: Theme.fontText
                            font.pixelSize: Theme.font.widgetSmall
                            font.weight: Theme.font.semibold
                            color: Theme.color.red
                        }
                        Grid {
                            id: month
                            // ints change once a day/month, so the seconds clock does not rebuild it
                            readonly property int year: clock.date.getFullYear()
                            readonly property int mon: clock.date.getMonth()
                            readonly property int today: clock.date.getDate()
                            readonly property int lead: (new Date(year, mon, 1).getDay() + 6) % 7   // weeks start on Monday
                            readonly property int days: new Date(year, mon + 1, 0).getDate()
                            readonly property var dayNames: ["M", "T", "W", "T", "F", "S", "S"]
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
                                        font.family: Theme.fontText
                                        font.pixelSize: Theme.font.widgetMonth
                                        font.weight: parent.isHeader ? Theme.font.semibold : Theme.font.regular
                                        color: parent.isToday ? Theme.nc.onImage : parent.isHeader ? Theme.color.secondaryLabel : Theme.color.label
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
                            font.family: Theme.fontText
                            font.pixelSize: Theme.font.widgetSmall
                            font.weight: Theme.font.semibold
                            color: Theme.color.red
                        }
                        Text {
                            text: clock.date.getDate()
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.font.widgetBig
                            color: Theme.color.label
                        }
                        Text {
                            width: parent.width
                            topPadding: Theme.nc.upNextGap
                            wrapMode: Text.WordWrap
                            text: "No more events today"
                            font.family: Theme.fontText
                            font.pixelSize: Theme.font.widgetSmall + 1
                            font.weight: Theme.font.medium
                            color: Theme.color.secondaryLabel
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
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.font.widgetPhotoTitle
                            // SF Pro here is a variable font: Bold is synthesised (smeared outline), Semibold is a real instance
                            font.weight: Theme.font.semibold
                            color: Theme.nc.onImage
                        }
                        Text {
                            text: Qt.formatDate(clock.date, "MMM d, yyyy").toUpperCase()
                            font.family: Theme.fontText
                            font.pixelSize: Theme.font.widgetSmall
                            font.weight: Theme.font.semibold
                            color: Theme.nc.onImageSecondary
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8
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
        implicitHeight: 24
        Glass {
            anchors.fill: parent
            // the list clips its content, the compositor glass does not: no glass while scrolled out
            visible: pill.glass && nc.fits(pill, nc.layoutTick)
            radius: height / 2
            tint: Theme.nc.pillLift
            pluginLift: pma.pressed ? Qt.darker(Theme.nc.pillLift, 1.4) : pma.containsMouse ? Qt.lighter(Theme.nc.pillLift, 1.25) : Theme.nc.pillLift
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
            font.family: Theme.fontText
            font.pixelSize: 12
            font.weight: Theme.font.medium
            color: Theme.color.label
        }
        Symbol { visible: !!pill.symbol; anchors.centerIn: parent; name: pill.symbol || "xmark"; size: 12; color: Theme.color.label }
        MouseArea { id: pma; anchors.fill: parent; hoverEnabled: true; onClicked: pill.activated() }
    }
}
