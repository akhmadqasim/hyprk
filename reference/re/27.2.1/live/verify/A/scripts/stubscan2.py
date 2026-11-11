import re,sys,collections,ctypes
from mem import *
from t2 import gp
for lib in sys.argv[4:]: ctypes.CDLL(lib)
BASE=0x190404000
targets={}
for l in open('suic.exp'):
    p=l.split()
    if len(p)>=2 and p[0].startswith('0x') and re.search(sys.argv[3],p[1]):
        targets[BASE+int(p[0],16)]=p[1]
cands=collections.defaultdict(list)
for l in open(sys.argv[1]):
    m=re.match(r'0x([0-9A-F]+)\s+bl?\s+0x([0-9a-f]+)',l)
    if m: cands[int(m.group(2),16)].append(int(m.group(1),16))
n=0
for t,sites in sorted(cands.items()):
    try:
        s=stub(t)
        if s[0] and s[1]=='adrp/add' and s[2]=='0xf9400230':
            n+=1
            tt=gp(s[0])
            if tt in targets: print(hex(t),targets[tt],len(sites),[hex(x) for x in sites[:int(sys.argv[2])]])
    except Exception as e: pass
print('stubs',n)
