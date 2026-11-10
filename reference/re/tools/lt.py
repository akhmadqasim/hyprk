# Compact layer-tree printer for probe JSON. Usage: lt.py file.json [substring-of-class-to-root-at] [maxdepth]
import json,sys
def short(v):
    if isinstance(v,float): return '%.4g'%v
    if isinstance(v,list): return '['+','.join(short(x) for x in v)+']'
    if isinstance(v,dict):
        if 'color' in v: return 'rgba'+short(v['color'])
        return '{'+','.join('%s:%s'%(k,short(x)) for k,x in v.items())+'}'
    return str(v)
def show(l,d=0,maxd=99):
    ind='  '*d
    keys=[k for k in l if k not in('class','sublayers','filters','backgroundFilters','mask','props','animations','frame')]
    print('%s%s %s %s'%(ind,l['class'],short(l.get('frame')),' '.join('%s=%s'%(k,short(l[k])) for k in keys)))
    for kind in ('filters','backgroundFilters'):
        for f in l.get(kind,[]):
            if isinstance(f,dict): print('%s  ~%s %s: %s'%(ind,kind[:-1],f.get('name'),short(f.get('inputs'))))
            else: print('%s  ~%s %s'%(ind,kind[:-1],f))
    if 'props' in l: print('%s  .props %s'%(ind,short({k:v for k,v in l['props'].items() if v not in (None,0,False,'')})))
    for k,a in l.get('animations',{}).items(): print('%s  @anim %s %s'%(ind,k,short({x:y for x,y in a.items() if x!='extra'})))
    if 'mask' in l: print(ind+'  mask:'); show(l['mask'],d+2,maxd)
    if d<maxd:
        for s in l.get('sublayers',[]): show(s,d+1,maxd)
def find(l,sub,out):
    if sub in l['class'] or sub==l.get('name'): out.append(l); return
    for s in l.get('sublayers',[]): find(s,sub,out)
d=json.load(open(sys.argv[1]))
roots=[w['layers'] for w in d] if isinstance(d,list) else [d['layers']]
sub=sys.argv[2] if len(sys.argv)>2 else None; maxd=int(sys.argv[3]) if len(sys.argv)>3 else 99
for r in roots:
    if sub:
        out=[]; find(r,sub,out)
        for o in out: show(o,0,maxd); print('-----')
    else: show(r,0,maxd)
