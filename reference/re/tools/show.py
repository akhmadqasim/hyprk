import sys,re
F=sys.argv[1]; fn={}
cur=None
for l in open(F):
    if l.startswith('//===='): cur=l.split()[1]; fn[cur]=[]
    elif cur: fn[cur].append(l)
def show(a,depth=0):
    a=a.lower().replace('0x','')
    body=''.join(fn.get(a,['<missing>\n']))
    m=re.search(r'thunk_FUN_([0-9a-f]+)',body)
    if m and len(body)<200 and depth<4: print('// %s -> thunk %s'%(a,m.group(1))); return show(m.group(1),depth+1)
    body=re.sub(r'\n\s*\n','\n',body)
    print('// ===',a); print(body)
for a in sys.argv[2:]: show(a)
