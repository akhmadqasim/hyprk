import json, numpy as np
from scipy.optimize import least_squares
eps=json.load(open('hud-track.json'))
def crit(t,w,t0): tt=np.maximum(t-t0,0); return 1-(1+w*tt)*np.exp(-w*tt)
def over(t,w,z,t0):
    tt=np.maximum(t-t0,0); s=np.sqrt(z*z-1); r1=-w*(z-s); r2=-w*(z+s)
    return 1-(r2*np.exp(r1*tt)-r1*np.exp(r2*tt))/(r2-r1)
W0=np.sqrt(300/2.0)
res=[]
for k,rows in enumerate(eps):
    r=np.array([[np.nan if x is None else x for x in row] for row in rows])
    # drop duplicated capture frames
    keep=[0]+[i for i in range(1,len(r)) if not np.allclose(np.nan_to_num(r[i,1:]),np.nan_to_num(r[i-1,1:]))]
    r=r[keep]; t=r[:,0]; h=r[:,3]-r[:,2]; gl=r[:,4]
    fin=(t>0.6)&(t<0.9); hf=np.nanmedian(h[fin]); gf=np.median(gl[fin])
    s=h/hf; m=~np.isnan(s)&(t<0.7)
    ph=(s[m]-0.9)/0.1; th=t[m]
    a=gl/gf; ma=(t>-0.02)&(t<0.7); ta=t[ma]; aa=a[ma]
    o={'episode':k,'h_final_px':round(float(hf),2),'n_scale':int(m.sum()),'n_alpha':int(ma.sum())}
    # joint fit: scale progress p, alpha = p**g ; shared omega,t0
    def resid(q,g=None):
        w,t0=q[0],q[1]; gg=q[2] if g is None else g
        return np.r_[(0.9+0.1*crit(th,w,t0)-s[m])*hf/2, (crit(ta,w,t0)**gg-aa)*0.0]   # scale residual in pt
    f=least_squares(lambda q: (0.9+0.1*crit(th,q[0],q[1])-s[m])*hf/2,[12.,0.0])
    o['scale_fit']={'omega':round(float(f.x[0]),3),'response_s':round(float(2*np.pi/f.x[0]),4),'t0':round(float(f.x[1]),4),'rms_pt':round(float(np.sqrt(np.mean(f.fun**2))),3)}
    f2=least_squares(lambda q: (0.9+0.1*crit(th,W0,q[0])-s[m])*hf/2,[0.0])
    o['scale_code']={'omega':round(float(W0),3),'t0':round(float(f2.x[0]),4),'rms_pt':round(float(np.sqrt(np.mean(f2.fun**2))),3)}
    for g in (1,2):
        f3=least_squares(lambda q: crit(ta,q[0],q[1])**g-aa,[12.,0.0])
        f4=least_squares(lambda q: crit(ta,W0,q[0])**g-aa,[0.0])
        o['alpha_p%d'%g]={'omega':round(float(f3.x[0]),3),'t0':round(float(f3.x[1]),4),'rms':round(float(np.sqrt(np.mean(f3.fun**2))),4),'code_omega_t0':round(float(f4.x[0]),4),'code_omega_rms':round(float(np.sqrt(np.mean(f4.fun**2))),4)}
    # joint: common t0 for scale (pt) and alpha^g
    for g in (1,2):
        fj=least_squares(lambda q: np.r_[(0.9+0.1*crit(th,W0,q[0])-s[m])*10, crit(ta,W0,q[0])**g-aa],[0.0])
        o['joint_code_p%d'%g]={'t0':round(float(fj.x[0]),4),'rms_scale_pt':round(float(np.sqrt(np.mean(((0.9+0.1*crit(th,W0,fj.x[0])-s[m])*hf/2)**2))),3),'rms_alpha':round(float(np.sqrt(np.mean((crit(ta,W0,fj.x[0])**g-aa)**2))),4)}
    o['track']=[[round(float(a_),4),None if np.isnan(b_) else round(float(b_),4),round(float(c_),4)] for a_,b_,c_ in zip(t,s,a)]
    res.append(o)
    print(json.dumps({k_:v for k_,v in o.items() if k_!='track'}))
json.dump(res,open('hud-fit.json','w'))
tt=np.array([0.05,0.1,0.2,0.3,0.4,0.5])
print('crit w0',crit(tt,W0,0).round(4)); print('over z=1.0206',over(tt,W0,50/(2*np.sqrt(600)),0).round(4),'max diff',np.abs(crit(np.linspace(0,1,500),W0,0)-over(np.linspace(0,1,500),W0,50/(2*np.sqrt(600)),0)).max())
