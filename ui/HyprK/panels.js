.pragma library
// Pure layout for alerts, sheets and popovers (AlertPanel, Sheet, Popover), from the 27.2.1 AppKit probe
// (reference/re/MAC-ANSWERS.md Q-panels-33/34, re/27.2.1/live/panels/panels-alert{2,3}-dark.json frames,
// LIVE-27.2.1.md). Points, top-left origin.

// NSAlert: 260 wide, 20 pt padding, 64 pt icon at (20, 20), 16 pt to the 220 pt wide bold title, 10 pt to the
// message, 16 pt to the buttons, buttons 16 pt from the sides and bottom. Two buttons sit side by side (110 x 28,
// gap 8; the first, default, on the right); three stack full width (228 x 28, pitch 34; top to bottom first,
// third, second). An alert sheet has no icon.
var alert = { width: 260, padding: 20, icon: 64, iconGap: 16, textWidth: 220, messageGap: 10, buttonGap: 16,
              inset: 16, buttonHeight: 28, rowGap: 8, pitch: 34 };

// titleH / messageH: laid-out text heights (messageH 0 = no message). Returns the frame of every part; buttons are
// in the caller's order (0 = default) with their own rects.
function alertLayout(count, hasIcon, titleH, messageH) {
    var a = alert;
    var y = a.padding;
    var icon = hasIcon ? { x: a.padding, y: y, width: a.icon, height: a.icon } : null;
    if (hasIcon) y += a.icon + a.iconGap;
    var title = { x: a.padding, y: y, width: a.textWidth, height: titleH };
    y += titleH;
    var message = null;
    if (messageH > 0) {
        y += a.messageGap;
        message = { x: a.padding, y: y, width: a.textWidth, height: messageH };
        y += messageH;
    }
    y += a.buttonGap;
    var inner = a.width - 2 * a.inset;
    var buttons = [];
    if (count >= 3) {
        var order = [0, 2, 1];   // top to bottom: default, third, second (cancel)
        for (var row = 0; row < count; row++) {
            var idx = row < 3 ? order[row] : row;
            buttons[idx] = { x: a.inset, y: y + row * a.pitch, width: inner, height: a.buttonHeight };
        }
        y += (count - 1) * a.pitch + a.buttonHeight;
    } else if (count === 2) {
        var w = (inner - a.rowGap) / 2;
        buttons[1] = { x: a.inset, y: y, width: w, height: a.buttonHeight };
        buttons[0] = { x: a.inset + w + a.rowGap, y: y, width: w, height: a.buttonHeight };
        y += a.buttonHeight;
    } else {
        // one button: full width (not measured; the stacked width)
        buttons[0] = { x: a.inset, y: y, width: inner, height: a.buttonHeight };
        y += a.buttonHeight;
    }
    return { width: a.width, height: y + a.inset, icon: icon, title: title, message: message, buttons: buttons };
}

// App-modal alert placement in an area of height areaH: centred horizontally; its top is 0.26 of the area minus
// a quarter of its own height (Q-panels-33: top = 289.5 - h/4 on a 1113 pt screen), never above 0.
function alertTop(areaH, h) { return Math.max(0, Math.round(areaH * 0.26 - h / 4)); }

// App-modal alert motion, decoded from AppKit 27.2.1 (re/27.2.1/MOTION-AUDIT.md "Alert, Round R3.1"). Appear: NSAlert
// orders its panel front with NSWindowTransformAnimationPopIn, an NSAnimation whose linear progress v (0..1 over
// Tokens.panel.alertPopIn ms) gives window alpha = v and a scale about the centre of 1.2 (0.2 + 0.8 v / 0.6)^3 up to
// v = 0.6, then 1 + 0.2 cos(0.2 pi u) (1 - u)^1.5 with u = (v - 0.6) / 0.4 (amount = 0.2; the R3.1 clips over grey fit
// it at rms .0019 dark / .0009 light).
function alertPopScale(v, amount) {
    if (v <= 0.6) return Math.pow(0.2 + 0.8 * Math.max(0, v) / 0.6, 3) * (1 + amount);
    var u = Math.min(1, (v - 0.6) / 0.4);
    return 1 + amount * Math.cos(0.2 * Math.PI * u) * Math.pow(1 - u, 1.5);
}
// Dismiss with the Cancel button (Esc): NSWindowTransformAnimationScaleDownAndOut, a CASpringAnimation of perceptual
// duration d (bounce 0, so critically damped at w = 2 pi / d) started at initial velocity v0: progress p at `ms` ms,
// alpha = 1 - p, scale = 1 - (1 - 0.98) p. Any other button: no order-out animation, gone at once.
function alertCancelProgress(ms, d, v0) {
    var t = Math.max(0, ms) / 1000, w = 2 * Math.PI / d;
    return Math.min(1, 1 - Math.exp(-w * t) * (1 + (w - v0) * t));
}

// Sheets are centred on the parent window, titlebar included (Q-panels-34).
function sheetRect(parentW, parentH, w, h) {
    return { x: Math.round((parentW - w) / 2), y: Math.round((parentH - h) / 2), width: w, height: h };
}

// Popover under (or over) an anchor rect: content inset 13 (LIVE-27.2.1.md), 9 pt arrow whose tip sits `gap` pt
// off the anchor (Finder toolbar: 7), the body kept `margin` inside the area; the arrow stays on the anchor's
// centre, at least radius + arrow half-width from a corner.
var popover = { inset: 13, arrow: 9, arrowWidth: 18, radius: 20, margin: 8 };
function popoverPlacement(anchor, w, h, areaW, areaH, gap) {
    var p = popover;
    var off = p.arrow + (gap || 0);
    var below = anchor.y + anchor.height + off + h <= areaH - p.margin || anchor.y - off - h < p.margin;
    var cx = anchor.x + anchor.width / 2;
    var x = Math.max(p.margin, Math.min(areaW - w - p.margin, Math.round(cx - w / 2)));
    var y = below ? anchor.y + anchor.height + off : anchor.y - off - h;
    var lo = p.radius + p.arrowWidth / 2, hi = w - p.radius - p.arrowWidth / 2;
    var arrowX = Math.max(lo, Math.min(hi, cx - x));
    return { x: x, y: y, below: below, arrowX: arrowX };
}
