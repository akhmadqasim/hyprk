# dockana.py <video> <ax2.jsonl> <log> <tile> <out.json>
# Tracks the vertical offset of the test tile (generic icon) per frame by masked template matching (sub-pixel),
# then fits the Dock code's launch and attention curves.
import subprocess, sys, json, numpy as np
from scipy.optimize import least_squares
v, axf, logf, tile, outf = sys.argv[1], sys.argv[2], sys.argv[3], float(sys.argv[4]), sys.argv[5]
Y0=1774  # crop top in px
fr=None
for l in open(axf):
    o=json.loads(l)
    if o.get('title')=='DockProbe': fr=o['frame']
assert fr, 'DockProbe not in AX'
log=dict(l.split() for l in open(logf)); dT=float(log['t_attn'])-float(log['t_launch'])
pts=[float(p.strip(',')) for p in subprocess.run(['ffprobe','-v','error','-select_streams','v:0','-show_entries','frame=pts_time','-of','csv=p=0',v],capture_output=True,text=True).stdout.split() if p.strip(',')]
x0=int(round(fr[0]*2)); w=int(round(fr[2]*2)); H=440
p=subprocess.Popen(['ffmpeg','-loglevel','error','-i',v,'-vf',f'crop={w}:{H}:{x0}:0,format=gray','-fps_mode','passthrough','-f','rawvideo','-pix_fmt','gray','-'],stdout=subprocess.PIPE)
F=[]
while True:
    b=p.stdout.read(w*H)
    if len(b)<w*H: break
    F.append(np.frombuffer(b,np.uint8).reshape(H,w).astype(np.float32))
F=np.array(F); n=len(F); pts=np.array(pts[:n]); pts-=pts[0]
act=np.r_[0,np.abs(np.diff(F,axis=0)).mean(axis=(1,2))]
first=int(np.argmax(act>0.3)); tL=pts[first]; tA=tL+dT
print('frames',n,'band x0',x0,'w',w,'first activity t=%.3f'%tL,'expected attention at t=%.3f'%tA)
# template: rest frame 0.25 s before the attention request
iref=int(np.searchsorted(pts,tA-0.25)); ref=F[iref]
cy=int(round((fr[1]+(fr[3]-5)/2)*2))-Y0; half=int(round(tile*0.26*2)); cx=w//2
ty0,ty1,tx0,tx1=cy-half,cy+half,cx-half,cx+half
T=ref[ty0:ty1,tx0:tx1]
maxup=int(min(ty0-2,(tile+6)*2+8))
def track(f):
    ss=np.array([((f[ty0-d:ty1-d,tx0:tx1]-T)**2).mean() for d in range(-3,maxup)])
    k=int(ss.argmin()); d=k-3.0
    if 0<k<len(ss)-1:
        a,b,c=ss[k-1],ss[k],ss[k+1]; den=a-2*b+c
        if den>1e-9: d+=0.5*(a-c)/den
    return d/2.0, float(ss.min())   # points
tr=np.array([track(f) for f in F]); off=tr[:,0]; err=tr[:,1]
json.dump({'t':pts.round(4).tolist(),'offset_pt':off.round(3).tolist(),'ssd':err.round(1).tolist(),'iref':iref,'tile':tile,'ax_frame':fr},open(outf,'w'))
def launch(t,P,Hh,t0): 
    u=np.mod(t-t0,P)/P; return Hh*4*u*(1-u)
def attn(t,Hh,t0,s=1.0):
    u=np.mod((t-t0)*1000/s,2000.0); out=np.zeros_like(u); a=0.0
    for T_,A in ((500,1.0),(326,0.5),(212,0.25)):
        m=(u>=a)&(u<a+T_); x=np.abs(u[m]-a-T_/2); out[m]=A*(1-(x/(T_/2))**2); a+=T_
    return Hh*out
