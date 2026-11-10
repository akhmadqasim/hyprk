import json
def views(p):
    d=json.load(open(p)); out=[]
    for v in d['views']:
        g={}; bd={}; eff=None; mat=None
        def walk(l):
            nonlocal eff,mat
            for f in l.get('filters',[]):
                if f['name']=='glassBackground': g.update(f['inputs']); bd.update(l.get('backdrop',{}))
            if l.get('effect') and 'Highlight' in l['effect'].get('class',''):
                eff=l['effect']; mat=[f['inputs'].get('inputColorMatrix') for f in l.get('filters',[])]
                eff=dict(eff); eff['_hidden']=l['hidden']; eff['_opacity']=l['opacity']
            for s in l.get('sublayers',[]): walk(s)
        walk(v['layers']); out.append(dict(cfg=v['config'],glass=g,backdrop=bd,effect=eff,matrix=mat))
    return d,out
def short(g,keys):
    return {k.replace('input',''):(round(v,3) if isinstance(v,float) else v) for k,v in sorted(g.items()) if any(s in k for s in keys)}
