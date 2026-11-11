import QtQuick
import Quickshell
import Quickshell.Wayland

// One session lock surface per screen (created by Lock's WlSessionLock while locked, destroyed on
// unlock). Static: nothing animates or redraws here while idle except the clock once a minute and
// the caret for a few seconds after a key. Keys from any screen go to Lock.key.
WlSessionLockSurface {
    id: s
    color: "black"

    LockContent {
        anchors.fill: parent
        primary: Lock.isMain(s.screen)
        output: s.screen
        interactive: true
        focus: true
        Keys.onPressed: event => { event.accepted = Lock.key(event); }
        Keys.onReleased: event => Lock.keyReleased(event)
        Component.onCompleted: forceActiveFocus()
    }
}
