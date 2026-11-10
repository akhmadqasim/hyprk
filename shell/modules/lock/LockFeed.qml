import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs
import qs.HyprK
import qs.components
import qs.services
import "../../lib/state.js" as State
import "lock.js" as L

// Top-right column on the lock screen: Now Playing (when an MPRIS player is up), then the
// notifications that arrived since the lock (Notifs history, Prefs.notifications rules).
// Position and look are guessed, waiting for Q-lockscreen-20 / -21.
Column {
    id: feed
    property bool interactive: false
    spacing: LockTheme.notifGap
    width: Theme.notif.width

    readonly property var player: State.pickPlayer(Mpris.players.values)

    // history is a ListModel: re-read it when it changes
    property var notifs: []
    function refresh() {
        const rows = [];
        for (let i = 0; i < Notifs.history.count; i++) rows.push(Notifs.history.get(i));
        notifs = L.lockNotifs(rows, Lock.since, LockTheme.notifMax, Prefs.notifications);
    }
    Connections {
        target: Notifs.history
        function onCountChanged() { feed.refresh(); }
    }
    Component.onCompleted: refresh()

    // ---------- Now Playing ----------
    Loader {
        active: feed.player !== null && (feed.player.trackTitle || feed.player.identity)
        visible: active
        width: feed.width
        height: active ? LockTheme.playerHeight : 0
        sourceComponent: Item {
            id: np
            readonly property var p: feed.player
            LockGlass {
                anchors.fill: parent
                radius: LockTheme.notifRadius
                face: LockTheme.cardFace
                solidColor: LockTheme.cardSolid
            }
            ClippingRectangle {
                id: art
                x: (parent.height - height) / 2
                anchors.verticalCenter: parent.verticalCenter
                width: LockTheme.playerArt
                height: LockTheme.playerArt
                radius: 8
                color: Theme.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.08)
                Image {
                    anchors.fill: parent
                    source: np.p ? np.p.trackArtUrl : ""
                    sourceSize: Qt.size(width * 2, height * 2)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
                }
            }
            Column {
                anchors.left: art.right
                anchors.leftMargin: 12
                anchors.right: controls.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    width: parent.width
                    text: np.p ? (np.p.trackTitle || np.p.identity) : ""
                    elide: Text.ElideRight
                    font: Typography.font(Theme.font.notifTitle, Typography.semibold)
                    color: Theme.color.label
                }
                Text {
                    width: parent.width
                    visible: text !== ""
                    text: np.p ? np.p.trackArtist : ""
                    elide: Text.ElideRight
                    font: Typography.body
                    color: Theme.color.secondaryLabel
                }
            }
            Row {
                id: controls
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                Repeater {
                    model: ["backward", "play", "forward"]
                    Item {
                        required property string modelData
                        readonly property var pl: feed.player
                        width: 26
                        height: 26
                        Symbol {
                            anchors.centerIn: parent
                            name: parent.modelData === "play" && parent.pl && parent.pl.isPlaying ? "pause" : parent.modelData
                            size: 18
                            color: Theme.color.label
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: feed.interactive && parent.pl !== null
                            onClicked: {
                                const p = parent.pl;
                                if (parent.modelData === "backward" && p.canGoPrevious) p.previous();
                                else if (parent.modelData === "forward" && p.canGoNext) p.next();
                                else if (parent.modelData === "play" && p.canTogglePlaying) p.togglePlaying();
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------- notifications since the lock ----------
    Repeater {
        model: feed.notifs
        Item {
            id: row
            required property var modelData
            width: feed.width
            height: card.height
            LockGlass {
                anchors.fill: parent
                radius: LockTheme.notifRadius
                face: LockTheme.cardFace
                solidColor: LockTheme.cardSolid
            }
            NotifCard {
                id: card
                width: parent.width
                glass: false                  // LockGlass above: the shell glass samples the desktop
                swipeable: false
                nid: row.modelData.nid
                appName: row.modelData.appName
                appIcon: row.modelData.appIcon
                image: row.modelData.image
                summary: row.modelData.summary
                body: row.modelData.body
                time: row.modelData.time
                onClosed: if (feed.interactive) Notifs.dismiss(nid)
            }
        }
    }
}
