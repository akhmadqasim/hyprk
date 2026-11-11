import subprocess, sys, json, numpy as np
from scipy.optimize import least_squares
v='hud.mp4'; W,H=900,260
pts=[float(p.strip(',')) for p in subprocess.run(['ffprobe','-v','error','-select_streams','v:0','-show_entries','frame=pts_time','-of','csv=p=0',v],capture_output=True,text=True).stdout.split() if p.strip(',')]
p=subprocess.Popen(['ffmpeg','-loglevel','error','-i',v,'-fps_mode','passthrough','-f','rawvideo','-pix_fmt','rgb24','-'],stdout=subprocess.PIPE)
F=[]
while True:
    b=p.stdout.read(W*H*3)
    if len(b)<W*H*3: break
    F.append(np.frombuffer(b,np.uint8).reshape(H,W,3).astype(np.float32).mean(axis=2))
F=np.array(F); n=len(F); pts=np.array(pts[:n]); pts-=pts[0]
starts=[100,310,523,734]
cx,cy=565.0,114.0
def edge(prof, lo, hi, rev=False):
    # sub-pixel position where |diff| profile crosses half of its plateau, scanning from outside
    seg=prof[lo:hi]; 
    if rev: seg=seg[::-1]
    pl=np.percentile(seg,85)
    if pl<1.5: return None, pl
    k=int(np.argmax(seg>0.5*pl))
    if k==0: return None, pl
    a,b=seg[k-1],seg[k]; x=k-1+(0.5*pl-a)/(b-a)
    return ((hi-1-x) if rev else (lo+x)), pl
out=[]
for s in starts:
    bg=F[s-12:s-2].mean(axis=0)
    rows=[]
    for i in range(s-4,s+75):
        f=F[i]; D=np.abs(f-bg)
        # left edge along centre band; top and bottom edges along a column band left of the bar (x 300..360 is glyph) -> use x 420..520 above/below bar
        px=D[int(cy)-5:int(cy)+6,:].mean(axis=0)
        xl,pl=edge(px,180,290)
        py=D[:,420:520].mean(axis=1)
        yt,_=edge(py,20,100); yb,_=edge(py,130,230,rev=True)
        # glyph brightness: 98th percentile of (f-bg) in the glyph box (scaled box generous)
        g=(f-bg)[84:146,286:362]; gl=np.percentile(g,97)
        rows.append([None if q is None else float(q) for q in (pts[i]-pts[s], xl, yt, yb, gl, pl)])
    out.append(rows)
json.dump(out,open('hud-track.json','w'))
for rows in out[:2]:
    for r in rows[:45]: print(' '.join('%7.3f'%x if x is not None else '   None' for x in r))
    print()
