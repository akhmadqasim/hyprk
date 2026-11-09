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
        id: ui
        anchors.fill: parent
        currentId: Qt.application.arguments.find(a => a.startsWith("--pane="))?.slice(7) ?? "appearance"
        windowActive: win.active
        onCloseRequested: Qt.quit()
        onMinimizeRequested: win.showMinimized()
        onZoomRequested: win.visibility === Window.Maximized ? win.showNormal() : win.showMaximized()
        onMoveRequested: win.startSystemMove()
    }

    // --snapshot=<file.png>: render, save, quit (used for reference comparisons).
    readonly property string snapshot: Qt.application.arguments.find(a => a.startsWith("--snapshot="))?.slice(11) ?? ""
    Timer {
        running: win.snapshot !== ""; interval: 4000
        onTriggered: ui.grabToImage(r => { r.saveToFile(win.snapshot); Qt.quit(); })
    }
}
