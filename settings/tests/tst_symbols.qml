import QtQuick
import QtTest
import "../HyprK"
import "../HyprK/sfpaths.js" as Sf

// Every SF Symbol Settings names is in HyprK/sfpaths.js (decoded outlines, no icon font) and has an ink box.
// Run: QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_symbols.qml
Item {
    width: 200; height: 100
    SfSymbol { id: chev; name: "chevron.forward"; weight: "semibold"; pointSize: 10.5 }
    SfSymbol { id: bars; name: "wifi.var-50" }
    SfSymbol { id: bed; name: "bed.double.fill"; pointSize: 13 }
    SfSymbol { id: play; name: "play.circle"; pointSize: 16.5 }
    TestCase {
        name: "SettingsSymbols"
        when: windowShown
        function test_names() {
            const used = ["chevron.forward", "chevron.backward", "chevron.forward.semibold", "chevron.backward.semibold", "checkmark",
                          "person.fill", "lock.fill", "wifi", "wifi.var-50", "wifi.var-20", "magnifyingglass", "square.on.square",
                          "square.and.arrow.up", "ellipsis", "capsule.on.rectangle.fill", "capsule.on.rectangle.liquid.glass",
                          "person.2.fill", "cloud.fill", "play.circle", "info.circle", "bluetooth.slash", "moon.fill",
                          "bed.double.fill", "person.lanyardcard.fill", "speaker.fill", "speaker.wave.3.fill", "sun.min.fill",
                          "sun.max.fill", "chevron.up.chevron.down.semibold",
                          // the Accessibility sub-panes (panes/accessibility/parts)
                          "plus", "minus", "clock", "chevron.down", "chevron.up", "ellipsis.circle", "tortoise.fill", "hare.fill"];
            for (const n of used) {
                const w = n.endsWith(".semibold") ? "semibold" : "regular";
                const g = Sf.get(w === "semibold" ? n.slice(0, -9) : n, w);
                verify(g !== null, n);
                verify(g.d.length > 0 && g.rect[2] > 0 && g.rect[3] > 0, n);
            }
            compare(Sf.get("no.such.symbol"), null);
        }
        // the Accessibility rows' chevron: 5.5 x 9.4 pt ink on the Mac (accessibility-light.png)
        function test_row_chevron() {
            fuzzyCompare(chev.width, 5.5, 0.1);
            fuzzyCompare(chev.height, 9.4, 0.1);
        }
        // an outline kept at another size than 32 pt (the Mac's 18 pt render) draws at the size asked for
        function test_other_size() {
            compare(Sf.get("bed.double.fill").pt, 18);
            fuzzyCompare(bed.width, 22.5 * 13 / 18, 0.01);
            fuzzyCompare(play.width, 16.5, 0.01);   // play.circle: 33 px on sound-light.png
        }
        // variable symbols carry the dimmed layers: wifi at 0.5 = two bars, the outer arc at 0.3
        function test_variable() {
            compare(Sf.get("wifi.var-50").o, [1, 1, 0.3]);
            compare(Sf.get("wifi.var-20").o, [1, 0.3, 0.3]);
            verify(bars.width > 0);
        }
    }
}
