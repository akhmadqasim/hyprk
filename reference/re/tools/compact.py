# Reduce probe variants-<mode>.json to glass-params-<mode>.json: per config, per D (shortest side),
# the resolved glassBackground filter inputs, the backdrop layer scale/margin and the other filters.
import json,sys
src,dst=sys.argv[1],sys.argv[2]
out={}
def rnd(v):
    if isinstance(v,float): return round(v,5)
    if isinstance(v,list): return [rnd(x) for x in v]
    if isinstance(v,dict): return {k:rnd(x) for k,x in v.items()}
    return v
for e in json.load(open(src)):
    rec={'size':e['size'],'cornerRadius':e['cornerRadius'],'glass':None,'other':[],'appActive':e.get('appActive'),'keyWindow':e.get('keyWindow')}
    for l in e['layers']:
        for kind in ('filters','backgroundFilters'):
            for f in l.get(kind,[]):
                if not isinstance(f,dict): continue
                if f.get('name')=='glassBackground':
                    rec['glass']=rnd(f['inputs']); p=l.get('props',{})
                    rec['backdrop']={k:p.get(k) for k in ('scale','marginWidth','groupName','lumaUpdateRate')}
                else:
                    rec['other'].append({'layer':l['path'].split('/')[-1],'name':f.get('name'),'inputs':rnd(f.get('inputs'))})
        cf=l.get('compositingFilter')
        if cf: rec['other'].append({'layer':l['path'].split('/')[-1],'compositing':cf if isinstance(cf,str) else cf.get('name')})
        if 'props' in l and 'effect' in l['props'] and isinstance(l['props']['effect'],dict):
            rec['other'].append({'layer':l['path'].split('/')[-1],'effect':rnd(l['props']['effect'])})
    out.setdefault(e['config'],{})[str(int(e['size'][1]))]=rec
json.dump(out,open(dst,'w'),indent=1,sort_keys=True)
print(dst,len(out),'configs')
