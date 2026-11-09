import QtQuick

// Invisible resize handles along the frameless window's edges and corners.
Item {
    id: root

    required property var window
    readonly property int m: Theme.win.resizeMargin
    enabled: window.visibility !== Window.Maximized && window.visibility !== Window.FullScreen

    component Edge: MouseArea {
        property int edges
        onPressed: root.window.startSystemResize(edges)
    }

    Edge { edges: Qt.LeftEdge; cursorShape: Qt.SizeHorCursor; x: 0; y: root.m; width: root.m; height: root.height - 2 * root.m }
    Edge { edges: Qt.RightEdge; cursorShape: Qt.SizeHorCursor; x: root.width - root.m; y: root.m; width: root.m; height: root.height - 2 * root.m }
    Edge { edges: Qt.TopEdge; cursorShape: Qt.SizeVerCursor; x: root.m; y: 0; width: root.width - 2 * root.m; height: root.m }
    Edge { edges: Qt.BottomEdge; cursorShape: Qt.SizeVerCursor; x: root.m; y: root.height - root.m; width: root.width - 2 * root.m; height: root.m }
    Edge { edges: Qt.LeftEdge | Qt.TopEdge; cursorShape: Qt.SizeFDiagCursor; x: 0; y: 0; width: root.m; height: root.m }
    Edge { edges: Qt.RightEdge | Qt.BottomEdge; cursorShape: Qt.SizeFDiagCursor; x: root.width - root.m; y: root.height - root.m; width: root.m; height: root.m }
    Edge { edges: Qt.RightEdge | Qt.TopEdge; cursorShape: Qt.SizeBDiagCursor; x: root.width - root.m; y: 0; width: root.m; height: root.m }
    Edge { edges: Qt.LeftEdge | Qt.BottomEdge; cursorShape: Qt.SizeBDiagCursor; x: 0; y: root.height - root.m; width: root.m; height: root.m }
}
