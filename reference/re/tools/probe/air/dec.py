# crude LLVM IR -> expression printer for AIR shaders (annotated .ann.ll input)
import re,sys,struct
src=open(sys.argv[1]).read()
fn=sys.argv[2]
m=re.search(r'^define [^\n]*@'+re.escape(fn)+r'[^(]*\(.*?^\}',src,re.M|re.S)
lines=m.group(0).split('\n')
def hexf(s):
    def h(mo):
        v=int(mo.group(1),16); return '%.6g'%struct.unpack('>d',struct.pack('>Q',v))[0]
    s=re.sub(r'0x([0-9A-F]{16})\b',h,s)
    def hh(mo):
        import numpy as np
        return '%.5g'%float(np.frombuffer(struct.pack('<H',int(mo.group(1),16)),dtype=np.float16)[0])
    s=re.sub(r'0xH([0-9A-F]{4})',hh,s)
    s=re.sub(r'(\d\.\d+e[+-]\d+)',lambda mo:'%g'%float(mo.group(1)),s)
    return s
uses={}
for l in lines[1:]:
    body=l.split('=',1)[1] if re.match(r'\s*%\d+ = ',l) else l
    for u in re.findall(r'%\d+',body): uses[u]=uses.get(u,0)+1
expr={}; blockof={}
T=r'(?:<\d+ x \w+>|float|half|i\d+|double|ptr|\{[^}]*\})'
def strip(a):
    a=a.strip()
    a=re.sub(r'^(readonly captures\(none\) )','',a)
    a=re.sub(r'^'+T+r'\s+','',a)
    a=re.sub(r'splat \((?:float|half) ([^)]+)\)',r'\1',a)
    return a
def splitargs(s):
    out=[];d=0;cur=''
    for ch in s:
        if ch in '(<{[': d+=1
        if ch in ')>}]': d-=1
        if ch==',' and d==0: out.append(cur);cur=''
        else: cur+=ch
    if cur.strip(): out.append(cur)
    return out
def R(tok,blk):
    tok=strip(tok)
    def sub(mo):
        v=mo.group(0)
        if v in expr and uses.get(v,0)==1 and blockof.get(v)==blk and len(expr[v])<160: return '('+expr[v]+')' if re.search(r'[ ]',expr[v]) and not re.match(r'^[\w.]+\(.*\)$',expr[v]) else expr[v]
        if v in expr and re.match(r'^(U|X)\.\w+$',expr[v]): return expr[v]
        return v
    return re.sub(r'%\d+',sub,tok)
