import json,os
B=os.path.dirname(os.path.abspath(__file__))
def w(n,**k):
    c=dict(mode='dark',views=[],dump=f'{B}/cap/{n}.json'); c.update(k); json.dump(c,open(f'{B}/cfg/{n}.json','w'),indent=1)
pats=[(f's{L}',f'solid:{L},{L},{L}') for L in (0,40,80,120,160,200,240,255)]+[('grady','grady'),('gradx','gradx')]
for nm,p in pats:
    w(f'sd-{nm}',pattern=p,content='none',origin=[40,60],size=[760,420],secs=2.6,
      views=[dict(frame=[60,60,633,48],shape='rrect:16',base='dock',size='medium'),dict(frame=[60,180,633,48],shape='rrect:16',base='dock',size='auto'),
             dict(frame=[60,300,633,84],shape='rrect:22',base='dock',size='medium')])
