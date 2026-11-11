// Mission Control window layout, decoded from macOS 27.2.1 (26B131) WindowManager.app (module WindowManagerAgent,
// type MissionControlLayout, the ungrouped path used with expose-group-apps 0). Addresses are the binary's unslid VAs:
//   0x1002223d4 usable area; 0x100222450 clamp the frames into it; 0x100016084 -> 0x100016318 the loop (at most 500
//   rounds), 0x100017334 its setup and first scale, 0x100016bfc the pair pushes.
// One uniform scale for all windows, min(1, area / largest window) to start with; every round grows each scaled rect by
// 8 pt per side, pushes each overlapping pair apart along the line between their centres (with a rounded-corner
// relief of radius 8), pushes rects back into the area, and shrinks the scale only when the windows overflow the area;
// it stops when no push is larger than 4 pt (so the gaps end near 12 pt). No sorting and no grid: the windows stay
// near where they are. Checked against the Mac's frames for 1, 2, 4, 5 and 7 windows
// (reference/re/27.2.1/live/dock/mission-control.json): every frame within 1 pt with the bar height 73.5 and Dock
// thickness 53 that the capture implies (shell/tests/run.mjs). Not decoded: grouping by app, a full-screen Space.
.pragma library

const PAD = 8;            // 0x100222700: each rect grows by this per side
const TOL = 4;            // 0x100016694: stop when the largest pair push and move are <= 4
const MAX_ITER = 500;     // 0x10001649c
const SHRINK = 0.9;       // 0x100016470
const DAMP = 10;          // 0x1000166dc: step = delta / (maxDelta / 10 + 1)

// 0x1002223d4. space: { x, y, w, h } (the screen); dock: thickness of a bottom Dock in pt (0: none); barH: Spaces bar
// height. Returns { x, y, w, h }. (A Dock on the left or right takes its thickness off that side: not used here.)
function usableArea(space, dock, barH) {
    const h = space.h - (dock > 0 ? dock - 6 : 0);
    return { x: space.x + 20, y: space.y + barH + 40, w: space.w - 40, h: h - (barH + 40 + 20) };
}

const sgn = v => (v > 0 ? 1 : v < 0 ? -1 : 0);

// FUN_100016bfc: accumulate pair pushes into delta, return the largest push component.
function pairPushes(U, delta, pad) {
  const n = U.length;
  let mx = -Number.MAX_VALUE, my = -Number.MAX_VALUE;
  for (let i = 0; i < n - 1; i++) {
    const a = U[i], cix = a[0] + 0.5 * a[2], ciy = a[1] + 0.5 * a[3];
    for (let j = i + 1; j < n; j++) {
      const b = U[j];
      let px = 0, py = 0;
      const dx0 = a[0] - b[0], dy0 = a[1] - b[1];
      const ovx = (dx0 < 0 ? a[2] : b[2]) - Math.abs(dx0);
      const ovy = (dy0 < 0 ? a[3] : b[3]) - Math.abs(dy0);
      if (ovx > 0 && ovy > 0) {
        const cjx = b[0] + 0.5 * b[2], cjy = b[1] + 0.5 * b[3];
        let dx = cix - cjx, dy = ciy - cjy;
        if (dy === 0) dy = 1;
        if (dx === 0) dx = 1;
        const hx = (a[2] + b[2]) * 0.5, hy = (a[3] + b[3]) * 0.5;
        const ex = cjx - cix, ey = cjy - ciy;
        const tx = Math.max((ex - hx) / dx, (ex + hx) / dx);
        const ty = Math.max((ey - hy) / dy, (ey + hy) / dy);
        const resx = Math.abs(cix + dx * ty - cjx) - hx;   // x clearance after moving by ty
        const resy = Math.abs(ciy + dy * tx - cjy) - hy;   // y clearance after moving by tx
        let t = 0, corner = true;
        if (resy < 0 && !Number.isNaN(tx)) t = tx;
        else if (resx >= 0) { t = 0; corner = false; }
        else t = Number.isNaN(ty) ? 0 : ty;
        if (corner && pad > 0 && t !== 0) {                 // rounded-corner relief (radius = pad)
          const qx0 = cix + dx * t - cjx, qy0 = ciy + dy * t - cjy;
          let qx = Math.abs(qx0) - hx + 2 * pad, qy = Math.abs(qy0) - hy + 2 * pad;
          if (qx >= 0 && qy >= 0) {
            qx *= sgn(qx0); qy *= sgn(qy0);
            const L = Math.sqrt(dx * dx + dy * dy);
            const cross = -dx * qy + qx * dy, dot = dx * qx + dy * qy;
            const perp = Math.abs(cross / L), par = Math.abs(dot / L);
            if (!(perp > 2 * pad) && par !== 0) {
              const root = Math.sqrt(4 * pad * pad - perp * perp);
              t -= ((par - root) * (dot / (dx * dx + dy * dy))) / par;
            }
          }
        }
        t = Math.max(t, 0);
        px = dx * t; py = dy * t;
      }
      mx = Math.max(mx, Math.abs(px)); my = Math.max(my, Math.abs(py));
      delta[i][0] += 0.5 * px; delta[i][1] += 0.5 * py;
      delta[j][0] -= 0.5 * px; delta[j][1] -= 0.5 * py;
    }
  }
  return Math.max(mx, my);
}

