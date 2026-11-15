import QtQuick
import QtTest
import ".."
import "../HyprK"
import "../Parsers.js" as P

// Appearance pane against the 27.2.1 Mac (MAC-ANSWERS.md PC #60, re/27.2.1/live/settings/appearance/layout.json):
// section heights, the Liquid Glass end buttons, wheel scrolling and the overlay scroll bar.
// Run: QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_appearance.qml
// State is never written: the test holds AppState's write timer and checks the queued patch instead.
Item {
    id: root
    width: 740; height: 625

    SettingsApp { id: app; anchors.fill: parent; currentId: "appearance"; windowActive: true }

    TestCase {
        name: "SettingsAppearance"
        when: windowShown

        function initTestCase() {
            AppState.debounce = AppState.appearanceDebounce = 24 * 3600 * 1000;   // never reaches the state file
            AppState.set("appearance", { iconStyle: "dark", iconStyleVariant: "dark", glass: 0.5 });
        }
        function cleanupTestCase() { AppState._flush.stop(); AppState._patches = {}; }
        function flick() { for (const c of app.children) if (c.contentHeight !== undefined) return c; return null; }
        function column() {
            const f = flick();
            for (const c of f.contentItem.children) if (c.item) return c.item;
            return null;
        }
        function heights() {
            const col = column();
            const out = [];
            for (const c of col.children) if (c.visible && c.height > 0 && c.width > 0) out.push(c.height);
            return out;
        }

        // cards 319, heading 30 + 16 + 10 over card 100, card 145.5, heading over card 75, card 189, button row
        // 20 + 24; document 1036.5 under the 52 pt toolbar, 573 visible, max offset 463.5
        function test_a_layout() {
            tryVerify(() => column() !== null && column().height > 900, 3000);
            AppState.set("appearance", { iconStyle: "dark", iconStyleVariant: "dark" });
            tryVerify(() => heights()[2] === 145.5, 1000);
            // a heading's 30 = the column's 10 + its own 20 top padding
            compare(heights(), [319, 20 + 16 + 10 + 100, 145.5, 20 + 16 + 10 + 75, 189, 10 + 24]);
            compare(column().spacing, 10);
            compare(flick().contentHeight, 52 + 1036.5);
            compare(flick().contentHeight - flick().height, 463.5);
            compare(column().mapToItem(app, 0, 0).y, 52 + 12);
            AppState.set("appearance", { iconStyle: "default" });
            tryVerify(() => heights()[2] === 129, 1000);  // no radio row with Default
            AppState.set("appearance", { iconStyle: "dark" });
        }
        // the end buttons step NSGlassTintAmount by -0.1 / +0.1 and the value is written (queued) at once
        function test_b_glass_end_buttons() {
            const sl = findChild(app, "glassSlider");
            verify(sl);
            const right = findChild(sl, "rightEnd"), left = findChild(sl, "leftEnd");
            compare(AppState.appearance.glass, 0.5);
            mouseClick(right);
            fuzzyCompare(AppState.appearance.glass, 0.6, 1e-9);
            fuzzyCompare(AppState._patches.appearance.glass, 0.6, 1e-9);
            mousePress(left);
            verify(left.pressed);                         // pressed state while held
            mouseRelease(left);
            mouseClick(left);
            fuzzyCompare(AppState.appearance.glass, 0.4, 1e-9);
            fuzzyCompare(AppState._patches.appearance.glass, 0.4, 1e-9);
            // the fill runs to the value x the track (the 23.09.23 recording, knob held at both ends)
            verify(sl.fillToEnds);
        }
        // A real drag that brings the knob onto an end bounces that end's glyph by layer: the capsule (layer 0) first,
        // the rectangle 0.05 s later, up to 1.25 then down to 0.90 (the 23.09.23 recording, INTERACTIVE-GLASS-REA.md 8).
        // Held there, pulled further or stepped with the end buttons: no second bounce
        function test_b1_glass_end_glyphs_bounce() {
            const sl = findChild(app, "glassSlider");
            const low = findChild(app, "glassClearBounce"), high = findChild(app, "glassTintedBounce");
            verify(low && high);
            compare(low.layers, 2); compare(high.layers, 2);
            const icon = end => { const p = findChild(sl, end).parent; for (const c of p.children) if (c.item) return c.item; return null; };
            const li = icon("leftEnd"), ri = icon("rightEnd");
            compare(li.name, "capsule.on.rectangle.liquid.glass"); compare(ri.name, "capsule.on.rectangle.fill");
            const track = findChild(sl, "leftEnd").parent.parent.children.filter(c => c.usable !== undefined)[0];
            const y = track.y + track.height / 2;
            const kx = () => track.x + Math.max(10, Math.min(track.width - 10, sl.value * track.width));
            const watch = (b, ic, capsule, rect) => {   // peak and trough of each layer, and when the capsule led
                let pc = 1, pr = 1, tc = 1, tr = 1, led = false;
                for (let t = 0; t < 900; t += 8) {
                    wait(8);
                    const sc = ic.layerScales[capsule] ?? 1, sr = ic.layerScales[rect] ?? 1;
                    if (sc > 1.05 && sr < sc - 0.02) led = true;
                    pc = Math.max(pc, sc); pr = Math.max(pr, sr); tc = Math.min(tc, sc); tr = Math.min(tr, sr);
                }
                return { pc: pc, pr: pr, tc: tc, tr: tr, led: led };
            };
            for (const fast of [false, true]) {
                // onto 0
                mousePress(sl, kx(), y);
                if (!fast) for (let x = kx(); x > track.x - 20; x -= 6) mouseMove(sl, x, y + 30);
                mouseMove(sl, track.x - 25, y + 30);
                verify(low.running, "a drag onto 0 starts the left glyph's bounce (fast " + fast + ")");
                verify(!high.running);
                let r = watch(low, li, 1, 0);
                verify(r.pc > 1.2 && r.pc <= 1.2501 && r.pr > 1.2 && r.pr <= 1.2501, "peaks " + r.pc + " " + r.pr);
                verify(r.tc < 0.92 && r.tc >= 0.8999 && r.tr < 0.92 && r.tr >= 0.8999, "troughs " + r.tc + " " + r.tr);
                verify(r.led, "the capsule moves before the rectangle");
                verify(!low.running); compare(li.layerScales[0], 1); compare(li.layerScales[1], 1);
                mouseMove(sl, track.x - 60, y + 30);        // pulled further: nothing
                verify(!low.running);
                mouseRelease(sl, track.x - 60, y + 30);
                compare(AppState.appearance.glass, 0);
                // onto 1
                mousePress(sl, kx(), y);
                if (!fast) for (let x = kx(); x < track.x + track.width + 20; x += 6) mouseMove(sl, x, y + 30);
                mouseMove(sl, track.x + track.width + 25, y + 30);
                verify(high.running, "a drag onto 1 starts the right glyph's bounce (fast " + fast + ")");
                verify(!low.running);
                r = watch(high, ri, 1, 0);
                verify(r.pc > 1.2 && r.pr > 1.2 && r.tc < 0.92 && r.tr < 0.92, JSON.stringify(r));
                verify(r.led);
                mouseRelease(sl, track.x + track.width + 25, y + 30);
                compare(AppState.appearance.glass, 1);
            }
            // the end buttons do not track: a step onto the end does not bounce
            mouseClick(findChild(sl, "leftEnd"));
            verify(!low.running && !high.running);
            AppState.set("appearance", { glass: 0.95 });
            mouseClick(findChild(sl, "rightEnd"));
            compare(AppState.appearance.glass, 1);
            verify(!high.running);
            AppState.set("appearance", { glass: 0.5 });
        }
        // the highlight pop-up writes appearance.highlight ("" = Automatic) and the text selection colour follows:
        // Purple #DFC5E0 light (accent-colors.json highlightKeys), Automatic = the accent's (Multicolor: Blue #B3D7FF)
        function test_b2_highlight() {
            const pop = findChild(app, "highlightPopup");
            verify(pop);
            compare(pop.model.length, 10);   // the eight colours between Automatic and Choose Color… (R13.2)
            compare(pop.model[9], "Choose Color…");
            compare(pop.separators, [0, 8]);
            compare(pop.model[0], "Automatic");
            compare(pop.currentIndex, 0);
            AppState.set("appearance", { mode: "light", accent: "multicolor" });
            pop.activated(2);
            compare(AppState.appearance.highlight, "purple");
            compare(AppState._patches.appearance.highlight, "purple");
            compare(pop.currentIndex, 2);
            verify(Qt.colorEqual(Accent.selectedText, "#DFC5E0"));
            pop.activated(0);
            compare(AppState.appearance.highlight, "");
            verify(Qt.colorEqual(Accent.selectedText, "#B3D7FF"));
        }
        // Auto: light or dark is the sun's answer at the zone's city, whatever the caller passes; without a place, light
        function test_b3_auto() {
            AppState._autoReady = true;
            AppState.autoPlace = { lat: 51.50833, lon: -0.12528 };
            const want = P.autoDark(Date.now(), 51.50833, -0.12528);
            AppState.set("appearance", { mode: "auto", dark: !want });
            compare(AppState.appearance.mode, "auto");
            compare(AppState.appearance.dark, want);
            compare(AppState._patches.appearance.dark, want);
            verify(AppState._autoTimer.running);              // one shot to the next -3 degree crossing
            verify(AppState._autoTimer.interval > 1000 && !AppState._autoTimer.repeat);
            AppState.autoPlace = null;
            AppState.set("appearance", { mode: "auto" });
            compare(AppState.appearance.dark, false);
            AppState.set("appearance", { mode: "dark" });
            compare(AppState.appearance.dark, true);
            verify(!AppState._autoTimer.running);
            AppState.set("appearance", { mode: "light" });
        }
        // wheel to the bottom: the last card and the button row are on screen; the overlay knob shows, then fades
        function test_c_wheel_and_scroller() {
            const f = flick();
            f.contentY = 0;
            const sc = findChild(app, "paneScroller");   // not the Liquid Glass preview's own scroller
            for (let i = 0; i < 40 && f.contentY < 463.5; i++) { mouseWheel(app, 500, 400, 0, -120); wait(20); }
            tryCompare(f, "contentY", 463.5, 2000);
            const col = column();
            const footer = col.children[col.children.length - 1];
            const p = footer.mapToItem(app, 0, 0);
            verify(p.y + footer.height <= app.height - 20 + 0.01, "button row bottom " + (p.y + footer.height));
            compare(sc.opacity, 1);
            tryCompare(sc, "opacity", 0, 2000);          // 0.6 s hold + 0.15 s fade
        }
        function test_d_scroller_drag() {
            const f = flick();
            f.contentY = 0;
            const sc = findChild(app, "paneScroller");   // not the Liquid Glass preview's own scroller
            sc.poke();
            const knob = findChild(sc, "knob");
            fuzzyCompare(knob.height, (625 - 52 - 6) * 625 / 1088.5, 0.01);   // 325.6 (Mac 325.5)
            mousePress(sc, 3, knob.height / 2);
            mouseMove(sc, 3, sc.height - knob.height / 2);
            mouseRelease(sc, 3, sc.height - knob.height / 2);
            fuzzyCompare(f.contentY, 463.5, 1.5);           // mouse positions are whole points
        }
    }
}
