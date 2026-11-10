import QtQuick
import QtTest
import HyprK
import "../HyprK/panels.js" as P

// Alert, sheet and popover geometry against the 27.2.1 AppKit probe (reference/re/27.2.1/live/panels/
// panels-alert{2,3}-dark.json, panels-sheetalert-dark.json; MAC-ANSWERS.md Q-panels-33/34).
TestCase {
    name: "HyprKPanels"

    function test_alert_two_buttons() {
        // alert2: 260 x 234, icon 64 at (20,20), 3-line title 48 at y 100, message 16 at y 158,
        // buttons 110 x 28 at x 16 (second) and 134 (default), y 190
        const l = P.alertLayout(2, true, 48, 16);
        compare([l.width, l.height], [260, 234]);
        compare([l.icon.x, l.icon.y, l.icon.width], [20, 20, 64]);
        compare([l.title.x, l.title.y, l.title.width], [20, 100, 220]);
        compare(l.message.y, 158);
        compare([l.buttons[0].x, l.buttons[0].y, l.buttons[0].width, l.buttons[0].height], [134, 190, 110, 28]);
        compare([l.buttons[1].x, l.buttons[1].y], [16, 190]);
    }
    function test_alert_three_buttons_stack() {
        // alert3: 260 x 334, title 32 at 100, message 64 at 142, stack at 222: default, third, second (pitch 34)
        const l = P.alertLayout(3, true, 32, 64);
        compare(l.height, 334);
        compare(l.message.y, 142);
        compare([l.buttons[0].y, l.buttons[2].y, l.buttons[1].y], [222, 256, 290]);
        compare([l.buttons[0].x, l.buttons[0].width], [16, 228]);
    }
    function test_alert_sheet_has_no_icon() {
        // sheet form: 260 x 154, title at y 20
        const l = P.alertLayout(2, false, 48, 16);
        compare(l.icon, null);
        compare([l.title.y, l.height], [20, 154]);
    }
    function test_alert_top() {
        compare(P.alertTop(1113, 234), 231);   // 289.5 - 58.5 on the 1113 pt screen
        compare(P.alertTop(100, 400), 0);
    }
    function test_sheet_centred() {
        compare(P.sheetRect(800, 552, 440, 220), { x: 180, y: 166, width: 440, height: 220 });
    }
    function test_popover_placement() {
        const below = P.popoverPlacement(Qt.rect(400, 8, 38, 36), 252, 99, 920, 560);
        verify(below.below);
        compare(below.y, 8 + 36 + 9);
        compare(below.x + below.arrowX, 419);          // the arrow on the anchor's centre
        const edge = P.popoverPlacement(Qt.rect(900, 8, 20, 36), 252, 99, 920, 560);
        compare(edge.x, 920 - 252 - 8);                  // kept inside the area
        verify(edge.arrowX <= 252 - 20 - 9);            // the arrow clear of the corner
        compare(P.popoverPlacement(Qt.rect(400, 8, 38, 36), 226, 74, 920, 560, 7).y, 44 + 7 + 9);   // Finder tag popover
        const above = P.popoverPlacement(Qt.rect(400, 520, 20, 20), 252, 99, 920, 560);
        verify(!above.below);
        compare(above.y, 520 - 9 - 99);
    }

    Item { id: host; width: 800; height: 552 }
    Component { id: alertC; AlertPanel { title: "T"; message: "M"; buttons: [{ text: "OK" }, { text: "Cancel", cancel: true }] } }
    Component { id: sheetC; Sheet { anchors.fill: parent; cardWidth: 440; cardHeight: 220 } }
    function test_alert_keys() {
        const a = createTemporaryObject(alertC, host);
        const hits = [];
        a.activated.connect(i => hits.push(i));
        a.shown = true;
        keyClick(Qt.Key_Escape);
        keyClick(Qt.Key_Return);
        compare(hits, [1, 0]);
    }
    function test_sheet_card_centred() {
        const s = createTemporaryObject(sheetC, host);
        compare([s.card.x, s.card.y], [180, 166]);
    }
}
