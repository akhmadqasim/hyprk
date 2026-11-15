import numpy as np, sys
def spring(t, d, b):
    w=2*np.pi/d; z=1-b if b>=0 else 1.0
    t=np.maximum(t,0)
    if abs(z-1)<1e-6: return 1-(1+w*t)*np.exp(-w*t)
    wd=w*np.sqrt(1-z*z); a=z*w
    return 1-np.exp(-a*t)*(np.cos(wd*t)+a/wd*np.sin(wd*t))
T=np.array([.817,.833,.850,.867,.883,.900,.917,.933,.967,.983,1.0,1.017,1.033,1.05,1.067,1.083,1.10,1.117,1.167,1.2])
SW=np.array([.438,.548,.649,.738,.813,.875,.919,.956,.996,1.006,1.012,1.015,1.015,1.013,1.013,1.010,1.010,1.006,1.002,1.0])
SH=np.array([.351,.471,.590,.696,.787,.857,.911,.950,.996,1.007,1.013,1.013,1.017,1.013,1.013,1.011,1.009,1.007,1.002,1.0])
def fit(Y, s0s):
    best=None
    for d in np.arange(0.2,0.8,0.01):
        for b in np.arange(0,0.5,0.01):
            for s0 in s0s:
                for t0 in np.arange(0.70,0.83,0.0025):
                    m=s0+(1-s0)*spring(T-t0,d,b)
                    e=np.sqrt(np.mean((m-Y)**2))
                    if best is None or e<best[0]: best=(e,d,b,s0,t0)
    return best
#print("w", fit(SW, np.arange(0.0,0.5,0.05)))
#print("h", fit(SH, np.arange(0.0,0.5,0.05)))
def fitfixed(Y,d,b):
    best=None
    for s0 in np.arange(0.0,0.6,0.01):
        for t0 in np.arange(0.65,0.83,0.0025):
            m=s0+(1-s0)*spring(T-t0,d,b); e=np.sqrt(np.mean((m-Y)**2))
            if best is None or e<best[0]: best=(round(e,4),d,b,round(s0,2),round(t0,4))
    return best
for d,b in [(0.41,0.12),(0.39,0.39),(0.35,0.43),(0.41,0.394),(0.2,0.05),(0.28,0.32),(0.28,0.41),(0.49,0.15),(0.25,0.0),(0.3,0.2),(0.33,0.21),(0.35,0.2),(0.71,0.01)]:
    print(d,b,"w",fitfixed(SW,d,b),"h",fitfixed(SH,d,b))
