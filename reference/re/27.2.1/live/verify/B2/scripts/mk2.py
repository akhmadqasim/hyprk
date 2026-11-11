import json,os,sys
B=os.path.dirname(os.path.abspath(__file__))
def w(n,**k):
    c=dict(mode='dark',views=[],dump=f'{B}/cap/{n}.json'); c.update(k); json.dump(c,open(f'{B}/cfg/{n}.json','w'),indent=1)
sysk=dict(level='floating',policy='accessory',activate=False)
if sys.argv[1]=='static':
    pats=[(f's{L}',f'solid:{L},{L},{L}') for L in (0,40,80,120,160,200,240,255)]+[('grady','grady'),('gradx','gradx')]
    for nm,p in pats:
        w(f'ak-{nm}',pattern=p,origin=[40,60],size=[760,300],secs=2.3,
          views=[dict(frame=[60,60,633,48],radius=24,variant=3),dict(frame=[60,180,633,48],radius=24,variant=0)])
    w('vscan',pattern='solid:60,60,60',origin=[40,60],size=[760,960],secs=2.0,
      views=[dict(frame=[60,10+22*i,633,48],radius=24,variant=i) for i in range(0,41)])
    w('spot2-grey',pattern='solid:128,128,128',origin=[400,150],size=[900,400],secs=16.0,**sysk)
    w('spot2-white',pattern='solid:255,255,255',origin=[400,150],size=[900,400],secs=16.0,**sysk)
    w('dk64-find',pattern='solid:120,120,120',origin=[200,900],size=[1310,207],secs=2.2,**sysk)
else:
    # dock64 configs from the measured platter bbox (pt): x0 y0 x1 y1
    x0,y0,x1,y1=[float(v) for v in sys.argv[2:6]]
    ox=int(x0-50); oy=int(y0-40); W=int(min(1710-ox, x1-ox+60)); H=1107-oy
    for L in (0,40,80,120,160,200,240,255): w(f'dk64-s{L}',pattern=f'solid:{L},{L},{L}',origin=[ox,oy],size=[W,H],secs=2.2,**sysk)
    w('dk64-grady',pattern='grady',origin=[ox,oy],size=[W,H],secs=2.2,**sysk)
    w('dk64-gradx',pattern='gradx',origin=[ox,oy],size=[W,H],secs=2.2,**sysk)
    print(f'{ox},{oy},{W},{H}')
