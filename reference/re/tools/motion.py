# Summarise probe *-motion-*.json: window alpha/frame over time and every distinct CAAnimation seen.
import json,sys
d=json.load(open(sys.argv[1])); seen={}; tl={}
def f(v):
    if isinstance(v,float): return '%.4g'%v
    if isinstance(v,list): return '['+','.join(f(x) for x in v)+']'
    if isinstance(v,dict): return '{'+','.join('%s:%s'%(k,f(x)) for k,x in v.items())+'}'
    return str(v)
for s in d:
    for w in s['windows']:
        tl.setdefault(w['class'],[]).append((s['t'],w['alpha'],w['visible'],w['frame']))
        for a in w['animations']:
            key=(w['class'],a['layer'].split('/')[-1],a.get('keyPath'),a['key'])
            e=seen.setdefault(key,{'first':s['t'],'last':s['t'],'a':a,'n':0,'path':a['layer']})
            e['last']=s['t']; e['n']+=1
for c,v in tl.items():
    vis=[x for x in v if x[2]]
    print('WINDOW %s: visible %.3f..%.3f s, alpha values %s, frames %d distinct'%(c,vis[0][0] if vis else -1,vis[-1][0] if vis else -1,sorted({round(x[1],2) for x in v}),len({tuple(x[3]) for x in v})))
    prev=None
    for t,a,vi,fr in v:
        cur=(round(a,3),vi,tuple(round(x) for x in fr))
        if cur!=prev: print('   t=%.3f alpha=%.3f visible=%s frame=%s'%(t,a,vi,[round(x) for x in fr])); prev=cur
for k,e in sorted(seen.items(),key=lambda x:x[1]['first']):
    a=e['a']
    keep={x:a[x] for x in ('class','duration','timingFunction','from','to','by','mass','stiffness','damping','initialVelocity','settlingDuration','values','keyTimes','additive','beginTime','fillMode') if x in a and a[x] not in (None,'',False)}
    if 'beginTime' in keep: del keep['beginTime']
    print('ANIM t=%.3f..%.3f  %s  %s  key=%s keyPath=%s\n     %s\n     depth=%d'%(e['first'],e['last'],k[0],k[1],k[3],k[2],f(keep),e['path'].count('/')))
