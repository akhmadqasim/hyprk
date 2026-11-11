import numpy as np
from PIL import Image
def L(n): return np.array(Image.open(n).convert('RGB')).astype(float)
def chan_disp(img, axis):
    H,W,_=img.shape; ys,xs=np.mgrid[0:H,0:W]; ref=(xs if axis==0 else ys)&255
    return np.stack([((img[...,c]-ref+128)%256)-128 for c in range(3)],-1)   # px, per channel
def capsule_sdf(x,y,cx,cy,w,h):
    r=h/2; hx=w/2-r
    px=np.abs(x-cx)-hx; px=np.maximum(px,0); py=y-cy
    dist=np.hypot(px,py); d=dist-r
    nx=np.where(dist>1e-6,np.sign(x-cx)*px/np.maximum(dist,1e-6),0); ny=np.where(dist>1e-6,py/np.maximum(dist,1e-6),0)
    return d,nx,ny
def m(depth,h):
    if h<=0: return np.where(depth<=0,1.0,0.0)*0
    t=np.clip(depth/h,0,1); return 1-np.sqrt(np.clip((2-t)*t,0,1))
def model(x,y,geo,A1,H1,A2,H2):
    cx,cy,w,h=geo
    d,nx,ny=capsule_sdf(x,y,cx,cy,w,h); dep=-d
    s2=A2*m(dep,H2); qx=x+nx*s2; qy=y+ny*s2
    d1,n1x,n1y=capsule_sdf(qx,qy,cx,cy,w,h); s1=np.where(d1<0,A1*m(-d1,H1),0)
    return qx+n1x*s1-x, qy+n1y*s1-y, dep
def run(kind, box_pt, geo_pt, A1,H1,A2,H2, ab=0, abang=0):
    gx=L(f'cap/lens-gradx-{kind}.png'); gy=L(f'cap/lens-grady-{kind}.png')
    dxc=chan_disp(gx,0); dyc=chan_disp(gy,1)       # [H,W,3] px
    x0,y0,x1,y1=[int(v*2) for v in box_pt]
    ys,xs=np.mgrid[y0:y1,x0:x1]; X=(xs+0.5)/2; Y=(ys+0.5)/2
    mdx,mdy,dep=model(X,Y,geo_pt,A1,H1,A2,H2)
    inside=dep>1.0      # skip the outer 1 pt (rim line, AA)
    G=np.stack([dxc[y0:y1,x0:x1,1]/2, dyc[y0:y1,x0:x1,1]/2],-1)   # pt
    ex=G[...,0]-mdx; ey=G[...,1]-mdy
    e=np.hypot(ex,ey)[inside]
    print(f'{kind}: green-channel field vs model: n={inside.sum()} rms {np.sqrt((e**2).mean()):.3f} pt, median {np.median(e):.3f} pt, p95 {np.percentile(e,95):.3f} pt; max |disp| measured {np.hypot(G[...,0],G[...,1])[inside].max():.2f} pt, model {np.hypot(mdx,mdy)[inside].max():.2f} pt')
    cy=int(geo_pt[1]*2); cx=int(geo_pt[0]*2)
    col=slice(y0,y1)
    print('   vertical cut through centre, dy(pt) G meas:',' '.join('%5.1f'%v for v in dyc[y0:y1:3,cx,1]/2))
    print('                                    model  :',' '.join('%5.1f'%v for v in mdy[::3,cx-x0]))
    print('   horizontal cut, dx(pt) G meas:',' '.join('%5.1f'%v for v in dxc[cy,x0:x1:4,1]/2))
    print('                          model:',' '.join('%5.1f'%v for v in mdx[cy-y0,::4]))
    # chromatic split R-B
    sx=(dxc[y0:y1,x0:x1,0]-dxc[y0:y1,x0:x1,2])/2; sy=(dyc[y0:y1,x0:x1,0]-dyc[y0:y1,x0:x1,2])/2
    sp=np.hypot(sx,sy)
    print('   R-B source split: median %.2f pt, p90 %.2f pt (inside); horizontal cut sx:'%(np.median(sp[inside]),np.percentile(sp[inside],90)),' '.join('%4.1f'%v for v in sx[cy-y0,::4]))
    print('                                             vertical cut sy:',' '.join('%4.1f'%v for v in sy[::3,cx-x0]))
    return G,mdx,mdy,inside,sx,sy
# switch lens: abs [93,56.5] size 50x31 -> centre (118,72)
#run('sw',(93,56.5,143,87.5),(118,72,50,31),7.75,31,-4.65,3.1)
# slider lens: abs [437.5,62] 25x20 -> centre (450,72)
#run('sl',(437.5,62,462.5,82),(450,72,25,20),5,0,-6,3.6)
