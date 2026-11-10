.pragma library

// Control geometry per AppKit control size, macOS 27.2.1 (reference/re/MAC-ANSWERS.md Q-settings-15..-23,
// re/27.2.1/live/controls/controls-{light,dark}.json). Sizes: "regular", "small", "mini", "large";
// unknown names are regular. Tests: ui/tests/tst_geometry.qml.

const SIZES = ["regular", "small", "mini", "large"];
function pick(size, values) { const i = SIZES.indexOf(size); return values[i < 0 ? 0 : i]; }

// Push button, pop-up button and segmented track: height, corner radius, label side padding.
// Large is a capsule (28, r14). Q-15, -19, -22.
function push(size) {
    const m = pick(size, [[24, 6, 12], [20, 5, 10], [16, 4, 8], [28, 14, 14]]);
    return { height: m[0], radius: m[1], padding: m[2] };
}

// Switch track and capsule knob, knob inset from the track edge (Q-16). AppKit has no large switch.
function switchTrack(size) {
    const m = pick(size, [[54, 24, 32, 20, 2], [44, 20, 26, 16, 2], [36, 16, 21, 13, 1.5], [54, 24, 32, 20, 2]]);
    return { width: m[0], height: m[1], knobWidth: m[2], knobHeight: m[3], inset: m[4] };
}
// Knob left edge at a (0 off .. 1 on; overshoot passes through).
function switchKnobX(m, a) { return m.inset + a * (m.width - 2 * m.inset - m.knobWidth); }

// Checkbox and radio: box side, box radius, radio dot diameter (Q-21; the large dot is not measured).
function checkbox(size) {
    const m = pick(size, [[16, 5.5, 5], [14, 4.5, 5], [12, 3.5, 4], [18, 6.5, 5]]);
    return { size: m[0], radius: m[1], dot: m[2] };
}

// Slider: row height, track thickness, knob (20 x 16 r8 at every size: only regular is measured), tick dots
// 2 x 2 at y 14 in the 16 pt row (Q-18).
function slider(size) {
    const m = pick(size, [[16, 6], [14, 4], [12, 4], [16, 6]]);
    return { height: m[0], track: m[1], knobWidth: 20, knobHeight: 16, tick: 2, tickY: m[0] - 2 };
}
// Centre x of tick i of n on a slider `width` wide: the knob centre's range, knobWidth / 2 from each end.
function tickX(width, knobWidth, i, n) { return knobWidth / 2 + (n > 1 ? i / (n - 1) : 0) * (width - knobWidth); }
