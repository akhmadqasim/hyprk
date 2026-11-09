import QtQuick
import Quickshell.Io

// Watches one file with inotify (Quickshell only). Emits "" when it is missing.
FileView {
    id: fv
    signal changed(string text)
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: fv.changed(fv.text())
    onLoadFailed: fv.changed("")
}
