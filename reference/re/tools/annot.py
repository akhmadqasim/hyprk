# Usage: annot.py <dump.c> spec|params <addr>...   Prints a function (following thunks) with
# param_1 offsets replaced by Spec/Parameters field names and float/double hex constants decoded.
import sys,re,struct,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from layout import MAPS
F=sys.argv[1]; M=MAPS[sys.argv[2]]; KIND=sys.argv[2]; fn={}; cur=None
BIN=os.path.join(os.path.dirname(os.path.abspath(F)),'..','DesignLibrary'); BB=open(BIN,'rb').read() if os.path.exists(BIN) else b''
TEXT_VA=0x195d88000   # __TEXT vmaddr, file offset 0
def data(m):
    va=int(m.group(1),16); o=va-TEXT_VA
    if not (0<=o<len(BB)-8) or va>0x196000000: return m.group(0)
    d=struct.unpack_from('<d',BB,o)[0]; f=struct.unpack_from('<ff',BB,o)
    if d==0 or 1e-6<abs(d)<1e7: return '{d %.6g}'%d
    return '{f %.6g, %.6g}'%f
for l in open(F):
    if l.startswith('//===='): cur=l.split()[1]; fn[cur]=[]
    elif cur: fn[cur].append(l)
def name(o): return '<'+M.get(o,'+%#x'%o)+'>'
def const(m):
    h=m.group(0); v=int(h,16)
    if len(h)==18:
        d=struct.unpack('<d',struct.pack('<Q',v))[0]
        if 1e-6<abs(d)<1e7: return '%.6g'%d
        lo,hi=struct.unpack('<ff',struct.pack('<Q',v))
        if all(x==0 or 1e-6<abs(x)<1e7 for x in (lo,hi)): return '(f %.6g, f %.6g)'%(lo,hi)
    elif len(h)==10:
        f=struct.unpack('<f',struct.pack('<I',v))[0]
        if 1e-6<abs(f)<1e7: return '%.6gf'%f
    return h
def show(a,depth=0):
    a=a.lower().replace('0x','')
    body=''.join(fn.get(a,['<missing>\n']))
    m=re.search(r'thunk_FUN_([0-9a-f]+)',body)
    if m and len(body)<200 and depth<4: return show(m.group(1),depth+1)
    scaled=bool(re.search(r'\(undefined8 \*param_1|\(double \*param_1|\(long \*param_1',body))
    k=8 if scaled else 1
    body=re.sub(r'\(long\)param_1 \+ (0x[0-9a-f]+|\d+)',lambda m:name(int(m.group(1),0)),body)
    body=re.sub(r'param_1\[(0x[0-9a-f]+|\d+)\]',lambda m:name(int(m.group(1),0)*8),body)
    body=re.sub(r'param_1 \+ (0x[0-9a-f]+|\d+)',lambda m:name(int(m.group(1),0)*k),body)
    body=re.sub(r'\*param_1\b',name(0),body)
    body=re.sub(r'\*\(\w+ \*\)\(?(<[^>]+>)\)?',r'\1',body)
    body=re.sub(r'\b0x[0-9a-f]{16}\b|\b0x[0-9a-f]{8}\b',const,body)
    body=re.sub(r'\b_?(?:DAT|UNK)_(195f[0-9a-f]{5})\b',data,body)
    body=re.sub(r'\n\s*\n','\n',body)
    print('// ===',a,sys.argv[2]); print(body)
for a in sys.argv[3:]: show(a)
