import subprocess, sys, json, numpy as np
v, axf, tile, outf = sys.argv[1], sys.argv[2], float(sys.argv[3]), sys.argv[4]
Y0=1774
fr=[json.loads(l)['frame'] for l in open(axf) if '"DockProbe"' in l][0]
pts=[float(p.strip(',')) for p in subprocess.run(['ffprobe','-v','error','-select_streams','v:0','-show_entries','frame=pts_time','-of','csv=p=0',v],capture_output=True,text=True).stdout.split() if p.strip(',')]
x0=int(round(fr[0]*2)); w=int(round(fr[2]*2)); H=440
p=subprocess.Popen(['ffmpeg','-loglevel','error','-i',v,'-vf',f'crop={w}:{H}:{x0}:0,format=gray','-fps_mode','passthrough','-f','rawvideo','-pix_fmt','gray','-'],stdout=subprocess.PIPE)
F=[]
while True:
    b=p.stdout.read(w*H)
    if len(b)<w*H: break
    F.append(np.frombuffer(b,np.uint8).reshape(H,w).astype(np.float32))
F=np.array(F); n=len(F); pts=np.array(pts[:n]); pts-=pts[0]
ref=F[10]
cy=int(round((fr[1]+(fr[3]-5)/2)*2))-Y0; half=int(round(tile*0.26*2)); cx=w//2
ty0,ty1,tx0,tx1=cy-half,cy+half,cx-half,cx+half; T=ref[ty0:ty1,tx0:tx1]
maxup=int(min(ty0-2,(tile+8)*2+10))
def track(f):
    ss=np.array([((f[ty0-d:ty1-d,tx0:tx1]-T)**2).mean() for d in range(-3,maxup)])
    k=int(ss.argmin()); return (k-3)/2.0, float(ss.min())
tr=np.array([track(f) for f in F]); y=tr[:,0]; e=tr[:,1]
print('n',n,'max offset',y.max(),'max ssd',e.max(),'distinct half-pt offsets?',sorted(set((y*2%2).tolist())))
def attn(t,Hh,t0,s=1.0,Q=None):
    u=np.mod((t-t0)*1000/s,2000.0); out=np.zeros_like(u); a=0.0
    for T_,A in ((500,1.0),(326,0.5),(212,0.25)):
        m=(u>=a)&(u<a+T_); z=(u[m]-a)/T_; out[m]=A*4*z*(1-z); a+=T_
    out=Hh*out*(t>=t0)
    return Q(out) if Q else out
mv=np.where(y>0.5)[0]; ts=pts[mv[0]]; te=pts[mv[-1]]
m=(pts>ts-0.2)&(pts<te+0.3); t=pts[m]; yy=y[m]
res={'tile':tile,'ax_frame':fr,'n':int(m.sum()),'max_pt':float(yy.max())}
def grid(Q,Hs,scales):
    best=None
    for Hh in Hs:
        for s in scales:
            for t0 in np.arange(ts-0.04,ts+0.012,0.002):
                r=np.sqrt(np.mean((attn(t,Hh,t0,s,Q)-yy)**2))
                if best is None or r<best[0]: best=(r,Hh,s,t0)
    return best
R=fr[2]
for nm,Q in (('round_pt',np.round),('none',None)):
    b=grid(Q,np.arange(R-3,R+4.01,0.25),np.arange(0.99,1.0101,0.002))
    res['free_'+nm]={'rms_pt':round(float(b[0]),3),'height_pt':round(float(b[1]),2),'cycle_s':round(float(2*b[2]),4)}
    for nm2,Hh in (('code_rectH+1',R+1),('tile+1',tile+1)):
        c=grid(Q,[Hh],[1.0]); res[nm2+'_'+nm]={'height_pt':Hh,'rms_pt':round(float(c[0]),3)}
b=grid(np.round,[R+1],[1.0]); t0=b[3]
u=np.mod(t-t0,2.0); pk=[]; 
for c in range(int((te-t0)//2)+1):
    row=[]
    for a_,b_ in ((0,.5),(.5,.826),(.826,1.038)):
        mm=(t-t0>=2*c+a_)&(t-t0<2*c+b_); row.append(float(yy[mm].max()) if mm.any() else None)
    pk.append(row)
res['hop_peaks_pt_per_cycle']=pk
# hop boundaries: times (rel. t0, mod 2 s) at which offset returns to 0
z=[round(float(np.mod(t[i]-t0,2.0)),3) for i in range(1,len(t)) if yy[i]==0 and yy[i-1]>0]
res['ground_times_mod_cycle_s']=z
res['track']=[[round(float(a),4),float(b_),round(float(c_),2)] for a,b_,c_ in zip(t-t0,yy,attn(t,R+1,t0,1.0,np.round))]
json.dump(res,open(outf,'w'))
print(json.dumps({k:v for k,v in res.items() if k!='track'}))
