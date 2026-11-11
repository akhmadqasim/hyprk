# Fits of glass_model.py against probe captures (tools/probe/glass3.swift, cham.swift). Run in a folder that holds
# the captures under m/ (m/sb, m/blur, m/fine1, m/fine5, m/nat, m/nat3):  python fit_c3.py sidebar|blur|recipes
import json, sys, os, math
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import glass_model as gm

def inputs(it):
    g = dict(it['glass']['inputs'])
    for k, v in list(g.items()):
        if isinstance(v, dict): g[k] = v['c']
    return g
def stat(E):
    E = np.array(E); return round(float(np.sqrt((E ** 2).mean())), 2), round(float(np.abs(E).max()), 2)

def sidebar():
    out = {}
    for mode in ('dark', 'light'):
        for a in ('0.0', '0.5', '1.0'):
            j = json.load(open(f'm/sb/{mode}-sb-a{a}.json')); acc = {}; cham = []; pe = [[], []]
            for c in j['colors']:
                im = np.asarray(Image.open(f'm/sb/{mode}-sb-a{a}-{c.replace(",", "_")}.png').convert('RGB')).astype(float)
                def px(x, y, w, h, m=10):
                    cx, cy = int((x + w / 2) * 2), int((y + h / 2) * 2); return im[cy - m:cy + m, cx - 3 * m:cx + 3 * m].reshape(-1, 3).mean(0)
                bg = im[6, 6]; P = [px(1130, 20 + 80 * i, 150, 60) for i in range(3)]; cham.append(P[0])
                pe[0].append(gm.chameleon(bg / 255, P[0] / 255, opacity=1) * 255 - P[1]); pe[1].append(gm.chameleon(bg / 255, P[0] / 255, opacity=0.1) * 255 - P[2])
                for it in j['items']:
                    x, y, w, h = [v / 2 for v in it['rect']]; m = px(x, y, w, h); g = inputs(it); sb = it['name'].startswith('sb')
                    e = acc.setdefault(it['name'], dict(with_layer=[], without=[]))
                    e['without'].append(gm.model(bg, g) - m); e['with_layer'].append(gm.model(bg, g, mode, P[0]) - m)
            cham = np.array(cham)
            out[f'{mode} a={a}'] = dict(n=len(j['colors']), chameleon_colour=[round(float(v), 1) for v in cham.mean(0)],
                bare_layer_opacity1=stat(pe[0]), bare_layer_opacity01=stat(pe[1]),
                items={n: dict(glass_only=stat(e['without']), glass_plus_chameleon=stat(e['with_layer'])) for n, e in acc.items()})
            for n, e in acc.items(): print(mode, a, n.ljust(11), 'glass only rms/max', stat(e['without']), ' + chameleon', stat(e['with_layer']))
    json.dump(out, open('m/sidebar-fit.json', 'w'), indent=1)

