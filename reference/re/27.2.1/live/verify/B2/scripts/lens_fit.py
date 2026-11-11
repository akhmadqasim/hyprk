# Content lensing (CAFilter glassForeground) : SwiftUI probe (regular glass, surface size large, contentEffect = .lense)
# against the shader glass_foreground_base. Content = grey ramp (value = x px or y px of the content, mod 256).
#   uv0 = p + n * Ar * lens((depth - Or)/Hr)                          (refraction_dir angle 0)
#   ab  = Aa * lens((depth - Oa)/Ha) * ( -(W/H)*(sin a*n.x + cos a*n.y),  -(H/W)*(cos a*n.x - sin a*n.y) )   [layer pt]
#         (the shader writes the row-0 term into .y and the row-1 term into .x of the uv offset, and the uv matrix is
#          diag(1/W, -1/H): hence the aspect factors and signs)
#   R = sum_k k*c(uv0 + k*ab)/2 (k = 1, 2/3, 1/3);  G = 5 taps around uv0 (weights 1/3 2/3 1 2/3 1/3)/3;  B = sum_k k*c(uv0 - k*ab)/2
# then the key/fill highlight layer on top: dst' = dst + m*(clamp(M dst + b, -0.75, 1) - dst)
import numpy as np, json, sys
from PIL import Image
np.set_printoptions(linewidth=250,precision=2,suppress=True)
L=lambda n: np.array(Image.open(f'cap/{n}.png').convert('RGB')).astype(float)
caps={'gradx':L('sw-gradx'),'grady':L('sw-grady')}
dump=json.load(open('cap/sw-gradx.json'))
def lens(depth,off,h): t=np.clip((depth-off)/h,0,1); return 1-np.sqrt(np.clip((2-t)*t,0,1))
def schlick(v,a): return v/((1/a-2)*(1-v)+1)
def lobe(c0,s): return np.clip((c0-np.cos(s))/(1-np.cos(s)),0,1)
def sdf_rrect(x,y,w,h,r):
    qx=np.abs(x-w/2)-(w/2-r); qy=np.abs(y-h/2)-(h/2-r)
    ox=np.maximum(qx,0); oy=np.maximum(qy,0); out=np.hypot(ox,oy); ins=np.minimum(np.maximum(qx,qy),0)
    d=out+ins-r
    corner=(qx>0)&(qy>0)
    nx=np.where(corner,ox/np.maximum(out,1e-9),np.where(qx>qy,1.0,0.0))*np.sign(x-w/2)
    ny=np.where(corner,oy/np.maximum(out,1e-9),np.where(qx>qy,0.0,1.0))*np.sign(y-h/2)
    return d,nx,ny,corner
def find(l,pred,out):
    if pred(l): out.append(l)
    for s in l.get('sublayers',[]): find(s,pred,out)
def predict(view,kind,P,aspect=True):
    cfg=view['config']; fx,fy,w,h=cfg['frame']; r=h/2 if cfg['shape']=='capsule' else float(cfg['shape'].split(':')[1])
    ys,xs=np.mgrid[0:int(h*2),0:int(w*2)]; X=(xs+0.5)/2; Y=(ys+0.5)/2
    d,nx,ny,corner=sdf_rrect(X,Y,w,h,r); depth=-d
    Ar,Hr,Or,Aa,Ha,Oa,ang=P
    lr=Ar*lens(depth,Or,Hr); ux=X+nx*lr; uy=Y+ny*lr
    la=Aa*lens(depth,Oa,Ha); c,s=np.cos(ang),np.sin(ang)
    fx_,fy_=((w/h),(h/w)) if aspect else (1.0,1.0)
    ax=-fx_*(s*nx+c*ny)*la; ay=-fy_*(c*nx-s*ny)*la
    def ramp(px,py): return ((2*px-0.5) if kind=='gradx' else (2*py-0.5))
    R=sum(k*ramp(ux+k*ax,uy+k*ay) for k in (1,2/3,1/3))/2
    G=sum(wk*ramp(ux+k*ax,uy+k*ay) for k,wk in ((2/3,1/3),(1/3,2/3),(0,1),(-1/3,2/3),(-2/3,1/3)))/3
    B=sum(k*ramp(ux-k*ax,uy-k*ay) for k in (1,2/3,1/3))/2
    # validity: every tap inside the content and no ramp wrap between the pixel and its taps
    ok=depth>1.0
    for k in (1,-1):
        tx=ux+k*ax; ty=uy+k*ay
        ok&=(tx>0.5)&(tx<w-0.5)&(ty>0.5)&(ty<h-0.5)
        v0=ramp(X,Y); v1=ramp(tx,ty); ok&=(np.floor(v0/256)==np.floor(v1/256))&(v0%256>8)&(v0%256<247)&(v1%256>8)&(v1%256<247)
    dst=np.stack([R,G,B],-1)%256/255
    # highlight
    hl=[]; find(view['layers'],lambda l:'Highlight' in (l.get('effect') or {}).get('class',''),hl)
    e=hl[0]['effect']; Mx=np.array([f for f in hl[0]['filters'] if f['name']=='vibrantColorMatrix'][0]['inputs']['inputColorMatrix']).reshape(4,5)
    m=0
    for ang_,amt,hgt,spr,sgn in ((e['keyAngle'],e['keyAmount'],e['keyHeight'],e['keySpread'],None),(e['fillAngle'],e['fillAmount'],e['fillHeight'],e['fillSpread'],None)):
        dx,dy=np.sin(ang_),-np.cos(ang_); c0=nx*dx+ny*dy
        spec=np.where(depth<hgt,1-e['curvature']*depth/hgt,0)*lobe(c0,spr)
        diff=np.maximum(0,1-depth/(hgt*e['diffuseHeightScale']))*lobe(c0,spr*e['diffuseSpreadScale'])
        m=m+schlick(spec,amt)+schlick(diff,amt*e['diffuseAmountScale'])
    v=np.clip(dst@Mx[:3,:3].T+Mx[:3,4],-0.75,1)
    out=np.clip(dst+m[...,None]*(v-dst),0,1)*255
    return out,ok,depth,corner,(nx,ny),m
