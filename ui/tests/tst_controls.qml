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
        id: mini
        x: 120; y: 20
        controlSize: "mini"
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

    ToolbarHighlight {
        id: light
        x: 20; y: 100; width: 200; height: 37
        centres: [18.5, 55.5]
    }
    PressSpring { id: capLift; w: 78; h: 37 }
    // a SwiftUI glass capsule with a source (platter off): the light lifts its source
    Rectangle { id: navCap; x: 20; y: 150; width: 74; height: 37 }
    ToolbarHighlight { id: navLight; x: 20; y: 150; width: 74; height: 37; source: navCap; platter: false; centres: [18.5, 55.5] }
    // an AppKit toolbar platter (back / forward): one glass, lifted about its centre and lit as one FlexInteraction entry
    Rectangle { id: platCap; x: 240; y: 240; width: 74; height: 37 }
    ToolbarHighlight { id: platLight; x: 240; y: 240; width: 74; height: 37; source: platCap; centres: [18.5, 55.5] }
    GlassButton { id: flexBtn; x: 300; y: 150; width: 78; height: 37 }
    GlassButton { id: pairBtn; x: 300; y: 200; width: 74; height: 37; segments: [37, 37] }

    SignalSpy { id: toggledSpy; target: refusing; signalName: "toggled" }
    SignalSpy { id: movedSpy; target: sl; signalName: "moved" }
    SignalSpy { id: releasedSpy; target: sl; signalName: "released" }
    SignalSpy { id: committedSpy; target: sl; signalName: "committed" }
    SignalSpy { id: endSpy; target: sl; signalName: "endReached" }
    SymbolBounce { id: bounce; name: "speaker.fill"; reduceMotion: false }
    SymbolBounce { id: waveBounce; name: "speaker.wave.3.fill"; reduceMotion: false }
    SfSymbol { id: layeredGlyph; x: 400; y: 300; name: "capsule.on.rectangle.fill"; layerScales: [1, 1.25] }

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
        // NSSwitch 27.2.1 (Switch.qml): click, long press, drags
        function test_switch_long_press_toggles_on_release() {
            backend.on = false;
            mousePress(sw, 12, 12);
            wait(1000);
            compare(backend.on, false);          // nothing while held
            mouseRelease(sw, 12, 12);
            compare(backend.on, true);           // the Mac probe: held 0.77-0.80 s, flips at the release
            backend.on = false;
        }
        function test_switch_release_off_track_keeps_state() {
            backend.on = false;
            mousePress(sw, 12, 12);
            mouseMove(sw, 12, 60);
            mouseRelease(sw, 12, 60);            // same half, below the track: no toggle
            compare(backend.on, false);
        }
        function test_switch_drag_past_middle() {
            backend.on = false;
            mousePress(sw, 12, 12);              // on the knob's half
            mouseMove(sw, 24, 12);
            compare(backend.on, false);          // short of the middle (27)
            mouseMove(sw, 30, 12);
            compare(backend.on, false);          // the state waits for the release
            mouseRelease(sw, 30, 12);
            compare(backend.on, true);
            backend.on = false;
        }
        function test_switch_drag_across_and_back() {
            backend.on = false;
            mousePress(sw, 12, 12);
            mouseMove(sw, 40, 12);
            mouseMove(sw, 12, 12);
            mouseRelease(sw, 12, 12);            // back on the start side: no change, and no click toggle
            compare(backend.on, false);
        }
        function test_switch_small_drag_is_a_click() {
            backend.on = false;
            mousePress(sw, 10, 12);
            mouseMove(sw, 18, 12);               // 8 pt, never past the middle
            mouseRelease(sw, 18, 12);
            compare(backend.on, true);
            backend.on = false;
        }
        function test_switch_drag_from_empty_half() {
            backend.on = false;
            mousePress(sw, 30, 12);              // empty half: flips after 0.4 x 54 = 21.6 pt towards "on"
            mouseMove(sw, 45, 12);
            mouseMove(sw, 50, 12);
            mouseRelease(sw, 50, 60);            // released off the track, 20 pt along: still off
            compare(backend.on, false);
            mousePress(sw, 30, 12);
            mouseMove(sw, 53, 12);               // 23 pt: the knob has flipped
            mouseRelease(sw, 53, 60);
            compare(backend.on, true);
            backend.on = false;
        }
        function knobOf(c) {
            for (let i = 0; i < c.children.length; i++) if (c.children[i].restW !== undefined) return c.children[i];
            return null;
        }
        function test_switch_sizes() {
            compare(sw.width, 54); compare(sw.height, 24);
            compare(mini.width, 36); compare(mini.height, 16);
            const k = knobOf(mini);
            compare(k.width, 21); compare(k.height, 13);
            compare(k.x, 1.5);                       // off: 1.5 pt inset
        }
        // PC #60 section 4: the knob grows x1.56 from the mouse-down frame, easeInEaseOut 0.20 s (half at 0.10 s),
        // no overshoot, then shrinks on release. Sampled every 10 ms (the test clock is coarse: a sample can land a
        // frame late).
        function test_switch_press_lens() {
            const k = knobOf(refusing);
            mousePress(refusing);
            let peak = 0, early = -1;
            for (let t = 0; t < 400; t += 10) {
                wait(10);
                peak = Math.max(peak, k.width);
                if (early < 0 && t >= 100) early = k.width;
            }
            verify(early > 33 && early < 46, "width near 0.11 s: " + early);
            fuzzyCompare(peak, 32 * 1.56, 0.05);     // no overshoot past 49.9
            mouseRelease(refusing);
            tryCompare(k, "width", 32, 1000);
        }
        // the knob runs 4 % past the end before it settles (+0.75 pt on 18), it is not squashed
        function test_switch_overshoot() {
            const k = knobOf(sw);
            backend.on = false;
            tryCompare(k, "x", 2, 1000);
            backend.on = true;
            let maxX = 0;
            for (let t = 0; t < 600; t += 10) { wait(10); maxX = Math.max(maxX, k.x); }
            verify(maxX > 20.4 && maxX < 21, "max knob x " + maxX);
            compare(k.width, 32);
            fuzzyCompare(k.x, 20, 0.05);
        }
        function test_slider_press_lens() {
            let tr = null; for (let i = 0; i < sl.children.length; i++) if (sl.children[i].usable !== undefined) tr = sl.children[i];
            const k = knobOf(tr);
            const cx = k.x + k.width / 2;
            mousePress(sl, cx, sl.height / 2);
            tryCompare(k, "width", 25, 1000);
            compare(k.height, 20);
            mouseRelease(sl, cx, sl.height / 2);
            tryCompare(k, "width", 20, 1000);
        }
        // user report: pressing a slider's knob without moving must not move it or write a value
        function test_slider_press_without_move() {
            backend.level = 0.3;
            let tr = null; for (let i = 0; i < sl.children.length; i++) if (sl.children[i].usable !== undefined) tr = sl.children[i];
            const k = knobOf(tr);
            const cx = k.x + k.width / 2;
            movedSpy.clear(); releasedSpy.clear(); committedSpy.clear();
            mousePress(sl, cx + 6, sl.height / 2);          // off-centre, still on the 20 pt knob
            tryCompare(k, "width", 25, 1000);
            fuzzyCompare(k.x + k.width / 2, cx, 0.01);      // grown around its centre
            compare(backend.level, 0.3);
            mouseRelease(sl, cx + 6, sl.height / 2);
            compare(movedSpy.count, 0); compare(releasedSpy.count, 0); compare(committedSpy.count, 0);
            compare(backend.level, 0.3);
            tryCompare(k, "width", 20, 1000);
            fuzzyCompare(k.x + k.width / 2, cx, 0.01);
            mousePress(sl, cx + 6, sl.height / 2);          // and a real drag keeps the grab offset
            mouseMove(sl, cx + 16, sl.height / 2);
            fuzzyCompare(backend.level, 0.3 + 10 / tr.usable, 0.001);
            mouseRelease(sl, cx + 16, sl.height / 2);
            compare(releasedSpy.count, 1); compare(committedSpy.count, 1);
            compare(sl.releaseModifiers, Qt.NoModifier);
        }
        // the held lens is elastic (Knob, FlexInteraction liquidLens driven by acceleration): a fast drag widens it
        // and flattens it, the shape changes the knob's geometry, and it springs back after the release; a press
        // without motion leaves it 25 x 20
        function test_slider_lens_elastic_on_fast_drag() {
            backend.level = 0.2;
            let tr = null; for (let i = 0; i < sl.children.length; i++) if (sl.children[i].usable !== undefined) tr = sl.children[i];
            const k = knobOf(tr);
            const cx = k.x + k.width / 2;
            mousePress(sl, cx, sl.height / 2);
            tryCompare(k, "width", 25, 1000);
            compare(k.deformation[0], 1);
            let maxW = 0, minH = 99;
            for (let i = 1; i <= 8; i++) {
                mouseMove(sl, cx + 12 * i, sl.height / 2);
                wait(16);
                maxW = Math.max(maxW, k.width); minH = Math.min(minH, k.height);
            }
            for (let t = 0; t < 200; t += 16) { wait(16); maxW = Math.max(maxW, k.width); minH = Math.min(minH, k.height); }
            verify(maxW > 26, "wider while speeding up: " + maxW);
            verify(minH < 19.5, "flatter: " + minH);
            verify(maxW < 25 * 1.2, "soft-clamped (1.167 plus the spring's overshoot): " + maxW);
            mouseRelease(sl, cx + 96, sl.height / 2);
            tryVerify(() => k.deformation[0] === 1 && k.deformation[2] === 0, 3000);
        }
        // the end glyphs' trigger: once per arrival on an end while dragging, not again while held there or pulled further
        function test_slider_end_reached_once() {
            backend.level = 0.5;
            let tr = null; for (let i = 0; i < sl.children.length; i++) if (sl.children[i].usable !== undefined) tr = sl.children[i];
            const k = knobOf(tr);
            const cx = k.x + k.width / 2;
            endSpy.clear();
            mousePress(sl, cx, sl.height / 2);
            mouseMove(sl, cx - 40, sl.height / 2);
            compare(endSpy.count, 0);
            mouseMove(sl, -30, sl.height / 2);
            compare(endSpy.count, 1); compare(endSpy.signalArguments[0][0], -1);
            mouseMove(sl, -60, sl.height / 2);
            compare(endSpy.count, 1);
            mouseMove(sl, 60, sl.height / 2);
            mouseMove(sl, sl.width + 40, sl.height / 2);
            compare(endSpy.count, 2); compare(endSpy.signalArguments[1][0], 1);
            mouseRelease(sl, sl.width + 40, sl.height / 2);
        }
        // SF Symbols .bounce: up to 1.27 at 0.217 s, down to 0.89 at 0.433 s, back to 1 by 0.583 s
        function test_symbol_bounce_runs_once() {
            compare(bounce.value, 1);
            bounce.play();
            let peak = 1, low = 1;
            for (let t = 0; t < 800; t += 10) { wait(10); peak = Math.max(peak, bounce.value); low = Math.min(low, bounce.value); }
            verify(peak > 1.25 && peak <= 1.2701, "peak " + peak);
            verify(low < 0.91 && low >= 0.8899, "trough " + low);
            compare(bounce.value, 1);
            verify(!bounce.running);
        }
        // a symbol of several layers bounces by layer: every path's scale, in the outline's path order (the speaker is
        // the last path and moves first, the outer wave the first path and moves 0.15 s later), 1.25 / 0.90 each
        function test_symbol_bounce_by_layer() {
            compare(waveBounce.layers, 4);
            fuzzyCompare(waveBounce.stagger, 0.05, 1e-9);
            compare(waveBounce.scales, [1, 1, 1, 1]);
            compare(bounce.scales, [1]);
            waveBounce.play();
            let peak = [1, 1, 1, 1], low = [1, 1, 1, 1], led = false;
            for (let t = 0; t < 1000; t += 8) {
                wait(8);
                const sc = waveBounce.scales;
                if (sc[3] > 1.05 && sc[0] < sc[3] - 0.03) led = true;
                for (let k = 0; k < 4; k++) { peak[k] = Math.max(peak[k], sc[k]); low[k] = Math.min(low[k], sc[k]); }
            }
            verify(led, "the speaker leads the outer wave");
            for (let k = 0; k < 4; k++) {
                verify(peak[k] > 1.22 && peak[k] <= 1.2501, "peak " + k + " " + peak[k]);
                verify(low[k] < 0.93 && low[k] >= 0.8999, "trough " + k + " " + low[k]);
            }
            compare(waveBounce.scales, [1, 1, 1, 1]);
            verify(!waveBounce.running);
            // SfSymbol draws each path at its scale about the ink box's centre
            const shapes = []; for (const c of layeredGlyph.children) if (c.s !== undefined) shapes.push(c);
            compare(shapes.length, 2);
            compare(shapes[0].s, 1); compare(shapes[1].s, 1.25);
            const m = shapes[1].mapToItem(layeredGlyph, layeredGlyph.glyph.rect[0] + layeredGlyph.glyph.rect[2] / 2,
                                          layeredGlyph.glyph.rect[1] + layeredGlyph.glyph.rect[3] / 2);
            fuzzyCompare(m.x, layeredGlyph.width / 2, 0.01); fuzzyCompare(m.y, layeredGlyph.height / 2, 0.01);
        }
        // Control Center reads Shift at the release (it inverts the volume pop): the modifiers of the let-go
        // macOS (the 23.09.23 recording, frames 2622-2645): a press on the slider's track moves the knob and the value
        // on mouse-DOWN, not at the release; the release only commits
        function test_slider_track_press_changes_on_press() {
            backend.level = 0.1;
            let tr = null; for (let i = 0; i < sl.children.length; i++) if (sl.children[i].usable !== undefined) tr = sl.children[i];
            movedSpy.clear(); committedSpy.clear();
            mousePress(sl, sl.width - 20, sl.height / 2);
            verify(movedSpy.count >= 1, "moved on press");
            verify(backend.level > 0.8, "value on press " + backend.level);
            compare(committedSpy.count, 0);
            mouseRelease(sl, sl.width - 20, sl.height / 2);
            compare(committedSpy.count, 1);
        }
        // FlexInteraction lift: the longer side grows 2.5 pt below 120 pt (GLASS-INTERACTION.md), released without overshoot
        function test_press_lift_by_longer_side() {
            capLift.pressed = true;
            tryVerify(() => Math.abs(capLift.scale - 80.5 / 78) < 0.0005 && !capLift.moving, 2000);
            capLift.pressed = false;
            let min = 2;
            for (let t = 0; t < 600; t += 10) { wait(10); min = Math.min(min, capLift.scale); }
            verify(min > 0.9995, "no undershoot after the release: " + min);
            tryCompare(capLift, "scale", 1, 1000);
        }
        // FlexInteraction drag stretch (applyScale): a drag inside the pressed glass stretches it along the drag by
        // |d| / (4 * 60000) and shifts it toward the pointer by width * k; nothing at rest
        function test_press_drag_stretch() {
            compare(flexBtn.transform[2].x, 0);
            mousePress(flexBtn, 10, 18);
            mouseMove(flexBtn, 70, 18, -1, Qt.LeftButton);
            const k = 60 / 240000;
            tryVerify(() => Math.abs(flexBtn.transform[2].x - 78 * k) < 0.002, 2000);
            verify(flexBtn.transform[1].xScale > flexBtn.transform[1].yScale, "stretched along x");
            mouseRelease(flexBtn, 70, 18);
            tryVerify(() => flexBtn.transform[2].x === 0, 1000);
        }
        // two merged buttons: the pressed one lifts by its own 37 pt (2.5 pt), only its outer end moves (1.25 pt)
        function test_press_merged_pair_grows_outer_edge() {
            mousePress(pairBtn, 10, 18);
            tryVerify(() => Math.abs(pairBtn.transform[1].yScale - 39.5 / 37) < 0.001, 2000);
            const t = pairBtn.transform[1];
            const left = t.origin.x - t.origin.x * t.xScale, right = t.origin.x + (74 - t.origin.x) * t.xScale - 74;
            verify(Math.abs(left + 1.25) < 0.02, "left end out 1.25 pt: " + left);
            verify(Math.abs(right) < 0.001, "right end stays: " + right);
            mouseRelease(pairBtn, 10, 18);
            mousePress(pairBtn, 60, 18);
            tryVerify(() => Math.abs(pairBtn.transform[1].origin.x) < 0.001 && pairBtn.transform[1].xScale > 1.016, 2000);
            mouseRelease(pairBtn, 60, 18);
        }
        // toolbar capsule (ToolbarHighlight with a source): the pressed button lifts by its own 37 pt (2.5 pt), only its
        // outer end moves (1.25 pt), the capsule and the light share the transform; back to identity after the release
        function test_toolbar_capsule_press_lift() {
            compare(navCap.transform.length, 2);
            compare(navCap.transform[0].xScale, 1);
            mousePress(navLight, 10, 18);
            tryVerify(() => Math.abs(navCap.transform[0].yScale - 39.5 / 37) < 0.001, 2000);
            const t = navCap.transform[0];
            const left = t.origin.x - t.origin.x * t.xScale, right = t.origin.x + (74 - t.origin.x) * t.xScale - 74;
            verify(Math.abs(left + 1.25) < 0.02, "left end out 1.25 pt: " + left);
            verify(Math.abs(right) < 0.001, "right end stays: " + right);
            compare(navLight.transform[0], navCap.transform[0]);
            mouseRelease(navLight, 10, 18);
            tryVerify(() => navCap.transform[0].yScale === 1 && navCap.transform[0].xScale === 1, 1500);
            mousePress(navLight, 60, 18);
            tryVerify(() => Math.abs(navCap.transform[0].origin.x) < 0.001 && navCap.transform[0].xScale > 1.016, 2000);
            mouseRelease(navLight, 60, 18);
            tryVerify(() => navCap.transform[0].xScale === 1, 1500);
        }
        // AppKit toolbar platter (one NSGlassEffectView over the capsule; R7.1 hold-shine-{settings,finder}-*.mov,
        // INTERACTIVE-GLASS-REA.md 1): pressed, the whole 74 x 37 capsule is one entry: it lifts about its centre by
        // (74 + 2.5) / 74 (both ends move 1.25 pt; Mac rims -3 / +3 px) and the glow is the ultraSmall preset sized by it
        function test_toolbar_platter_press() {
            verify(platLight.platter);
            compare(platCap.transform.length, 2);
            mousePress(platLight, 10, 18);
            verify(platLight.pressed);
            tryVerify(() => Math.abs(platCap.transform[0].xScale - 76.5 / 74) < 0.001, 2000);
            const t = platCap.transform[0];
            compare(t.origin.x, 37);
            compare(t.xScale, t.yScale);
            tryVerify(() => Math.abs(platLight.glowBig - 0.75) < 0.01, 2000);
            verify(platLight.glowLittle > 0.3, "LittleGlow: " + platLight.glowLittle);
            compare(platLight.glowHalf, 1.5 * 37 / 2);
            mouseRelease(platLight, 10, 18);
            tryVerify(() => platLight.glowBig === 0 && platCap.transform[0].xScale === 1, 3000);
        }
        // a disabled button (Q-finder-10 "Disabled: no hover") gets no press light and no lift; its enabled neighbour does
        function test_toolbar_platter_disabled_half() {
            platLight.disabled = [false, true];
            verify(!platLight.off(10));
            verify(platLight.off(60));
            mousePress(platLight, 60, 18);
            verify(!platLight.pressed);
            wait(150);
            compare(platLight.glowBig, 0);
            compare(platCap.transform[0].xScale, 1);
            mouseRelease(platLight, 60, 18);
            mousePress(platLight, 10, 18);
            verify(platLight.pressed);
            mouseRelease(platLight, 10, 18);
            platLight.disabled = [];
            tryVerify(() => platLight.glowBig === 0 && platCap.transform[0].xScale === 1, 3000);
        }
        // pressed knob lens: light uses the Mac's B2 model (ring shadow 8 down, 4 wide, blur 3, .4; fill light), dark keeps
        // the recording's fit (no ring, no fill light)
        function test_knob_lens_light_model() {
            const was = Tokens.dark;
            Tokens.dark = false;
            compare(Tokens.control.knobLensRingOpacity, 0.4);
            compare(Tokens.control.knobLensFillLight, 1);
            compare(Tokens.control.knobLensGain, 1);
            compare(Tokens.control.knobLensHaze, 0.1);
            compare(Tokens.control.knobLensKeyTop, 0);
            Tokens.dark = true;
            compare(Tokens.control.knobLensRingOpacity, 0);
            compare(Tokens.control.knobLensFillLight, 0);
            compare(Tokens.control.knobLensKeyTop, 0.092);
            compare(Tokens.control.knobLensOutline, 0.45);
            compare(Tokens.control.knobLensGain, 0.702);
            Tokens.dark = was;
        }
        // FlexInteraction glow (updateGlow 0x190c24650, GlowContainer.body 0x190c1f0c4): a 37 x 37 button (ultraSmall)
        // lights BigGlow 0.75 and LittleGlow 0.405 (fitted to the recording; decoded 0.2625), both 55.5 pt; the light
        // follows the pointer; beyond 50 pt from the press LittleGlow halves and the glow doubles; released, both fade while the glow grows to x4. Light and dark.
        function test_press_light_follows_pointer() {
            for (const dark of [true, false]) {
                Tokens.dark = dark;
                fuzzyCompare(light.glowDodge, dark ? 4 : 5 / 3, 1e-4);
                mousePress(light, 18, 18);
                tryVerify(() => Math.abs(light.glowBig - 0.75) < 0.005 && Math.abs(light.glowLittle - 0.405) < 0.005, 1000);
                tryVerify(() => Math.abs(light.glowHalf - 55.5 / 2) < 0.2, 1000);
                fuzzyCompare(light.glowCentre.x, 18, 1);
                mouseMove(light, 60, 18);
                tryVerify(() => Math.abs(light.glowCentre.x - 60) < 1, 1000);
                mouseMove(light, 120, 18);                       // 102 pt from the press
                tryVerify(() => Math.abs(light.glowLittle - 0.2025) < 0.003 && Math.abs(light.glowHalf - 55.5) < 0.3, 2000);
                fuzzyCompare(light.glowBig, 0.75, 0.005);
                mouseRelease(light, 120, 18);
                tryVerify(() => light.glowBig === 0 && light.glowLittle === 0 && Math.abs(light.glowHalf - 111) < 0.5, 3000);
            }
            Tokens.dark = false;
        }
        // the LittleGlow's coverage: its circle blurred by sigma = 1.3 radii (fitted; centre 1 - e^(-1 / (2 x 1.3^2))),
        // the table over 0..5 radii, indexed in quarters of glowRadius (4/3 of the glow's radius); nothing past 5 radii
        function test_press_light_mask() {
            const lut = light.glowLut;
            compare(lut.length, 16);
            fuzzyCompare(lut[0], 1 - Math.exp(-1 / (2 * 1.3 * 1.3)), 0.002);
            verify(lut[15] < 0.001 && lut[4] < lut[0] && lut[8] < lut[4]);
            fuzzyCompare(light.glowRadius, light.glowHalf * 4 / 3, 1e-6);
        }
        function test_slider_release_modifiers() {
            backend.level = 0.3;
            let tr = null; for (let i = 0; i < sl.children.length; i++) if (sl.children[i].usable !== undefined) tr = sl.children[i];
            const k = knobOf(tr);
            const cx = k.x + k.width / 2;
            releasedSpy.clear();
            mousePress(sl, cx, sl.height / 2);
            mouseMove(sl, cx + 10, sl.height / 2);
            mouseRelease(sl, cx + 10, sl.height / 2, Qt.LeftButton, Qt.ShiftModifier);
            compare(releasedSpy.count, 1);
            verify(sl.releaseModifiers & Qt.ShiftModifier);
            sl.forceActiveFocus();
            keyClick(Qt.Key_Left);                          // an arrow key: no modifiers
            compare(releasedSpy.count, 2);
            compare(sl.releaseModifiers, Qt.NoModifier);
        }
        function test_popup_keeps_binding() {
            const menu = findChild(pop, "menu");
            verify(menu);
            backend.index = 0;
            mouseClick(pop);                // opens the menu 3 frames after the press (a click leaves it open)
            verify(!menu.opened);
            tryVerify(() => menu.opened);
            // the menu is lifted so the current row sits on the button (5 px padding cancels the 5 px lift)
            const row = Tokens.control.menuItemHeight;
            mouseClick(root, pop.x + pop.width - 30, pop.y - pop.currentIndex * row + 2 * row + row / 2);
            compare(backend.index, 0);       // the chosen row blinks first (off 4 frames, on 3), then the value goes
            tryCompare(backend, "index", 2);
            compare(pop.currentIndex, 2);
            tryVerify(() => !menu.visible);  // faded out
            backend.index = 1;
            compare(pop.currentIndex, 1);
        }
        // a click (press and release at once, a touchpad tap) on the button over the open menu is a click on its checked
        // row: it blinks and closes, and the next click opens the menu again (a closed menu kept the clicks of a pointer
        // that did not move: the liquidglass plugin's popup unmap hook; with the menu up the button takes them as a menu
        // click, Popup's inMenu)
        function test_popup_click_on_checked_row_then_reopen() {
            const menu = findChild(pop, "menu");
            backend.index = 1;
            mouseClick(pop);
            tryVerify(() => menu.opened);
            mouseClick(pop);                 // the checked row sits on the button
            tryVerify(() => !menu.visible);
            compare(backend.index, 1);
            mouseClick(pop);
            tryVerify(() => menu.opened);
            mouseClick(root, 5, 5);          // outside: closes
            tryVerify(() => !menu.visible);
            compare(backend.index, 1);
        }
        // -[NSSliderCell _moveInDirection:]: a twentieth per arrow, Page Up / Down to the ends, no Home / End, no modifiers
        function test_slider_arrow_keys() {
            backend.level = 0.5;
            sl.forceActiveFocus();
            movedSpy.clear(); releasedSpy.clear(); committedSpy.clear();
            keyClick(Qt.Key_Right);
            fuzzyCompare(backend.level, 0.55, 1e-9);
            keyClick(Qt.Key_Up);
            fuzzyCompare(backend.level, 0.6, 1e-9);
            keyClick(Qt.Key_Left); keyClick(Qt.Key_Down);
            fuzzyCompare(backend.level, 0.5, 1e-9);
            compare(movedSpy.count, 4); compare(releasedSpy.count, 4); compare(committedSpy.count, 4);
            keyClick(Qt.Key_Home); keyClick(Qt.Key_End); keyClick(Qt.Key_Right, Qt.ShiftModifier);
            fuzzyCompare(backend.level, 0.5, 1e-9);
            compare(movedSpy.count, 4);
            keyClick(Qt.Key_PageUp);
            compare(backend.level, 1);
            keyClick(Qt.Key_Right);                 // at the end: nothing to report
            compare(movedSpy.count, 5);
            keyClick(Qt.Key_PageDown);
            compare(backend.level, 0);
            sl.tickMarks = 5; sl.onlyTicks = true;  // ticks only: one tick per press
            keyClick(Qt.Key_Right);
            fuzzyCompare(backend.level, 0.25, 1e-9);
            sl.tickMarks = 0; sl.onlyTicks = false;
        }
        function test_slider_keeps_binding() {
            mouseClick(sl, sl.width - 2, sl.height / 2);
            verify(backend.level > 0.9);
            backend.level = 0.5;
            compare(sl.value, 0.5);
        }
    }
}
