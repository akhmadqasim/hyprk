# R8.1: fit of the top / bottom rim highlight along x with gradientOvalization (glassr8 captures, 2x, window px incl. 64 px title bar).
# Model (uber shader supercircle_sdf_image<true>): n = normalize(mix(g, normalize(x, y*a/b), oval)), a/b = half width/height,
# g = SDF gradient ((0,+-1) on the flat edges), then the CASDFKeyFillHighlightEffect mask
#   m = schlick(spec*lobe(n.k, spread), amount) + schlick(diff*lobe(n.k, spread*0.65), amount*0.15)
# and out = dst + m*(v - dst), v = vibrantColorMatrix(dst). dst per row is solved from the oval=0 capture (lobe = 1 on the flat edge).
# usage: python3 rim_fit.py <capture dir> <mode>
import sys, json, math
import numpy as np
from PIL import Image
d, mode = sys.argv[1], sys.argv[2]
def load(n): return np.array(Image.open(f'{d}/cap-{mode}{n}.png').convert('RGB')).astype(float).mean(2)
base, o0, o1 = load(''), load('-oval0'), load('-oval1')
M = 1.1202 - 0.1894 - 0.019 if mode == 'dark' else None
tree = json.load(open(f'{d}/tree-{mode}.json'))
def find_cm(o, out):
    for f in o.get('filters', []):
        if f.get('name') == 'vibrantColorMatrix': out.append(f['inputs']['inputColorMatrix'])
    for s in o.get('sublayers', []): find_cm(s, out)
cms = []; find_cm(tree['layers'], cms)
cm = cms[0]; slope = sum(cm[0:3]); bias = cm[4]          # grey in -> grey out (row 0)
def schlick(v, a): return v / ((1 / a - 2) * (1 - v) + 1)
def lobe(c, s): return np.clip((c - math.cos(s)) / (1 - math.cos(s)), 0, 1)
def mask(c, depth, spread, amount=0.5):
    spec = np.where(depth < 1, 1 - 0.75 * depth, 0); diff = max(0, 1 - depth / 8)
    return schlick(spec * lobe(c, spread), amount) + schlick(diff * lobe(c, spread * 0.65), amount * 0.15)
def normal_cos(u, a, b, oval):
    r = np.stack([u, np.full_like(u, b * a / b)], 1); r /= np.linalg.norm(r, axis=1)[:, None]
    n = (1 - oval) * np.array([0, 1.0]) + oval * r; n /= np.linalg.norm(n, axis=1)[:, None]
    return n[:, 1]
res = {}
# shape: x0 px, width pt, top row px, height pt, radius pt, spread, list of (capture, oval)
shapes = {'A_capsule_640x56': (80, 640, 144, 56, 28, 1.3962634, [(o1, 1.0)]),
          'B_rrect_640x260_r24': (80, 640, 324, 260, 24, math.pi / 2, [(base, 0.5), (o1, 1.0)])}
for name, (x0, W, top, H, R, spread, caps) in shapes.items():
    a, b = W / 2, H / 2
    xs = np.arange(x0 + int(R * 2 * 1.6), x0 + W * 2 - int(R * 2 * 1.6), 4)
    u = (xs + 0.5 - (x0 + W)) / 2
    for edge, rows in (('top', [top, top + 1, top + 2]), ('bottom', [top + H * 2 - 1, top + H * 2 - 2, top + H * 2 - 3])):
        for k, row in enumerate(rows):
            depth = (k + 0.5) / 2
            ref = o0[row, xs].mean()
            m1 = mask(1.0, depth, spread)
            dst = (ref / 255 - m1 * bias) / (1 + m1 * (slope - 1))
            for cap, oval in caps:
                c = normal_cos(u, a, b, oval)
                pred = 255 * (dst + mask(c, depth, spread) * (slope * dst + bias - dst))
                meas = cap[row, xs]
                e = meas - pred
                res[f'{name} {edge} row{k} oval{oval}'] = {'rms': round(float(np.sqrt((e ** 2).mean())), 2), 'max': round(float(abs(e).max()), 2),
                    'meas_centre': float(meas[len(xs) // 2]), 'meas_end': float(meas[0]), 'pred_centre': round(float(pred[len(xs) // 2]), 1),
                    'pred_end': round(float(pred[0]), 1), 'flat_oval0': round(float(ref), 1), 'u_end_pt': float(u[0])}
json.dump(res, open(f'{d}/rim-fit-{mode}.json', 'w'), indent=1)
for k, v in res.items(): print(k, v)