code=(-16,16,-3.3,-5,6.6,0.0,np.pi/2)
res={}
for vi in (0,2,4):
    view=dump['views'][vi]; cfg=view['config']; fx,fy,w,h=cfg['frame']
    gf=[]; find(view['layers'],lambda l:any(f['name']=='glassForeground' for f in l.get('filters',[])),gf)
    ins=[f for f in gf[0]['filters'] if f['name']=='glassForeground'][0]['inputs']
    P=(ins.get('inputRefractionAmount',0),ins.get('inputRefractionHeight',0),ins.get('inputRefractionOffset',0),ins.get('inputAberrationAmount',0),ins.get('inputAberrationHeight',0),ins.get('inputAberrationOffset',0),ins.get('inputAberrationAngle',0))
    print(f'\nview {vi} {cfg["shape"]} {w}x{h}: dumped glassForeground inputs Ar {P[0]} Hr {P[1]} Or {P[2]:.2f} Aa {P[3]} Ha {P[4]:.2f} Oa {P[5]} angle {P[6]:.4f} | code (BaseSpec 0x195ef8e68..0x195ef922c) Ar -16 Hr 16 Or -3.3 Aa -5 Ha 6.6 Oa 0 angle pi/2')
    for nm,PP,asp in (('shader + dumped inputs',P,True),('same without the W/H aspect factor',P,False),('no aberration',P[:3]+(0,)+P[4:],True),('no lens at all',(0,1,0,0,1,0,0),True)):
        tot=[];zone=[];reg={}
        for kind in ('gradx','grady'):
            pred,ok,depth,corner,n,m=predict(view,kind,PP,asp)
            cap=caps[kind][int(fy*2):int((fy+h)*2),int(fx*2):int((fx+w)*2)]
            if cfg['shape']!='capsule': ok=ok&~corner          # continuous corners are not modelled
            e=(cap-pred)[ok]; tot.append(e); zone.append((cap-pred)[ok&(depth<14)])
            nxx,nyy=n
            reg.setdefault('ends (|n.x|>0.9)',[]).append((cap-pred)[ok&(depth<8)&(abs(nxx)>0.9)]); reg.setdefault('top/bottom (|n.y|>0.9)',[]).append((cap-pred)[ok&(depth<8)&(abs(nyy)>0.9)])
        e=np.concatenate(tot); z=np.concatenate(zone)
        print(f'   {nm:38s}: all px rms {np.sqrt((e**2).mean()):5.2f} levels (n={e.shape[0]}); lens zone (depth 1..14 pt) rms {np.sqrt((z**2).mean()):5.2f}, median |e| {np.median(abs(z)):.2f}, p95 {np.percentile(abs(z),95):.1f} (n={z.shape[0]})')
        print('        depth 1..8 pt: '+'; '.join(f'{k} rms {np.sqrt((np.concatenate(v)**2).mean()):.2f} (n={np.concatenate(v).shape[0]})' for k,v in reg.items()))
        res.setdefault(str(vi),{})[nm]=dict(rms_all=float(np.sqrt((e**2).mean())),rms_zone=float(np.sqrt((z**2).mean())),n_zone=int(z.shape[0]))
json.dump(res,open('lens_fit.json','w'),indent=1)
