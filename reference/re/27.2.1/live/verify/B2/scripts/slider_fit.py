# Slider knob lens (held): full forward model vs captures. Geometry in window points, captures are 2x.
import numpy as np, sys
from math import erfc
from PIL import Image
V='$SCRATCH/vb/cap/'
def L(n): return np.array(Image.open(V+n).convert('RGB')).astype(float)
CX,CY,W,H=450.0,72.0,25.0,20.0
def sdf(x,y,cx=CX,cy=CY):
    r=H/2; hx=W/2-r
    px=np.maximum(np.abs(x-cx)-hx,0); py=y-cy
    dist=np.hypot(px,py)
    nx=np.where(dist>1e-6,np.sign(x-cx)*px/np.maximum(dist,1e-6),0); ny=np.where(dist>1e-6,py/np.maximum(dist,1e-6),0)
    return dist-r,nx,ny
def m(depth,h): t=np.clip(depth/h,0,1); return 1-np.sqrt(np.clip((2-t)*t,0,1))
Phic=np.vectorize(lambda t: 0.5*erfc(np.clip(t,-2,2)/np.sqrt(2)) if False else 0.5*erfc(t/np.sqrt(2)))
def poly(t):   # the shader's polynomial: t=clamp(x*0.7071,-2,2)
    t=np.clip(t*0.7071,-2,2); q=t*t
    return (((0.00295448*q-0.0344543)*q+0.168213)*q-0.560547)*t+0.5
def schlick(v,a): return v/((1/a-2)*(1-v)+1)
def lobe(c0,s): return np.clip((c0-np.cos(s))/(1-np.cos(s)),0,1)
x0,x1,y0,y1=870,930,120,168
ys,xs=np.mgrid[y0:y1,x0:x1]; X=(xs+0.5)/2; Y=(ys+0.5)/2
d,nx,ny=sdf(X,Y); dep=-d
def geom(A,Hh):
    s=A*m(dep,Hh); return X+nx*s, Y+ny*s
def ring(off=(0,8),w=4,R=3,op=0.4):
    s,_,_=sdf(X+off[0],Y+off[1])
    return op*np.clip(poly(s/R)-poly((s+w)/R),0,1)
def hl():
    sp=np.radians(80.0)
    out=0
    for dy in (-1,1):
        c0=ny*dy
        spec=np.where(dep<1,1-0.75*dep/1,0)*lobe(c0,sp)
        diff=np.maximum(0,1-dep/8)*lobe(c0,sp*0.65)
        out=out+schlick(spec,0.5)+schlick(diff,0.075)
    return out
MR=np.array([1.1202,-0.1894,-0.019,0.1471])
res={}
for ax,nm in ((0,'gradx'),(1,'grady')):
    flat=L(f'flat-{nm}-sl.png')[y0:y1,x0:x1,1]; full=L(f'lens-{nm}-sl.png')[y0:y1,x0:x1,1]
    qx,qy=geom(-6,3.6)
    src=(2*qx-0.5-768) if ax==0 else (2*qy-0.5)     # ramp value at the sampled source point
    ins=dep>0.75
    # face matrix: fit flat = a + b*src on the deep interior (depth > 4 pt, no refraction)
    deep=dep>4.2
    b,a=np.polyfit(src[deep],flat[deep],1)
    pf=25.5+0.9*src
    e=(flat-pf)[ins]
    print(f'{nm} FLAT: face fit a={a:.2f} levels ({a/255:.4f}) b={b:.4f}; model 0.1+0.9c with inner -6/3.6: rms {np.sqrt((e**2).mean()):.2f} levels, median |e| {np.median(abs(e)):.2f}, n={ins.sum()}  (identity geometry rms {np.sqrt(((flat-(25.5+0.9*((2*X-0.5-768) if ax==0 else (2*Y-0.5))))[ins]**2).mean()):.2f})')
    # geometry-only error in pt: decode source coordinate
    dec=((flat-25.5)/0.9+0.5+(768 if ax==0 else 0))/2; tru=(X if ax==0 else Y); mod=(qx if ax==0 else qy)
    eg=(dec-mod)[ins]; print(f'   decoded source coord vs model: rms {np.sqrt((eg**2).mean()):.3f} pt, max {abs(eg).max():.2f} pt; max |disp| measured {abs(dec-tru)[ins].max():.2f} model {abs(mod-tru)[ins].max():.2f}')
    for sign in (8,-8):
        c=pf/255*(1-ring((0,sign)))
        mh=hl(); v=c*(MR[0]+MR[1]+MR[2])+MR[3]; c2=np.minimum(c+mh*(v-c),1)*255
        e=(full-c2)[ins]; e0=(full-pf)[ins]; e1=(full-c*255)[ins]
        print(f'{nm} FULL ring offset (0,{sign}): rms {np.sqrt((e**2).mean()):.2f} levels, median |e| {np.median(abs(e)):.2f}; without highlight {np.sqrt((e1**2).mean()):.2f}; without ring+hl {np.sqrt((e0**2).mean()):.2f}')
        if sign==8 or True:
            dm=dep>3
            e=(full-c2)[dm]; print(f'     depth>3pt: rms {np.sqrt((e**2).mean()):.2f}, n={dm.sum()}')
    res[nm]=(flat,full,pf)
# old description check: slope of the full capture through the centre row
flat,full,pf=res['gradx']; r=(144-y0)
sl=np.polyfit(np.arange(886,912),full[r,886-x0:912-x0],1); print('centre-row slope of raw capture: %.3f levels/px, intercept at x=900: %.1f (pattern there 132)'%(sl[0],np.polyval(sl,900)))
c=pf/255*(1-ring((0,8))); print('model centre row slope: %.3f'%np.polyfit(np.arange(886,912),(c*255)[r,886-x0:912-x0],1)[0])
np.set_printoptions(linewidth=250,precision=0,suppress=True)
print('meas ',full[r,6:56:2]); mh=hl(); v=c*(MR[0]+MR[1]+MR[2])+MR[3]; c2=np.minimum(c+mh*(v-c),1)*255; print('model',c2[r,6:56:2])
flat,full,pf=res['grady']; c=pf/255*(1-ring((0,8))); v=c*(MR[0]+MR[1]+MR[2])+MR[3]; c2=np.minimum(c+mh*(v-c),1)*255
print('vert meas ',full[4:46:2,30]); print('vert model',c2[4:46:2,30])
c=pf/255*(1-ring((0,-8))); v=c*(MR[0]+MR[1]+MR[2])+MR[3]; c2=np.minimum(c+mh*(v-c),1)*255
print('vert model(-8)',c2[4:46:2,30])