function _layout(windows, area) {
  const pad = PAD;
  let [ax, ay, aw, ah] = area;
  const aMaxX0 = ax + aw, aMaxY0 = ay + ah;
  // FUN_100222450: bring every frame inside the area first
  const rects = windows.map(([x, y, w, h]) => {
    const inside = x >= ax && y >= ay && x + w <= aMaxX0 && y + h <= aMaxY0;
    if (!inside) {
      if (w > aw) x = Math.round(ax + aw * 0.5 - w * 0.5);       // frinta at 0x100222574
      else if (x < ax) x = ax;
      else if (x + w > aMaxX0) x = aMaxX0 - w;
      if (h > ah) y = Math.round(ay + ah * 0.5 - h * 0.5);       // frinta at 0x100222620
      else if (y < ay) y = ay;
      else if (y + h > aMaxY0) y = aMaxY0 - h;
    }
    return [x, y, w, h];
  });
  const n = rects.length;
  if (n === 0) return { scale: 1, rects: [] };
  if (n === 1) { ay += 20; ah -= 40; }                      // 0x10001638c: CGRectInset(0, 20) for one item
  const aMaxX = ax + aw, aMaxY = ay + ah;
  // FUN_100017334
  const C = rects.map(r => [r[0] + 0.5 * r[2], r[1] + 0.5 * r[3]]);
  let maxW = -Number.MAX_VALUE, maxH = -Number.MAX_VALUE;
  for (const r of rects) { maxW = Math.max(maxW, r[2]); maxH = Math.max(maxH, r[3]); }
  let scale = Math.min(aw / maxW, ah / maxH, 1);
  let U = [];
  for (let it = 0; it < MAX_ITER; it++) {
    U = rects.map((r, i) => [C[i][0] - 0.5 * r[2] * scale - pad, C[i][1] - 0.5 * r[3] * scale - pad,
                             r[2] * scale + 2 * pad, r[3] * scale + 2 * pad]);
    const delta = rects.map(() => [0, 0]);
    const push = pairPushes(U, delta, pad);
    let loX = -Number.MAX_VALUE, loY = -Number.MAX_VALUE, hiX = -Number.MAX_VALUE, hiY = -Number.MAX_VALUE;
    let maxD = 0;
    for (let i = 0; i < n; i++) {
      const ox = U[i][0] + pad, oy = U[i][1] + pad, w = U[i][2] - 2 * pad, h = U[i][3] - 2 * pad;
      const mxX = ox + w, mxY = oy + h, mid = ox + 0.5 * w;
      let lx = Math.max(ax - mid, 0), ly = Math.max(ay - oy, 0);
      if (ax > ox + lx) lx = ax - ox;
      let hx = Math.min(aMaxX - mid, 0), hy = Math.min(aMaxY - mxY, 0);
      if (mxX + hx > aMaxX) hx = aMaxX - mxX;
      delta[i][0] += lx + hx; delta[i][1] += ly + hy;
      loX = Math.max(loX, lx); loY = Math.max(loY, ly);
      hiX = Math.max(hiX, Math.abs(hx)); hiY = Math.max(hiY, Math.abs(hy));
      maxD = Math.max(maxD, Math.abs(delta[i][0]), Math.abs(delta[i][1]));
    }
    if (push <= TOL && maxD <= TOL) break;
    const ratio = Math.max(aw / (aw + loX + hiX), ah / (ah + hiY + loY));
    scale *= ratio + (1 - ratio) * SHRINK;
    const k = 1 / (maxD / DAMP + 1);
    for (let i = 0; i < n; i++) { C[i][0] += delta[i][0] * k; C[i][1] += delta[i][1] * k; }
  }
  return { scale: scale, rects: U.map((u, i) => {
    const w = u[2] - 2 * pad, s = rects[i][2] > 0 ? w / rects[i][2] : 1;
    return [u[0] + pad, u[1] + pad, s * windows[i][2], s * windows[i][3]];
  }) };
}

// rects: [{ x, y, w, h }] (window frames, top-left origin), area: { x, y, w, h } from usableArea().
// Returns { scale, frames: [{ x, y, w, h }] } in the order given (fractional, as the binary's result).
function layout(rects, area) {
    if (rects.length === 0) return { scale: 1, frames: [] };
    const out = _layout(rects.map(r => [r.x, r.y, r.w, r.h]), [area.x, area.y, area.w, area.h]);
    return { scale: out.scale, frames: out.rects.map(r => ({ x: r[0], y: r[1], w: r[2], h: r[3] })) };
}
