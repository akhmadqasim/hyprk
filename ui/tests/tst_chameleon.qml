import QtQuick
import QtTest
import "../HyprK"
import "../HyprK/chameleon.js" as Ch

// Sidebar chameleon tint (MAC-ANSWERS.md C3.1) and the wallpaper mean that feeds it.
Item {
    width: 100; height: 100
    WallpaperTint { id: wt }
    TestCase {
        name: "Chameleon"
        when: windowShown
        function test_quantise() {
            compare(Ch.quantise(0), 0);
            compare(Ch.quantise(1), 1);                 // trunc(64) capped at 63 -> 63/63
            compare(Ch.quantise(0.5), 32 / 63);
        }
        function test_apply() {
            const f = { r: 0.137, g: 0.149, b: 0.204 };  // Settings dark sidebar #232634
            const same = Ch.apply(f, null, true);
            compare(same.r, f.r);
            // a grey tint at the sidebar's luminance is the sidebar's grey: only the hue moves the result
            const grey = Ch.apply(f, { r: 0.5, g: 0.5, b: 0.5 }, true);
            const l = Ch.lum(f);
            fuzzyCompare(grey.r, f.r + (l - f.r) * 0.10, 1e-9);
            // light blends 5 %: a pure blue tint pulls blue up and keeps luminance near f's
            const w = { r: 0.925, g: 0.929, b: 0.933 };
            const blue = Ch.apply(w, { r: 0, g: 0, b: 1 }, false);
            verify(blue.b > w.b);
            fuzzyCompare(Ch.lum(blue), Ch.lum(w), 0.01);
            // clipColor keeps every channel in 0..1
            const c = Ch.setLum({ r: 1, g: 0, b: 0 }, 0.9);
            verify(c.r <= 1 && c.g >= 0 && c.b >= 0);
            fuzzyCompare(Ch.lum(c), 0.9, 1e-9);
        }
        function test_wallpaperMean() {
            wt.path = Qt.resolvedUrl("../../themes/wallpapers/png/Mac Blue.png");
            tryVerify(() => wt.tint !== null, 5000);
            verify(wt.tint.b > wt.tint.r);   // a blue wallpaper averages blue
            compare(Math.round(wt.tint.b * 63), wt.tint.b * 63);   // 6-bit steps
        }
    }
}
