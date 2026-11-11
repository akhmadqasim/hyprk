import json,os
B=os.path.dirname(os.path.abspath(__file__))
def w(n,**k):
    c=dict(mode='dark',views=[],dump=f'{B}/cap/{n}.json'); c.update(k); json.dump(c,open(f'{B}/cfg/{n}.json','w'),indent=1)
sysk=dict(level='floating',policy='accessory',activate=False)
for L in (0,40,80,120,160,200,240,255):
    w(f'dock-s{L}',pattern=f'solid:{L},{L},{L}',origin=[440,1000],size=[830,107],secs=2.2,**sysk)
w('dock-grady',pattern='grady',origin=[440,1000],size=[830,107],secs=2.2,**sysk)
w('dock-gradx',pattern='gradx',origin=[488,1000],size=[782,107],secs=2.2,**sysk)
w('dock-hs',pattern='hstripes:4',origin=[440,1000],size=[830,107],secs=2.2,**sysk)
w('dock-grid',pattern='grid:8',origin=[440,1000],size=[830,107],secs=2.2,**sysk)
for nm,p in (('grey','solid:128,128,128'),('white','solid:255,255,255'),('black','solid:0,0,0'),('cols','cols:255,0,0:0,255,0:0,0,255:255,255,0')):
    w(f'menu-{nm}',pattern=p,origin=[40,60],size=[500,420],secs=8.5,popupMenu=[120,60],dumpWindowsAt=[2.5,4.0])
    w(f'cc-{nm}',pattern=p,origin=[1200,34],size=[510,700],secs=7.0,**sysk)
V=lambda fr,r,lens,cp,**k: dict(frame=fr,radius=r,variant=0,kv=({'_contentLensing':True} if lens else {}),contentPattern=cp,**k)
for cp in ('gradx','grady','grad','checker:4'):
    w(f'lens-{cp.replace(":","")}',pattern='solid:90,90,90',origin=[40,60],size=[1140,520],secs=3.4,
      views=[V([30,30,520,87],43.5,True,cp),V([580,30,520,87],43.5,False,cp),V([30,150,300,150],40,True,cp),V([360,150,300,150],40,False,cp),
             V([700,150,200,44],22,True,cp),V([700,220,64,64],32,True,cp),V([30,330,520,87],43.5,True,cp,contentInset=10)])
for nm,p in (('white','solid:255,255,255'),('vs','vstripes:6'),('grey','solid:128,128,128')):
    w(f'spot-{nm}',pattern=p,origin=[400,150],size=[900,400],secs=9.0,**sysk)
