# Control Center (real): top/bottom rim profiles of the modules, columns away from content and corners.
import numpy as np, json
from PIL import Image
from scipy import ndimage as ndi
np.set_printoptions(linewidth=260,precision=1,suppress=True)
L=lambda n: np.array(Image.open(f'cap/{n}.png').convert('RGB')).astype(float)
im={b:L('cc-'+b) for b in ('grey','white','black')}
k=im['black']; mask=k.max(2)>2
lab,n=ndi.label(mask); objs=ndi.find_objects(lab)
def schlick(v,a): return v/((1/a-2)*(1-v)+1)
def mprof(depth):
    spec=np.where(depth<1,1-0.75*depth,0); diff=np.maximum(0,1-depth/8)
    return schlick(spec,0.5)+schlick(diff,0.075)
M={'cc/clear 1.319 -0.048 -0.005 | 0.2':(1.319-0.048-0.005,0.2),'regular 1.1202 -0.1894 -0.019 | 0.1471':(1.1202-0.1894-0.019,0.1471),'dock dark 1.094 -0.358 -0.036 | 0.25':(1.094-0.358-0.036,0.25)}
out=[]
for i,sl in enumerate(objs):
    y0,y1,x0,x1=sl[0].start,sl[0].stop,sl[1].start,sl[1].stop
    w,h=(x1-x0)/2,(y1-y0)/2
    if w<40 or h<30: continue
    r=min(w,h)/2
    cs=slice(int(x0+2*min(r,30)+8),int(x1-2*min(r,30)-8))     # straight part of the top edge
    if cs.stop-cs.start<20: continue
    print(f'\nmodule {i}: x {1200+x0/2:.1f}..{1200+x1/2:.1f} y {34+y0/2:.1f}..{34+y1/2:.1f}  size {w:.1f} x {h:.1f} pt; columns used {cs.stop-cs.start}')
    rec=dict(rect=[1200+x0/2,34+y0/2,w,h])
    for edge in ('top','bottom'):
        for b in ('grey','white','black'):
            a=im[b][...,1]
            rows=np.arange(y0-3,y0+26) if edge=='top' else np.arange(y1+2,y1-27,-1)
            blk=a[rows][:,cs]
            # keep columns whose deep part (rows 18..28 from the edge) is flat = no content there
            flat=(blk[20:29].max(0)-blk[20:29].min(0))<=2
            # and whose value equals the mode of the row (content-free)
            base_all=np.median(blk[22:29],0); mode=np.median(base_all[flat]) if flat.sum()>5 else np.nan
            good=flat&(abs(base_all-mode)<=1.5)
            if good.sum()<8: print(f'  {edge} {b}: too few content-free columns ({good.sum()})'); continue
            prof=np.median(blk[:,good],1); sd=blk[:,good].std(1)
            base=mode
            depth=(np.arange(26)+0.5)/2
            line=f'  {edge:6s} {b:5s} n={good.sum():4d} outside {prof[:3]} | rim {prof[3:19]} | base {base:.0f} (col sd max {sd[3:19].max():.1f})'
            print(line)
            best=None
            for nm,(g,bias) in M.items():
                pred=np.minimum(base+mprof(depth)*(np.minimum(g*base+bias*255,255)-base),255)
                e=(prof[3:19]-pred[:16]); rms=np.sqrt((e**2).mean())
                print(f'         model {nm}: {pred[:8]} rms {rms:.1f}')
            rec[f'{edge}_{b}']=dict(profile=prof.tolist(),base=float(base),n=int(good.sum()))
    out.append(rec)
json.dump(out,open('cc_rim.json','w'))
