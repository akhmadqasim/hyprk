# Measure UI animations in a screen recording. Usage: vidmotion.py video.mp4 [W H]
# Pass 1: find segments where consecutive frames differ. Pass 2: for each segment, per frame, the
# bounding box of pixels that differ from the frame just before the segment, and how far the change
# has progressed (mean abs diff inside the final box, normalised to the last frame of the segment).
import subprocess,sys,json
from PIL import Image,ImageChops,ImageStat
V=sys.argv[1]; W=int(sys.argv[2]) if len(sys.argv)>2 else 1100; H=int(sys.argv[3]) if len(sys.argv)>3 else 750; FPS=60.0
def frames():
    p=subprocess.Popen(['ffmpeg','-loglevel','error','-i',V,'-vf','scale=%d:%d:flags=area'%(W,H),'-f','rawvideo','-pix_fmt','rgb24','-'],stdout=subprocess.PIPE)
    n=W*H*3
    while True:
        b=p.stdout.read(n)
        if len(b)<n: break
        yield Image.frombytes('RGB',(W,H),b)
act=[]; prev=None; keep={}
fs=[]
for i,f in enumerate(frames()):
    g=f.convert('L')
    if prev is not None:
        d=ImageChops.difference(g,prev).point(lambda x:255 if x>6 else 0)
        act.append(ImageStat.Stat(d).sum[0]/255)
    else: act.append(0)
    prev=g; fs.append(g)
segs=[]; cur=None
for i,a in enumerate(act):
    if a>40:
        if cur and i-cur[1]<=6: cur[1]=i
        else:
            cur=[i,i]; segs.append(cur)
out=[]
for s,e in segs:
    if e-s<2: continue
    ref=fs[max(s-1,0)]; last=fs[min(e+1,len(fs)-1)]
    fin=ImageChops.difference(last,ref).point(lambda x:255 if x>6 else 0); box=fin.getbbox()
    if not box: box=(0,0,W,H)
    tot=ImageStat.Stat(ImageChops.difference(last,ref).crop(box)).sum[0] or 1
    rows=[]
    for i in range(s-1,e+2):
        if i<0 or i>=len(fs): continue
        d=ImageChops.difference(fs[i],ref); bb=d.point(lambda x:255 if x>6 else 0).getbbox()
        prog=ImageStat.Stat(ImageChops.difference(fs[i],last).crop(box)).sum[0]/tot
        rows.append({'f':i,'t':round((i-s+1)/FPS,4),'bbox':bb,'remaining':round(prog,4)})
    out.append({'start':round(s/FPS,3),'end':round(e/FPS,3),'duration':round((e-s+1)/FPS,3),'finalBox':box,'frames':rows})
json.dump(out,sys.stdout)
