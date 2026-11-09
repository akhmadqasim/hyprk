import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs
import qs.components
import qs.services

// Notification Center: grouped history on top, widgets below (macOS 26).
Item {
    id: nc

    property real originX: 0
    property real originY: 0
    property real maxHeight: 800

    width: Theme.nc.width
    height: Math.min(maxHeight, flick.contentHeight)

    property var expanded: ({})       // appName -> bool
    property string photo: ""
    // folder name as the caption, like a Photos memory; a loose file in ~/Pictures gets the generic title
    readonly property string photoTitle: {
        const folder = photo ? photo.split("/").slice(-2, -1)[0] : "";
        return folder && folder !== "Pictures" ? folder : "Featured Photo";
    }
    Process {
        // first photo in ~/Pictures (xdg dir, screenshots skipped), once per shell start
        running: true
        command: ["sh", "-c", 'd="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"; find "$d" -maxdepth 2 -type f \\( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \\) -not -ipath "*screenshot*" 2>/dev/null | head -n1']
        stdout: StdioCollector { onStreamFinished: nc.photo = text.trim() }
    }
    property var groups: []
    // regroup only while the panel is open (and when it opens)
    readonly property bool shown: Panels.open === "nc"
    function refresh() { if (shown) groups = Notifs.groups(); }
    onShownChanged: refresh()
    Connections {
        target: Notifs.history
        function onCountChanged() { nc.refresh(); }
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentHeight: content.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        // plugin glass shapes don't follow scrolling by themselves
        onContentYChanged: { const w = QsWindow.window; if (w && w.settleGlass) w.settleGlass(); }

        ColumnLayout {
            id: content
            width: nc.width
            spacing: Theme.nc.spacing

            Repeater {
                model: nc.groups
                delegate: ColumnLayout {
                    id: grp
                    required property var modelData
                    readonly property bool open: nc.expanded[modelData.appName] === true || modelData.items.length === 1
                    Layout.fillWidth: true
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 6
                        Layout.rightMargin: 6
                        visible: grp.open && grp.modelData.items.length > 1
                        Text {
                            Layout.fillWidth: true
                            text: grp.modelData.appName
                            font.family: Theme.fontText
                            font.pixelSize: Theme.font.ccTitle
                            font.weight: Theme.font.semibold
                            color: Theme.color.menuBarText
                        }
                        Pill {
                            text: "Show Less"
                            onActivated: { const e = Object.assign({}, nc.expanded); e[grp.modelData.appName] = false; nc.expanded = e; }
                        }
                        Pill { text: "✕"; onActivated: Notifs.clearApp(grp.modelData.appName) }
                    }

                    Repeater {
                        model: grp.open ? grp.modelData.items : grp.modelData.items.slice(0, 1)
                        delegate: NotifCard {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.bottomMargin: stacked > 0 ? Theme.notif.stackPeek * Math.min(stacked, 2) : 0
                            nid: modelData.nid
                            appName: modelData.appName
                            appIcon: modelData.appIcon
                            summary: modelData.summary
                            body: modelData.body
                            time: modelData.time
                            shadow: false
                            stacked: grp.open ? 0 : grp.modelData.items.length - 1
                            sx: nc.originX + x
                            sy: nc.originY + y - flick.contentY
                            onClicked: {
                                if (!grp.open) {
                                    const e = Object.assign({}, nc.expanded);
                                    e[grp.modelData.appName] = true;
                                    nc.expanded = e;
                                } else Notifs.invokeDefault(nid);
                            }
                            onClosed: Notifs.dismiss(nid)
                        }
                    }
                }
            }

            // widgets: medium Calendar, small analog Clock (macOS defaults)
            Widget {
                Layout.preferredWidth: Theme.nc.width
                color: Theme.nc.calendarBg
                Column {
                    x: Theme.nc.widgetPadding
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
                }
                Text {
                    x: Theme.nc.widgetPadding
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Theme.nc.widgetPadding
                    text: "No events today"
                    font.family: Theme.fontText
                    font.pixelSize: Theme.font.widgetSmall + 1
                    font.weight: Theme.font.medium
                    color: Theme.color.secondaryLabel
                }
                // month grid on the right half, today in a red circle (macOS medium Calendar widget)
                Grid {
                    id: month
                    // ints change once a day/month, so the grid is not rebuilt by the seconds clock
                    readonly property int year: clock.date.getFullYear()
                    readonly property int mon: clock.date.getMonth()
                    readonly property int today: clock.date.getDate()
                    readonly property int lead: (new Date(year, mon, 1).getDay() + 6) % 7   // weeks start on Monday
                    readonly property int days: new Date(year, mon + 1, 0).getDate()
                    readonly property var dayNames: ["M", "T", "W", "T", "F", "S", "S"]
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.nc.widgetPadding
                    anchors.verticalCenter: parent.verticalCenter
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
                        font.weight: Theme.font.bold
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
                Pill { text: "✕"; onActivated: Panels.close() }
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

    // glass capsule with a grey lift so it stays visible over white windows
    component Pill: Glass {
        id: pill
        property string text
        signal activated()
        implicitWidth: pt.implicitWidth + 16
        implicitHeight: 22
        radius: 11
        tint: Theme.nc.pillLift
        pluginLift: Theme.nc.pillLift
        shadow: false
        readonly property point pos: mapToItem(null, 0, 0)
        sx: nc.originX + pos.x
        sy: nc.originY + pos.y
        Text {
            id: pt
            anchors.centerIn: parent
            text: pill.text
            font.family: Theme.fontText
            font.pixelSize: Theme.font.notifApp
            font.weight: Theme.font.medium
            color: Theme.color.label
        }
        MouseArea { anchors.fill: parent; onClicked: pill.activated() }
    }
}
