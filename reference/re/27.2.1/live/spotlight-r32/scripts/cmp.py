import numpy as np, sys
def rd(p, wref, href):
    T=[];W=[];H=[];A=[]
    for l in open(p):
        if l.startswith("#"): continue
        s=l.split()
        if len(s)<10: continue
        T.append(float(s[0])); W.append(float(s[3])/wref); H.append(float(s[6])/href); A.append(float(s[8]))
    return np.array(T),np.array(W),np.array(H),np.array(A)
mt,mw,mh,ma=rd(sys.argv[1],519.5,230.5)
ot,ow,oh,oa=rd(sys.argv[2],520,226)
lo,hi=float(sys.argv[3]),float(sys.argv[4])
k=(mt>=lo)&(mt<=hi)
best=None
for sh in np.arange(-5,1.0,0.001):
    w=np.interp(mt[k]+sh,ot,ow); h=np.interp(mt[k]+sh,ot,oh); a=np.interp(mt[k]+sh,ot,oa)
    e=np.sqrt(np.mean((w-mw[k])**2))
    if best is None or e<best[0]: best=(e,sh,np.sqrt(np.mean((h-mh[k])**2)),np.sqrt(np.mean((a-ma[k])**2)))
print("rms width %.4f at shift %.3f s; height %.4f; level %.4f" % best)
sh=best[1]
for t,w,h,a in zip(mt[k],mw[k],mh[k],ma[k]):
    print("%.3f mac w %.3f h %.3f a %.3f | ours w %.3f h %.3f a %.3f"%(t,w,h,a,np.interp(t+sh,ot,ow),np.interp(t+sh,ot,oh),np.interp(t+sh,ot,oa)))
