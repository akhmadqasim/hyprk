import QtQuick
import QtQuick.Window

// Entry for the plain Qt `qml` tool (no command backend; panes show their
// fallback states). Real runtime: shell.qml under Quickshell.
Window {
    id: win
    width: Theme.window.width; height: Theme.window.height
    minimumWidth: Theme.window.minWidth; minimumHeight: Theme.window.minHeight
    visible: true
    title: "System Settings"
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"

    SettingsApp {
        anchors.fill: parent
        // --pane=<id>, --snapshot=<file.png>
        currentId: Qt.application.arguments.find(a => a.startsWith("--pane="))?.slice(7) ?? "appearance"
        snapshotPath: Qt.application.arguments.find(a => a.startsWith("--snapshot="))?.slice(11) ?? ""
        windowActive: win.active
        onCloseRequested: Qt.quit()
        onMinimizeRequested: win.showMinimized()
        onZoomRequested: win.visibility === Window.Maximized ? win.showNormal() : win.showMaximized()
        onMoveRequested: win.startSystemMove()
    }

}
