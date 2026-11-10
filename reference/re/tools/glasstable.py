# Summarise probe variants-*.json: one line per config/size with the glassBackground inputs that differ
# from the `regular` config of the same size. Usage: glasstable.py variants-light.json [config-regex]
import json,sys,re
d=json.load(open(sys.argv[1])); pat=re.compile(sys.argv[2] if len(sys.argv)>2 else '.')
def fmt(v):
    if isinstance(v,float): return '%.4g'%v
    if isinstance(v,dict) and 'color' in v: return 'rgba(%s)'%','.join('%.3g'%x for x in v['color'])
    if isinstance(v,list): return '['+','.join(fmt(x) for x in v)+']'
    return str(v)
def glass(e):
    for l in e['layers']:
        for f in l.get('filters',[]):
            if isinstance(f,dict) and f.get('name')=='glassBackground': return f['inputs'],l
    return None,None
base={}
for e in d:
    if e['config']=='regular': base[tuple(e['size'])]=glass(e)[0]
for e in d:
    if not pat.search(e['config']): continue
    g,l=glass(e); sz=tuple(e['size'])
    print('## %s %dx%d'%(e['config'],sz[0],sz[1]))
    if g is None:
        print('   (no glassBackground filter)  layers:',', '.join(sorted({x['class'] for x in e['layers']}))); continue
    b=base.get(sz) or {}
    keys=sorted(g) if e['config']=='regular' else [k for k in sorted(set(g)|set(b)) if fmt(g.get(k))!=fmt(b.get(k))]
    print('   '+'  '.join('%s=%s'%(k.replace('input',''),fmt(g.get(k))) for k in keys))
    p=l.get('props',{})
    print('   backdrop: scale=%s marginWidth=%s'%(p.get('scale'),p.get('marginWidth')))
