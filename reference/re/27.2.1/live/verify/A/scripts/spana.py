import subprocess, sys, json, numpy as np
v='sp.mp4'; X0,Y0,W,H=600,330,1400,320
pts=[float(p.strip(',')) for p in subprocess.run(['ffprobe','-v','error','-select_streams','v:0','-show_entries','frame=pts_time','-of','csv=p=0',v],capture_output=True,text=True).stdout.split() if p.strip(',')]
p=subprocess.Popen(['ffmpeg','-loglevel','error','-i',v,'-vf',f'crop={W}:{H}:{X0}:{Y0},format=gray','-fps_mode','passthrough','-f','rawvideo','-pix_fmt','gray','-'],stdout=subprocess.PIPE)
F=[]
while True:
    b=p.stdout.read(W*H)
    if len(b)<W*H: break
    F.append(np.frombuffer(b,np.uint8).reshape(H,W))
F=np.array(F); n=len(F); pts=np.array(pts[:n]); pts-=pts[0]
bg=F[:20].astype(np.float32).mean(axis=0)
act=np.array([np.abs(f.astype(np.float32)-bg).mean() for f in F])
thr=act.max()*0.15; on=act>thr
starts=[i for i in range(1,n) if on[i] and not on[i-1] and not on[max(i-20,0):i].any()]
print('n',n,'starts',[(i,round(float(pts[i]),3)) for i in starts],'act max',act.max())
def edge(prof, lo, hi, rev=False, frac=0.5):
    seg=prof[lo:hi]
    if rev: seg=seg[::-1]
    pl=np.percentile(seg,85)
    if pl<1.0: return None
    k=int(np.argmax(seg>frac*pl))
    if k==0: return None
    a,b=seg[k-1],seg[k]; x=k-1+(frac*pl-a)/(b-a)
    return float((hi-1-x) if rev else (lo+x))
def bright(f, x0,x1,y0,y1):
    g=f[y0:y1,x0:x1]; mx=np.percentile(g,99.5)
    if mx<25: return None
    m=g>0.5*mx; ys,xs=np.where(m)
    return [float(xs.min()+x0),float(xs.max()+x0),float(ys.min()+y0),float(ys.max()+y0),float(mx)]
out=[]
for s in starts:
    bgl=F[s-30:s-18].astype(np.float32).mean(axis=0); rows=[]
    for i in range(s-16,min(s+60,n)):
        f=F[i].astype(np.float32); D=np.abs(f-bgl)
        px=D[150:170,:].mean(axis=0); py=D[:,650:1000].mean(axis=1)
        xl=edge(px,0,400); xr=edge(px,1000,1400,rev=True); yt=edge(py,0,150); yb=edge(py,170,320,rev=True)
        d=f-bgl
        mic=bright(d,1000,1400,40,280); txt=bright(d,150,700,40,280)
        rows.append({'t':round(float(pts[i]-pts[s]),4),'xl':xl,'xr':xr,'yt':yt,'yb':yb,'mic':mic,'txt':txt,'dup':bool(i>0 and (F[i]==F[i-1]).all())})
    out.append(rows)
json.dump(out,open('sp-track.json','w'))
f=lambda v: '  None' if v is None else '%7.1f'%v
for r in out[0][:50]:
    print(r['t'],r['dup'],f(r['xl']),f(r['xr']),f(r['yt']),f(r['yb']),'mic',[round(x,1) for x in r['mic']] if r['mic'] else None,'txt',[round(x,1) for x in r['txt']] if r['txt'] else None)
print('act by 0.25s:',' '.join('%.1f'%act[i:i+15].max() for i in range(0,n,15)))
