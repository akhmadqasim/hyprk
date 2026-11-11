.pragma library

// Appearance handshake, one window's part (components/AppearanceAck.qml): when has this window put a frame on its
// surface that was built after a change? Two signals of its QQuickWindow answer it: afterAnimating (GUI thread, right
// before a frame is built from the items as they are) and frameSwapped (a frame's buffer was committed).
// After idle Qt builds two frames back to back, so the first swap after a build can still be the frame before; the
// window therefore asks for one more frame and waits for a second swap: one of the two is the frame with the change.
// stage: 0 idle, 1 waiting for a frame to be built, 2 built, waiting for a swap, 3 one swap seen, waiting for another.
// step(stage, event) with event "begin" | "built" | "swapped" -> { stage, update: ask the window for a frame, done }
function step(stage, event) {
    if (event === "begin") return { stage: 1, update: true, done: false };
    if (event === "built" && stage === 1) return { stage: 2, update: false, done: false };
    if (event === "swapped" && stage === 2) return { stage: 3, update: true, done: false };
    if (event === "swapped" && stage === 3) return { stage: 0, update: false, done: true };
    return { stage: stage, update: false, done: false };
}
