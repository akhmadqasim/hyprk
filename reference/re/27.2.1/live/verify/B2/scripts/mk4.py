import json,os
B=os.path.dirname(os.path.abspath(__file__))
def w(n,**k):
    c=dict(mode='dark',views=[],dump=f'{B}/cap/{n}.json'); c.update(k); json.dump(c,open(f'{B}/cfg/{n}.json','w'),indent=1)
for cp in ('gradx','grady','checker:4','solid:255,255,255'):
    nm=cp.replace(':','').replace(',','')
    w(f'sw-{nm}',pattern='solid:90,90,90',content=cp,origin=[40,60],size=[1140,340],secs=3.4,
      views=[dict(frame=[30,30,520,87],shape='capsule',lense=True,size='large'),dict(frame=[580,30,520,87],shape='capsule',lense=False,size='large'),
             dict(frame=[30,150,300,150],shape='rrect:40',lense=True,size='large'),dict(frame=[360,150,300,150],shape='rrect:40',lense=False,size='large'),
             dict(frame=[700,150,200,44],shape='capsule',lense=True,size='auto'),dict(frame=[700,220,300,87],shape='capsule',lense=True,size='auto',inset=20)])
