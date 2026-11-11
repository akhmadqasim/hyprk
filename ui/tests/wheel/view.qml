import QtQuick
import "../../HyprK"

// Fixture for tst_wheel.cpp: a virtualised ListView with RubberBand, and a plain Qt Flickable for comparison.
Item {
    width: 400; height: 300
    ListView {
        id: list
        objectName: "list"
        width: 200; height: 300
        model: 1000
        boundsBehavior: Flickable.StopAtBounds
        delegate: Rectangle { width: 200; height: 20; color: index % 2 ? "#eee" : "#ddd" }
        RubberBand { objectName: "rb"; flickable: list }
    }
    Flickable {
        objectName: "plain"
        x: 200; width: 200; height: 300
        contentHeight: 3000
        boundsBehavior: Flickable.OvershootBounds
        Rectangle { width: 200; height: 3000; color: "#ccc" }
    }
}