good=err<np.median(err)*6+50
# launch segment: from first bounce after tile insertion to end of periodic motion
segL=(pts>tL+0.1)&(pts<tL+9)&good
mv=np.where(segL&(off>0.5))[0]
res={}
if len(mv):
    a,b=mv[0],mv[-1]
    # split into contiguous run starting at a (BounceProbe launch); stop at first rest > 0.3 s
    e=a
    for i in range(a,b+1):
        if off[i]>0.5: e=i
        elif pts[i]-pts[e]>0.3: break
    sel=np.arange(max(a-3,0),min(e+4,n)); sel=sel[good[sel]]
    t=pts[sel]; y=off[sel]
    best=None
    for t0g in np.arange(t[0]-0.7,t[0]+0.05,0.02):
        r=least_squares(lambda q: np.where((t>=q[2])&(t<=pts[e]+0.02),launch(t,q[0],q[1],q[2]),0)-y,[0.7,y.max(),t0g])
        c=np.sqrt(np.mean(r.fun**2))
        if best is None or c<best[0]: best=(c,r.x)
    c,(P,Hh,t0)=best
    r2=least_squares(lambda q: np.where((t>=q[0])&(t<=pts[e]+0.02),launch(t,0.7,(tile-8)*0.2+6,q[0]),0)-y,[t0])
    nb=(pts[e]-t0)/P
    res['launch']={'n':int(len(t)),'period_s':round(float(P),4),'height_pt':round(float(Hh),3),'rms_pt':round(float(c),3),'bounces':round(float(nb),2),
                   'code_fixed_rms_pt':round(float(np.sqrt(np.mean(r2.fun**2))),3),'max_pt':round(float(y.max()),2),'t0':round(float(t0),4),'t_end':round(float(pts[e]),4)}
    res['launch_track']=[[round(float(a_),4),round(float(b_),3),round(float(launch(np.array([a_]),P,Hh,t0)[0]) if a_>=t0 else 0,3)] for a_,b_ in zip(t,y)]
segA=(pts>tA-0.1)&(pts<tA+5.9)&good
t=pts[segA]; y=off[segA]
if (y>2).any():
    ts=t[np.argmax(y>0.5)]
    best=None
    for t0g in np.arange(ts-0.06,ts+0.02,0.005):
        r=least_squares(lambda q: attn(t,q[0],q[1],q[2])*(t>=q[1])-y,[y.max(),t0g,1.0])
        c=np.sqrt(np.mean(r.fun**2))
        if best is None or c<best[0]: best=(c,r.x)
    c,(Hh,t0,s)=best
    r2=least_squares(lambda q: attn(t,q[0],q[1],1.0)*(t>=q[1])-y,[Hh,t0])
    res['attention']={'n':int(len(t)),'height_pt':round(float(Hh),3),'time_scale':round(float(s),4),'cycle_s':round(float(2*s),4),'rms_pt':round(float(c),3),
                      'fixed_timing_height_pt':round(float(r2.x[0]),3),'fixed_timing_rms_pt':round(float(np.sqrt(np.mean(r2.fun**2))),3),'max_pt':round(float(y.max()),2),'t0':round(float(t0),4)}
    res['attention_track']=[[round(float(a_),4),round(float(b_),3),round(float((attn(np.array([a_]),Hh,t0,s)*(a_>=t0))[0]),3)] for a_,b_ in zip(t,y)]
    # peaks per hop
    u=np.mod((t-t0)/s,2.0); pk=[]
    for a_,b_ in ((0,.5),(.5,.826),(.826,1.038)):
        m=(u>=a_)&(u<b_)&(t<t0+2*s)
        pk.append(round(float(y[m].max()),2) if m.any() else None)
    res['attention']['hop_peaks_pt_first_cycle']=pk
print(json.dumps({k:v for k,v in res.items() if not k.endswith('_track')},indent=1))
d=json.load(open(outf)); d.update(res); json.dump(d,open(outf,'w'))
