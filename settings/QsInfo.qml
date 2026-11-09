import QtQuick
import Quickshell

// Quickshell-only facts (Backend loads it dynamically; absent under `qml`).
QtObject {
    readonly property string shellDir: Quickshell.shellDir
}
