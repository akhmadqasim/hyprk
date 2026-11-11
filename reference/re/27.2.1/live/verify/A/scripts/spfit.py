import json, numpy as np
from scipy.optimize import least_squares
eps=json.load(open('sp-track.json'))
def spring(t,w,z,t0,A=0.12):
    tt=np.maximum(t-t0,0); wd=w*np.sqrt(1-z*z)
    return 1+A*np.exp(-z*w*tt)*(np.cos(wd*tt)+z*w/wd*np.sin(wd*tt))
W=2*np.pi/0.28; res=[]
for k,rows in enumerate(eps):
    r=[x for x in rows if x['xl'] is not None and not x['dup'] and x['txt'] is not None and x['t']<0.6]
    t=np.array([x['t'] for x in r]); w=np.array([x['xr']-x['xl'] for x in r]); h=np.array([x['yb']-x['yt'] for x in r])
    wf=np.median(w[t>0.42]); hf=np.median(h[t>0.42]); sx=w/wf; sy=h/hf
    o={'episode':k,'n':len(t),'width_final_pt':round(wf/2,2),'height_final_pt':round(hf/2,2),'first_visible_sx':round(float(sx[0]),4),'first_visible_sy':round(float(sy[0]),4),'min_sx':round(float(sx.min()),4),'min_sy':round(float(sy.min()),4)}
    f=least_squares(lambda q: (spring(t,q[0],q[1],q[2])-sx)*wf/2,[22.,0.65,t[0]-0.03])
    o['free_fit_x']={'omega':round(float(f.x[0]),3),'response':round(float(2*np.pi/f.x[0]),4),'zeta':round(float(f.x[1]),4),'bounce':round(float(1-f.x[1]),4),'t0':round(float(f.x[2]),4),'rms_pt':round(float(np.sqrt(np.mean(f.fun**2))),3)}
    for nm,z in (('code_bounce0.32',0.68),('code_bounce0.41',0.59)):
        g=least_squares(lambda q: (spring(t,W,z,q[0])-sx)*wf/2,[f.x[2]])
        gy=least_squares(lambda q: (spring(t,W,z,q[0])-sy)*hf/2,[f.x[2]])
        o[nm]={'t0':round(float(g.x[0]),4),'rms_x_pt':round(float(np.sqrt(np.mean(g.fun**2))),3),'rms_y_pt_if_y_from_1.12':round(float(np.sqrt(np.mean(gy.fun**2))),3)}
    gy=least_squares(lambda q: (spring(t,W,0.68,q[0],-0.05)-sy)*hf/2,[f.x[2]])
    o['y_from_0.95_bounce0.32_rms_pt']=round(float(np.sqrt(np.mean(gy.fun**2))),3)
    t0=o['code_bounce0.32']['t0']
    o['track']=[[round(float(a),4),round(float(b),4),round(float(c),4),round(float(spring(np.array([a]),W,0.68,t0)[0]),4)] for a,b,c in zip(t,sx,sy)]
    res.append(o); print(json.dumps({a:b for a,b in o.items() if a!='track'},indent=0))
json.dump(res,open('sp-fit.json','w'))
