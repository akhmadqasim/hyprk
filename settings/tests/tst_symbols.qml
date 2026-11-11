import QtQuick
import QtTest
import "../controls"
import "../controls/sfpaths.js" as Sf

// Every SF Symbol Settings names is in controls/sfpaths.js (decoded outlines, no icon font) and has an ink box.
// Run: QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_symbols.qml
Item {
    width: 200; height: 100
    SfSymbol { id: chev; name: "chevron.forward"; weight: "semibold"; pointSize: 10.5 }
    SfSymbol { id: bars; name: "wifi.var-50" }
    TestCase {
        name: "SettingsSymbols"
        when: windowShown
        function test_names() {
            const used = ["chevron.forward", "chevron.backward", "chevron.forward.semibold", "chevron.backward.semibold", "checkmark",
                          "person.fill", "lock.fill", "wifi", "wifi.var-50", "wifi.var-20", "magnifyingglass", "square.on.square",
                          "square.and.arrow.up", "ellipsis", "capsule.on.rectangle.fill", "capsule.on.rectangle.liquid.glass"];
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
        // variable symbols carry the dimmed layers: wifi at 0.5 = two bars, the outer arc at 0.3
        function test_variable() {
            compare(Sf.get("wifi.var-50").o, [1, 1, 0.3]);
            compare(Sf.get("wifi.var-20").o, [1, 0.3, 0.3]);
            verify(bars.width > 0);
        }
    }
}
