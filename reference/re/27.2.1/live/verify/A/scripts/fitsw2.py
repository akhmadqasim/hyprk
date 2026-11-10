import json, sys, numpy as np
from scipy.optimize import least_squares
ev=[json.loads(l) for l in open(sys.argv[1])]
clicks=[e['t'] for e in ev if e['ev']=='performClick']
def model(t, w, z, t0):
    tt=np.maximum(t-t0,0); wd=w*np.sqrt(1-z*z)
    return 1-np.exp(-z*w*tt)*(np.cos(wd*tt)+z*w/wd*np.sin(wd*tt))
for i,c in enumerate(clicks):
    nxt=clicks[i+1] if i+1<len(clicks) else 1e9
    a,b=(2,20) if i%2==0 else (20,2)
    xs=[list(e['frames'].values())[0][0] for e in ev if e['ev']=='frame' and c<e['t']<nxt]
    ts=[e['t'] for e in ev if e['ev']=='frame' and c<e['t']<nxt]
    p=np.array([(x-a)/(b-a) for x in xs]); 
    mov=[j for j in range(len(p)) if 1e-9<abs(p[j]-1) and abs(p[j])>1e-9]
    p=p[mov]; t=np.arange(len(p))/60.0
    print('dt check', np.round(np.diff(np.array(ts)[mov])*1000,1).tolist())
    r=least_squares(lambda q: model(t,*q)-p, [13.6,0.72,-0.016])
    w,z,t0=r.x
    print(f'flip {i}: n={len(p)} omega={w:.5f} k={w*w:.3f} c={2*z*w:.4f} response={2*np.pi/w:.5f} zeta={z:.5f} t0={t0*60:.3f} frames rms={np.sqrt(np.mean(r.fun**2))*18:.5f} pt peak={p.max():.5f}')
    print('p', np.round(p,5).tolist())
