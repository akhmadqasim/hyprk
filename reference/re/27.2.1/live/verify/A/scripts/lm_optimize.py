# minimal Levenberg-Marquardt stand-in (own code, not SciPy)
import numpy as np
class R: pass
def least_squares(f, x0, **kw):
    x=np.array(x0,float); lam=1e-3
    r=np.asarray(f(x),float); c=r@r
    for it in range(400):
        J=np.empty((len(r),len(x)))
        for j in range(len(x)):
            h=1e-6*max(1,abs(x[j])); xp=x.copy(); xp[j]+=h
            J[:,j]=(np.asarray(f(xp),float)-r)/h
        A=J.T@J; g=J.T@r
        ok=False
        for _ in range(30):
            try: d=np.linalg.solve(A+lam*np.diag(np.diag(A)+1e-12),-g)
            except np.linalg.LinAlgError: lam*=10; continue
            rn=np.asarray(f(x+d),float); cn=rn@rn
            if cn<c: x=x+d; conv=(c-cn)<1e-14*max(c,1e-30); r=rn; c=cn; lam=max(lam/5,1e-12); ok=True; break
            lam*=5
        if not ok or conv: break
    o=R(); o.x=x; o.fun=r; return o
