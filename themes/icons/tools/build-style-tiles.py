#!/usr/bin/env python3 -I
"""Build the tiles of Settings > Appearance > "Icon & widget style": settings/assets/icon-style/*.png.

macOS 27.2.1 draws each tile as the Weather app's icon in that style (Appearance.appex IconStyleRow: ISIcon(bundleIdentifier:
"com.apple.weather") with an ISImageDescriptor, 36 pt). The same composition as build-styles.py (icr.py, the port of
IconRendering), here in the mitigated version for every style and both modes, 36 pt at 4x (144 px):
default (Apple's bitmap), dark, clear-{light,dark}, tinted-<accent>-{light,dark} (tint = that accent, ui/HyprK/Accent.qml).
Fitted against reference/screens/27.2.1/settings/appearance/iconstyle-*-light.png: 72 px on the Mac, rms 10-16 levels.

  build-style-tiles.py <os-volume-root> [out dir]
"""
import sys, os, importlib.util
import numpy as np
from PIL import Image
T = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, T)
spec = importlib.util.spec_from_file_location('bs', T + '/build-styles.py'); bs = importlib.util.module_from_spec(spec); spec.loader.exec_module(bs)
import iconstack as IS, icr
icons = os.path.dirname(T)
car = sys.argv[1] + '/System/Applications/Weather.app/Contents/Resources/Assets.car'
out = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(icons), '..', 'settings', 'assets', 'icon-style')
size, points, ppp, ss = 144, 36.0, 2.0, 2
stem = [l.split('\t') for l in open(icons + '/apps-sources.txt') if l.startswith('Weather\t')][0][2]
stack = IS.Stack(car, extended=True)
default = Image.open(icons + '/apps/Weather-1024.png')
alpha,cov=bs.shape(default,size); y0,y1=bs.body(cov)
def cell(rgb): return np.pad(rgb,((y0,size-y1),(y0,size-y1),(0,0)),mode='edge')
res={}
px=np.asarray(default.convert('RGBA').resize((size,size),Image.LANCZOS)).astype(np.float32)/255
res['default']=(px[...,:3],px[...,3])
dark=bs.icon_for(stack,stem,'dark',cov)
rgb=cell(icr.render(dark,'color','dark',points,ppp,mitigated=True,supersample=ss))
res['dark']=(rgb*(cov/np.maximum(alpha,1e-6))[...,None],alpha)
tin=bs.icon_for(stack,stem,'tintable',cov)
TINTS={'blue':('007AFF','007AFF'),'purple':('953D96','A550A7'),'pink':('F74F9E','F74F9E'),'red':('E0383E','FF5257'),
'orange':('F7821B','F7821B'),'yellow':('FFC726','FFC600'),'green':('62BA46','62BA46'),'graphite':('989898','8C8C8C')}
def hx(h): return np.array([int(h[i:i+2],16) for i in (0,2,4)],np.float32)/255
for ap in ('light','dark'):
    res['clear-'+ap]=(cell(icr.render(tin,'clear',ap,points,ppp,supersample=ss)),cov)
    for n,(l,d) in TINTS.items():
        res['tinted-%s-%s'%(n,ap)]=(cell(icr.render(tin,'tinted',ap,points,ppp,tint=hx(d if ap=='dark' else l),supersample=ss)),cov)
# FITTED (R11.6 icon-style-tiles-default-selected-dark.png, the Display P3 still read as sRGB): the Mac's blue light
# plate is the accent itself, (0,125,255) where the decoded mix gives (12,120,237) (its tint is likely a wide-gamut
# blue). Per channel, ours -> the Mac's median over the aligned tile; rms 17.4 -> 12.1 (Apple's own default bitmap: 11.7)
BLUE_LIGHT={0:[(0,0),(17,0),(63,15),(72,32),(86,63),(101,91),(122,113),(134,129),(149,150),(255,255)],
            1:[(0,0),(105,110),(120,125),(140,140),(255,255)],
            2:[(0,0),(44,43),(237,255),(255,255)]}
rgb,a=res['tinted-blue-light']; q=(np.clip(rgb,0,1)*255).round()
for ch,pts in BLUE_LIGHT.items():
    xs,ys=zip(*pts); q[...,ch]=np.interp(q[...,ch],xs,ys)
res['tinted-blue-light']=((q/255).astype(np.float32),a)
for k,(rgb,a) in res.items(): bs.save(rgb,a,f'{out}/{k}.png')
