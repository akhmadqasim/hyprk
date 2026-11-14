# R8.2: centre column of the held SwiftUI Slider knob lens (25 x 20 pt, r 10) over the white fill, glassr8 capture
# cap-<mode>-held-white.png (2x, window px incl. the 64 px title bar; lens top = px row 976, column x = 480 px).
# Model: face c' = 0.1 + 0.9 c (white stays 1), then ring shadow c' *= 1 - 0.4*sat(g(s/3) - g((s+4)/3)),
# (opacity 0.4 dark / 0.15 light, read from the dump) s = SDF of the knob shape moved 8 pt DOWN, g(x) = 0.5 erfc(x / sqrt 2). usage: python3 knob_fit.py <dir> <mode>
import sys, json, math
import numpy as np
from PIL import Image
d, mode = sys.argv[1], sys.argv[2]
im = np.array(Image.open(f'{d}/cap-{mode}-held-white.png').convert('RGB')).astype(float).mean(2)
g = lambda x: 0.5 * math.erfc(x / math.sqrt(2))
rows = [r for r in range(978, 1015) if not 990 <= r <= 1001]   # inside the lens; rim rows and the 6 pt track rows left out
tree = json.load(open(f'{d}/tree-{mode}-held-white.json'))
def find(o, inl=False):
    inl = inl or 'Lift' in o.get('class', '')
    for f in o.get('filters', []) if inl else []:
        if f.get('name') == 'glassBackground': return f['inputs']
    for c in o.get('sublayers', []):
        r = find(c, inl)
        if r: return r
gi = find(tree['layers']); op = gi['inputRingShadowOpacity']
meas, model = [], []
for r in rows:
    y = (r - 976 + 0.5) / 2; ys = y - 8
    s = -min(ys, 20 - ys) if 0 <= ys <= 20 else (-ys if ys < 0 else ys - 20)
    ring = op * min(1, max(0, g(s / 3) - g((s + 4) / 3)))
    face = 0.1 + 0.9 * 1.0
    model.append(round(255 * face * (1 - ring), 1)); meas.append(float(im[r, 480]))
e = np.array(meas) - np.array(model)
out = {'ringShadowOpacity': op, 'rows_px': rows, 'depth_pt_from_top': [(r - 976 + 0.5) / 2 for r in rows], 'measured': meas, 'model': model,
       'rms': round(float(np.sqrt((e ** 2).mean())), 2), 'max': round(float(abs(e).max()), 2)}
json.dump(out, open(f'{d}/knob-fit-{mode}.json', 'w'), indent=1)
print(out['rms'], out['max']); print(meas); print(model)
