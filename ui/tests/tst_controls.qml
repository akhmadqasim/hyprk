import QtQuick
import QtTest
import HyprK

// Controlled controls: the caller's binding survives a user change.
// Run: QT_QPA_PLATFORM=offscreen qmltestrunner -import ui -input ui/tests
Item {
    id: root
    width: 400; height: 300

    QtObject {
        id: backend
        property bool on: false
        property int index: 0
        property real level: 0.2
    }

    Switch {
        id: sw
        x: 20; y: 20
        checked: backend.on
        onToggled: v => backend.on = v
    }
    Switch {
        id: refusing          // a caller that rejects the change: the switch stays as it was
        x: 20; y: 60
        checked: false
    }
    Popup {
        id: pop
        x: 200; y: 150; width: 120
        model: ["A", "B", "C"]
        currentIndex: backend.index
        onActivated: i => backend.index = i
    }
    Slider {
        id: sl
        x: 20; y: 240; width: 200
        value: backend.level
        onMoved: v => backend.level = v
    }

    SignalSpy { id: toggledSpy; target: refusing; signalName: "toggled" }

    TestCase {
        name: "HyprKControls"
        when: windowShown

        function test_switch_keeps_binding() {
            mouseClick(sw);
            compare(backend.on, true);
            compare(sw.checked, true);
            backend.on = false;              // external change still reaches the switch
            compare(sw.checked, false);
        }
        function test_switch_does_not_write_checked() {
            mouseClick(refusing);
            compare(toggledSpy.count, 1);
            compare(toggledSpy.signalArguments[0][0], true);
            compare(refusing.checked, false);
        }
        function test_popup_keeps_binding() {
            mouseClick(pop);                 // opens the menu (a click leaves it open)
            // the menu is lifted so the current row sits on the button (5 px padding cancels the 5 px lift)
            const row = Tokens.control.menuItemHeight;
            mouseClick(root, pop.x + pop.width - 30, pop.y - pop.currentIndex * row + 2 * row + row / 2);
            compare(backend.index, 2);
            compare(pop.currentIndex, 2);
            backend.index = 1;
            compare(pop.currentIndex, 1);
        }
        function test_slider_keeps_binding() {
            mouseClick(sl, sl.width - 2, sl.height / 2);
            verify(backend.level > 0.9);
            backend.level = 0.5;
            compare(sl.value, 0.5);
        }
    }
}
