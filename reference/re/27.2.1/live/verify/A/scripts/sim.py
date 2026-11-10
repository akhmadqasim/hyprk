import numpy as np
def fluid(resp, z, T=0.6, h=1/300.):
    k=min((2*np.pi/resp)**2,45000); c=2*np.sqrt(k)*z
    x=0.;v=0.;a=k*(1-x); out=[(0,0.)]
    n=int(T/h)
    for i in range(1,n+1):
        v+=a*h/2; x+=v*h; a=-c*v+k*(1-x); v+=a*h/2
        out.append((i*h,x))
    return np.array(out)
def exact(resp,z,t):
    w=2*np.pi/resp; wd=w*np.sqrt(1-z*z)
    return 1-np.exp(-z*w*t)*(np.cos(wd*t)+z*w/wd*np.sin(wd*t))
p=np.array([0.01861, 0.07489, 0.15611, 0.25178, 0.35372, 0.45583, 0.55356, 0.64389, 0.72483, 0.79556, 0.85572, 0.90556, 0.94583, 0.97739, 1.00122, 1.01844, 1.03011, 1.03728, 1.04083, 1.04161, 1.04039, 1.03772, 1.03417, 1.03006, 1.02578, 1.02156, 1.01756])
if __name__=='__main__':
    for resp,z in [(0.46,0.75),(0.47,0.7),(0.46,0.72),(0.4624,0.7113)]:
        f=fluid(resp,z)
        best=None
        for off in np.arange(0,2.0,0.01):   # frames
            t=(np.arange(len(p))+off)/60.
            for nm,m in (('fluid',np.interp(t,f[:,0],f[:,1])),('exact',exact(resp,z,t))):
                r=np.sqrt(np.mean((m-p)**2))*18
                if best is None or r<best[0]: best=(r,off,nm,m.max())
            
        print(resp,z,'best rms %.4f pt at offset %.2f frames (%s) peak %.4f; fluid peak %.4f'%(best+(f[:,1].max(),)))
