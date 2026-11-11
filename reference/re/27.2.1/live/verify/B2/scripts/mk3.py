import json,os
B=os.path.dirname(os.path.abspath(__file__))
def w(n,**k):
    c=dict(mode='dark',views=[],dump=f'{B}/cap/{n}.json'); c.update(k); json.dump(c,open(f'{B}/cfg/{n}.json','w'),indent=1)
def V(fr,kv,cp): return dict(frame=fr,radius=43.5,variant=0,kv=kv,contentPattern=cp)
for cp in ('gradx','grady','checker:4'):
    w(f'l3-{cp.replace(":","")}',pattern='solid:90,90,90',origin=[40,60],size=[1140,420],secs=3.2,
      views=[V([30,30,520,87],{'_contentLensing':True},cp),V([580,30,520,87],{'_contentLensing':True,'_placesContentAboveGlass':False},cp),
             V([30,150,520,87],{'_placesContentAboveGlass':False},cp),V([580,150,520,87],{'_contentLensing':True,'_placesContentAboveGlass':True},cp),
             V([30,270,520,87],{'_contentLensing':True,'_effectIsInteractive':True},cp)])
w('l3-istate',pattern='solid:90,90,90',origin=[40,60],size=[1140,180],secs=3.0,views=[V([30,30,520,87],{'_contentLensing':True,'_interactionState':1},'checker:4'),V([580,30,520,87],{'_contentLensing':True,'_interactionState':2},'checker:4')])