def blur():
    out = []
    for d, tag in (('m/blur', 'b'), ('m/fine1', 'f'), ('m/fine5', 'f')):
        L = json.load(open(f'{d}/{tag}-blur-log.json'))[1:]
        for e in L:
            pat = e['pattern']
            if not (pat == 'edgeV' or pat.startswith('lineV')): continue
            im = np.asarray(Image.open(f'{d}/' + e['file']).convert('RGB')).astype(float)[:, :, 1] / 255
            h, w = im.shape; p = im[h // 2 - 40:h // 2 + 40].mean(0); x = np.zeros(w); x0 = int(round((650 + e['phase'] - 150) * 2))
            if pat == 'edgeV': x[x0:] = 1
            else: x[x0:x0 + int(pat.split(':')[1])] = 1
            s, r = e['s'], e['r']; q = int(round(1 / s)); lev = gm.level(r, s); half = int(min(900, max(40, 42 * max(r, 0.5))))
            sl = slice(max(60, x0 - half), min(w - 60, x0 + half)); best = None; per = q * 2 ** int(math.ceil(lev))
            for phi in range(0, per, max(1, per // 64)):
                dd = (gm.Pyramid1D(x, s, phi).sample(lev)[sl] - p[sl]) * 255; rms = float(np.sqrt((dd ** 2).mean()))
                if best is None or rms < best[0]: best = (rms, float(np.abs(dd).max()), phi)
            out.append(dict(set=d[2:], pattern=pat, phase=e['phase'], scale=s, radius=r, R=round(1.6 * r * 2 * s, 3), level=round(lev, 3),
                            rms=round(best[0], 2), max=round(best[1], 2), peak_measured=round(float(p[sl].max() * 255), 1)))
    json.dump(out, open('m/blur-kernel-fit.json', 'w'), indent=0)
    for pat in ('edgeV', 'lineV:1', 'lineV:8'):
        v = [o for o in out if o['pattern'] == pat]; print(pat, 'n', len(v), 'rms mean %.2f worst %.2f, max worst %.2f' % (np.mean([o['rms'] for o in v]), max(o['rms'] for o in v), max(o['max'] for o in v)))

def recipes(cham=(37, 46, 50)):
    out = []
    def one(tag, mode, a, name_pat, ph, im, x, it, x0, half):
        g = inputs(it); rx, ry, rw, rh = it['rect']; s = it['glass']['backdrop']['scale']; q = int(round(1 / s)); D = rh / 2
        cy = int(ry + rh / 2); row = im[cy - 6:cy + 6].mean(0); sl = slice(x0 - half, x0 + half); best = None
        for phi in range(0, q * 8, max(1, q // 2)):
            o = gm.profile_1d(x, g, s, D / 2, mode, cham if it['name'].startswith(('sb', 'sidebar')) else None, phi=phi)[sl]
            d = o - row[sl]; rms = float(np.sqrt((d ** 2).mean()))
            if best is None or rms < best[0]: best = (rms, float(np.abs(d).max()))
        out.append(dict(mode=mode, a=a, pattern=name_pat, phase=ph, name=it['name'], D=D, scale=s, rms=round(best[0], 2), max=round(best[1], 2),
                        measured_range=round(float(row[sl, 1].max() - row[sl, 1].min()), 1)))
    for a in ('0.0', '0.5', '1.0'):
        j = json.load(open(f'm/nat/n-nat-a{a}.json'))
        for pat, ph in (('edgeV', 0.0), ('edgeV', 1.5), ('edgeV', 5.0), ('lineV1', 0.0), ('lineV8', 0.0), ('stripes16', 0.0)):
            im = np.asarray(Image.open(f'm/nat/n-nat-a{a}-{pat}-p{ph}.png').convert('RGB')).astype(float)
            x = np.zeros(2600); x0 = int(round((650 + ph) * 2))
            if pat == 'edgeV': x[x0:] = 1
            elif pat.startswith('lineV'): x[x0:x0 + int(pat[5:])] = 1
            else:
                for k in range(0, 2600, 16): x[k:k + 8] = 1
            for it in j['items']:
                rx, ry, rw, rh = it['rect']
                if pat == 'stripes16': one('n', 'dark', a, pat, ph, im, x, it, int(rx + rw / 2), 100)
                elif rx + 160 < x0 < rx + rw - 160: one('n', 'dark', a, pat, ph, im, x, it, x0, 140)
    for tag, mode, a in (('n', 'dark', '0.0'), ('n', 'dark', '0.5'), ('n', 'dark', '1.0'), ('L', 'light', '0.5')):
        j = json.load(open(f'm/nat3/{tag}-nat3-a{a}.json'))
        for ph in (0.0, 3.5):
            im = np.asarray(Image.open(f'm/nat3/{tag}-nat3-a{a}-edges3-p{ph}.png').convert('RGB')).astype(float)
            x = np.zeros(2600); x[:int((230 + ph) * 2)] = 1; x[int((650 + ph) * 2):int((650 + ph) * 2) + 840] = 1
            for it in j['items']:
                rx, ry, rw, rh = it['rect']; one(tag, mode, a, 'edges3', ph, im, x, it, int(rx + rw / 2 + ph * 2), 330)
    json.dump(out, open('m/recipes-edge-fit.json', 'w'), indent=0)
    for key in sorted(set((o['mode'], o['name'], o['a']) for o in out)):
        v = [o for o in out if (o['mode'], o['name'], o['a']) == key]
        print('%-5s %-17s a=%s n=%d rms mean %.2f worst %.2f max %.2f' % (*key, len(v), np.mean([o['rms'] for o in v]), max(o['rms'] for o in v), max(o['max'] for o in v)))

if __name__ == '__main__':
    {'sidebar': sidebar, 'blur': blur, 'recipes': recipes}[sys.argv[1]]()
