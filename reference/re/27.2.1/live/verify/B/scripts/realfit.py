import numpy as np, sys
from PIL import Image
from disp import model
from dumputil import views
def fit(name, vi, edge='left', verbose=True):
    im=np.array(Image.open(f'cap/{name}.png').convert('RGB')).astype(float)
    d,vs=views(f'cap/{name}.json'); v=vs[vi]; g=v['glass']
    x,y,w,h=[int(a*2) for a in v['cfg']['frame']]
    H=g['inputInnerRefractionHeight']; A=g['inputInnerRefractionAmount']
    # calibration: interior pixels deeper than max(H, 22pt) from every edge -> colour = F(pattern)
    m=int(max(H,10)*2+12)
    ys,xs=np.mgrid[y+m:y+h-m, x+m:x+w-m]
    if ys.size<50: m=int(H*2+2); ys,xs=np.mgrid[y+m:y+h-m, x+m:x+w-m]
    P=np.stack([(xs&255).ravel(),(ys&255).ravel(),np.ones(xs.size)],1).astype(float)
    C=im[ys.ravel(),xs.ravel()]
    # drop samples near sawtooth wraps (blur mixes across them)
    ok=((xs&255).ravel()>24)&((xs&255).ravel()<232)&((ys&255).ravel()>24)&((ys&255).ravel()<232)
    if ok.sum()<30: ok[:]=True
    F,res,_,_=np.linalg.lstsq(P[ok],C[ok],rcond=None)
    calerr=np.sqrt(((P[ok]@F-C[ok])**2).mean())
    # invert: colour -> (px,py)   use R,G rows of F (2x2 + bias) ; solve least squares with 3 channels
    Aaff=F[:2].T; b=F[2]
    pinv=np.linalg.pinv(Aaff)
    def decode(c): return (c-b)@pinv.T
    rows=[]
    if edge=='left':
        yy=y+h//2
        for i in range(0,int(H*2)+6):
            xx=x+i; p=decode(im[yy,xx]); dxm=((p[0]-(xx&255)+128)%256)-128
            rows.append((i,(i+0.5)/2,dxm,-model((i+0.5)/2,H,A)*2))
    else:
        xx=x+w//2
        for i in range(0,int(H*2)+6):
            yy=y+i; p=decode(im[yy,xx]); dym=((p[1]-(yy&255)+128)%256)-128
            rows.append((i,(i+0.5)/2,dym,-model((i+0.5)/2,H,A)*2))
    r=np.array(rows)
    sel=r[:,0]>=3   # skip the outer-refraction/rim band (first 1.5 pt)
    err=r[sel,2]-r[sel,3]
    if verbose:
        print(f'{name} v{vi} {v["cfg"]["frame"][2:]} var {v["cfg"].get("variant")} {edge}: H={H} A={A} cal rms {calerr:.2f} | fit rms {np.sqrt((err**2).mean()):.2f} px, max {abs(err).max():.2f}, n={sel.sum()}')
        print('    meas',' '.join('%4.0f'%a for a in r[:22,2])); print('    mod ',' '.join('%4.0f'%a for a in r[:22,3]))
    return r
if __name__=='__main__':
    for mode in ('dark','light'):
        for vi,e in ((0,'left'),(0,'top'),(1,'left'),(2,'left'),(3,'left'),(4,'left'),(5,'top'),(6,'top'),(9,'top'),(10,'top')):
            try: fit(f'a-grad-{mode}',vi,e)
            except Exception as ex: print('ERR',vi,e,ex)