ops={'fadd':'+','fsub':'-','fmul':'*','fdiv':'/','add':'+','sub':'-','mul':'*','and':'&','or':'|','xor':'^'}
blk='entry'; out=[]
for l in lines[1:-1]:
    l=hexf(l.rstrip())
    mo=re.match(r'^(\d+):',l)
    if mo: blk=mo.group(1); out.append('L%s:  %s'%(blk,l.split(';')[-1].strip())); continue
    mo=re.match(r'\s*(%\d+) = (.*)$',l)
    if not mo:
        s=l.strip()
        s=re.sub(r'br i1 (%\d+), label %(\d+), label %(\d+)',lambda q:'if %s goto L%s else L%s'%(R(q.group(1),blk),q.group(2),q.group(3)),s)
        s=re.sub(r'br label %(\d+)',r'goto L\1',s)
        if s.startswith('ret'): s='return '+R(s.split(None,1)[1],blk)
        out.append('    '+s); continue
    v,rhs=mo.groups(); blockof[v]=blk; e=None
    rhs=re.sub(r' #\d+$','',rhs); rhs=re.sub(r', !range !\d+','',rhs)
    q=re.match(r'GEP ([UX]\.\w+)',rhs)
    if q: expr[v]=q.group(1); continue
    q=re.match(r'load '+T+r', (%\d+)',rhs)
    if q and q.group(1) in expr: expr[v]=expr[q.group(1)]; continue
    q=re.match(r'(fadd|fsub|fmul|fdiv|add|sub|mul|and|or|xor) (?:\w+ )*?('+T+r') (.*)$',rhs)
    if q:
        a=splitargs(q.group(3)); e='%s %s %s'%(R(a[0],blk),ops[q.group(1)],R(a[1],blk))
    q2=re.match(r'fneg '+T+r' (.*)$',rhs)
    if q2: e='-'+R(q2.group(1),blk)
    q2=re.match(r'call .*?@air\.([\w.]+)\((.*)\)$',rhs)
    if q2:
        name=re.sub(r'\.(v\d)?[fi]\d+$','',q2.group(1)).replace('fast_','')
        args=[R(a,blk) for a in splitargs(q2.group(2))]
        if name.startswith('sample_texture_2d'): e='sample(%s, uv=%s, lodflag=%s, lod=%s)'%(args[0],args[2],args[5],args[6])
        else: e='%s(%s)'%(name,', '.join(args))
    q2=re.match(r'call .*?@(_Z\w+)\((.*)\)$',rhs)
    if q2 and e is None: e='%s(%s)'%(q2.group(1)[:24],', '.join(R(a,blk) for a in splitargs(q2.group(2))))
    q2=re.match(r'(fcmp|icmp) (\w+) '+T+r' (.*)$',rhs)
    if q2:
        a=splitargs(q2.group(3)); c={'olt':'<','ogt':'>','ole':'<=','oge':'>=','oeq':'==','une':'!=','ult':'!>=','ugt':'!<=','ule':'!>','uge':'!<','eq':'==','ne':'!=','one':'!=','ueq':'=='}.get(q2.group(2),q2.group(2))
        e='%s %s %s'%(R(a[0],blk),c,R(a[1],blk))
    q2=re.match(r'select (?:[\w ]+ )?(?:i1|<\d+ x i1>) (.*)$',rhs)
    if q2:
        a=splitargs(q2.group(1)); e='%s ? %s : %s'%(R(a[0],blk),R(a[1],blk),R(a[2],blk))
    q2=re.match(r'extractelement '+T+r' (.*), i64 (\d+)$',rhs)
    if q2: e='%s.%s'%(R(q2.group(1),blk),'xyzw'[int(q2.group(2))])
    q2=re.match(r'extractvalue .*? (%\d+), 0$',rhs)
    if q2: e=R(q2.group(1),blk)
    q2=re.match(r'insertelement '+T+r' (.*), (?:float|half|i\d+) (.*), i64 (\d+)$',rhs)
    if q2:
        base=R(q2.group(1),blk); val=R(q2.group(2),blk)
        e='vec(%s)'%val if base in('poison','undef') and q2.group(3)=='0' else 'ins(%s, %s=%s)'%(base,'xyzw'[int(q2.group(3))],val)
    q2=re.match(r'shufflevector '+T+r' (.*), '+T+r' (poison|undef|%\d+|zeroinitializer), <\d+ x i32> (.*)$',rhs)
    if q2:
        a=R(q2.group(1),blk); msk=q2.group(3)
        if msk=='zeroinitializer': e='splat(%s)'%re.sub(r'^vec\((.*)\)$',r'\1',a)
        else:
            idx=re.findall(r'i32 (\d+|poison|undef)',msk)
            if q2.group(2) in('poison','undef'): e='%s.%s'%(a,''.join('xyzw'[int(i)] if i.isdigit() else '_' for i in idx))
            else: e='shuf(%s, %s, [%s])'%(a,R(q2.group(2),blk),','.join(idx))
    q2=re.match(r'(fpext|fptrunc|sitofp|uitofp|fptosi|fptoui|zext|sext|trunc|bitcast) '+T+r' (.*) to (.*)$',rhs)
    if q2: e=R(q2.group(2),blk) if q2.group(1) in('fpext','fptrunc','zext') else '%s(%s)'%(q2.group(1),R(q2.group(2),blk))
    if rhs.startswith('phi'):
        ps=re.findall(r'\[ (.*?), %(\d+) \]',rhs); out.append('    %s = phi %s'%(v,'  '.join('[%s from L%s]'%(strip(a),b) for a,b in ps))); continue
    if e is None: e='?? '+rhs
    expr[v]=e
    if not(uses.get(v,0)==1 and len(e)<160) : out.append('    %s = %s'%(v,e))
    else: out.append(('#DEFER',v,blk,e))
# deferred single-use: print only if never inlined (used in another block or phi)
txt=[o for o in out if isinstance(o,str)]
alltxt='\n'.join(txt)
final=[]
for o in out:
    if isinstance(o,str): final.append(o)
    else:
        _,v,b,e=o
        if re.search(re.escape(v)+r'\b',alltxt): final.append('    %s = %s'%(v,e))
print('\n'.join(final))
