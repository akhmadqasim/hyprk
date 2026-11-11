# Highlight-free refraction measurement of a glass platter (real Dock or probe glass).
# Per pixel transfer T_p(level) from 8 uniform grey backdrops (tint, face matrix, rim highlight, dark specular:
# everything pointwise), then a ramp backdrop is decoded per pixel through T_p^-1 -> source position -> displacement.
# usage: refr_fit.py <prefix> <xshift px of the gradx ramp vs the capture> [x0 x1 y0 y1 (platter bbox px)] [models "name:A:H:Ao:Ho:op,..."]
import numpy as np, sys, json
from PIL import Image
np.set_printoptions(linewidth=250,precision=1,suppress=True)
pre=sys.argv[1]; xsh=int(sys.argv[2])
def L(n): return np.array(Image.open(f'cap/{pre}-{n}.png').convert('RGB')).astype(float)[...,1]
lv=np.array([0,40,80,120,160,200,240,255.])
T=np.stack([L(f's{int(l)}') for l in lv])
if len(sys.argv)>6: bx0,bx1,by0,by1=[int(v) for v in sys.argv[3:7]]
else:
    m=np.abs(T[3]-120)>2; rows=np.where(m.sum(1)>200)[0]; by0,by1=rows.min(),rows.max()
    cols=np.where(m[by0:by1+1].sum(0)>(by1-by0)*0.5)[0]; bx0,bx1=cols.min(),cols.max()
D=(by1+1-by0)/2; Wd=(bx1+1-bx0)/2
print(f'{pre}: platter px x {bx0}..{bx1} y {by0}..{by1} -> {Wd} x {D} pt; body levels over 0/120/255: {T[0,(by0+by1)//2-2:(by0+by1)//2+2,bx0+30:bx0+60].mean():.0f} / {T[3,by0+6:by0+10,bx0+80:bx1-80].mean():.0f} / {np.median(T[7,by0+6:by0+10,bx0+80:bx1-80]):.0f}')
ok=(np.diff(T,axis=0)>0.5).all(0)
def decode(img):
    out=np.full(img.shape,np.nan)
    for i in range(len(lv)-1):
        lo,hi=T[i],T[i+1]
        with np.errstate(all='ignore'): val=lv[i]+(img-lo)/(hi-lo)*(lv[i+1]-lv[i])
        sel=ok&(img>=lo-0.5)&(img<=hi+0.5)&np.isnan(out); out[sel]=val[sel]
    return out
def mfun(depth,h): t=np.clip(depth/max(h,1e-9),0,1); return 1-np.sqrt(np.clip((2-t)*t,0,1))
def model(depth,A,H,Ao=0,Ho=1,op=0):
    f=op*np.clip(1-depth,0,1); return (1-f)*(-A*mfun(depth,H))+f*(-Ao*mfun(depth,Ho))
models={}
if len(sys.argv)>7:
    for s in sys.argv[7].split(';'):
        p=s.split(':'); models[p[0]]=tuple(float(eval(v,{'D':D,'min':min,'max':max})) for v in p[1:])
res={}
N=44; depth=(np.arange(N)+0.5)/2
gy=decode(L('grady')); gx=decode(L('gradx'))
for edge in ('top','bottom','left','right'):
    if edge in ('top','bottom'):
        cols=np.arange(bx0+int(D*2)+20,bx1-int(D*2)-20)
        rows=(by0+np.arange(N)) if edge=='top' else (by1-np.arange(N))
        src=gy[rows][:,cols]; pos=(rows&255)[:,None]*np.ones((1,len(cols)))
        d=((src-pos+128)%256)-128; disp=d/2*(1 if edge=='top' else -1); good=~np.isnan(src)
    else:
        rws=np.arange((by0+by1)//2-5,(by0+by1)//2+6)
        cE=(bx0+np.arange(N)) if edge=='left' else (bx1-np.arange(N))
        src=gx[rws][:,cE].T; pos=((cE-xsh)&255)[:,None]*np.ones((1,len(rws)))
        d=((src-pos+128)%256)-128; disp=d/2*(1 if edge=='left' else -1); good=~np.isnan(src)
    med=np.array([np.median(disp[i][good[i]]) if good[i].sum()>5 else np.nan for i in range(N)])
    n=np.array([good[i].sum() for i in range(N)])
    iqr=np.array([np.percentile(disp[i][good[i]],75)-np.percentile(disp[i][good[i]],25) if good[i].sum()>5 else np.nan for i in range(N)])
    sel=(depth>1.0)&(depth<20)&~np.isnan(med)&(n>5)&(iqr<1.0)
    print(f'== {edge}: inward source displacement (pt) at depth 0.25,0.75,...; rows used {sel.sum()}')
    print('   meas ',med[:36]); print('   n    ',n[:36])
    out=dict(depth=depth.tolist(),meas=[None if np.isnan(x) else round(float(x),2) for x in med],n=n.tolist())
    if sel.sum()>6:
        for nm,p in models.items():
            e=(med-model(depth,*p))[sel]; print(f'   model {nm} {tuple(round(x,2) for x in p)}: rms {np.sqrt((e**2).mean()):.2f} pt, max {abs(e).max():.2f}'); out['rms_'+nm]=float(np.sqrt((e**2).mean()))
        best=None
        for A in np.arange(-70,-1,0.25):
            for H in np.arange(1.5,30,0.125):
                e=(med-model(depth,A,H))[sel]; r=np.sqrt((e**2).mean())
                if best is None or r<best[0]: best=(r,A,H)
        print('   free fit (single quarter-circle term): A=%.2f pt (%.3f D), H=%.2f pt (%.3f D), rms %.2f pt'%(best[1],best[1]/D,best[2],best[2]/D,best[0]))
        out['free_fit']=dict(A=best[1],H=best[2],rms=best[0])
    res[edge]=out
json.dump(dict(prefix=pre,D=D,W=Wd,platter_px=[int(bx0),int(bx1),int(by0),int(by1)],edges=res),open(f'refr_{pre}.json','w'))
