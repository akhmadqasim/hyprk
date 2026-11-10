.pragma library

// Notification Center and banner motion, fitted to the 27.2.1 recordings (reference/re/MAC-ANSWERS.md "Notification
// Center glass and transitions (PC #62)", data re/27.2.1/live/nc/motion.json). Springs are { response, ratio } for
// lib/spring.js; progress values run 0..1 and the shell derives offsets, opacity and scale from that one value.

// Panel open and close (clock click): the code's Spring(duration 0.3, bounce -0.2), which SwiftUI clamps to the critical
// curve (lib/spring.js fromBounce), both ways. Fitted per frame: ratio 1.0 gives 1.2 pt RMS on the open and 0.6 pt on
// the close; an unclamped ratio 1.25 gives 14.7 and 4.0 pt (tests/run.mjs re-fits both). Banners and the list reflow
// use spring(response, dampingFraction), which is not clamped.
var panelSpring = { response: 0.3, ratio: 1.0 };
// the close fit's travel W (376 pt) is the column frame width in the RE (NotificationCenterBackground width 376)
var panelTravel = 376;
// close: the window is ordered out 0.375 s after the motion starts (the spring at 99.7 %)
var panelCloseCut = 0.375;

// List reflow (stack expand/collapse, a new card pushing the list down, the list closing up after a clear): response
// 0.2 s, ratio 1.25 (expand 1.4 pt RMS, push 1.9 pt).
var reflowSpring = { response: 0.2, ratio: 1.25 };
// a cleared card blurs and fades out in place in 4-5 frames, then the list closes up
var clearFadeMs = 70;
// a card that arrives while the panel is open: shows 0.08 s after the list starts to move, fades in over 0.25 s
var arriveDelayMs = 80;
var arriveFadeMs = 250;

// Hover: the "Show" capsule and the time label crossfade (50 % at 0.1 s, 95 % at 0.27 s, the same both ways)
var hoverSpring = { response: 0.37, ratio: 1.0 };

// Banner in: from 462 pt right of its place (first visible frame at +276), response 0.43 s, ratio 0.9 (5.3 pt RMS).
// Content and glass fade in and the card grows from 0.85 as it comes.
var bannerInSpring = { response: 0.43, ratio: 0.9 };
var bannerInTravel = 462;
function bannerInOpacity(p) { return Math.max(0, Math.min(1, (p - 0.3) / 0.7)); }
function bannerInScale(p) { return 0.85 + 0.15 * Math.max(0, Math.min(1, p)); }
// Banner out (after 4.97 s): back to the right on Spring(0.3, bounce -0.2), fading out; gone after 0.15 s (9 frames)
var bannerOutSpring = { response: 0.3, ratio: 1.25 };
var bannerOutTravel = 449;
var bannerOutCut = 0.15;
function bannerOutOpacity(p) { const q = 1 - Math.max(0, Math.min(1, p)); return q * q * q; }
var bannerTimeoutMs = 4970;
