import QtQuick

// The press glow of a glass button over time (Tokens.toolbar.pressRise / pressFall, per 60 Hz frame from the 23.09.23
// recording): `value` rises to 1 over 9 frames from the press and falls back over about 0.8 s from the release, from
// wherever it was. Steps on the window's frames (FrameClock); nothing runs at rest.
Item {
    id: g
    visible: false
    width: 0
    height: 0
    property bool pressed: false
    property real value: 0
    property real from: 0
    FrameClock {
        id: clock
        watchdog: true
        onTick: g.step()
        onStalled: { stop(); g.value = g.pressed ? 1 : 0; }
    }
    onPressedChanged: { from = value; clock.start(); }
    function at(table, i) {
        if (i >= table.length - 1) return table[table.length - 1];
        const k = Math.floor(i);
        return table[k] + (table[k + 1] - table[k]) * (i - k);
    }
    function step() {
        const table = pressed ? Tokens.toolbar.pressRise : Tokens.toolbar.pressFall;
        const i = clock.elapsed / (1000 / 60);
        const f = at(table, i);
        value = pressed ? from + (1 - from) * f : from * f;
        if (i >= table.length - 1) clock.stop();
    }
}
