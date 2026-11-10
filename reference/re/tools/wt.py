import struct,sys,re
b=open(sys.argv[1],'rb').read()
pat=re.compile(sys.argv[2])
assert struct.unpack_from('<I',b,0)[0]==0xfeedfacf
ncmds=struct.unpack_from('<I',b,16)[0]; off=32; secs=[]; segs=[]
for _ in range(ncmds):
    cmd,sz=struct.unpack_from('<II',b,off)
    if cmd==0x19:
        segname=b[off+8:off+24].rstrip(b'\0').decode(); vmaddr,vmsize,fileoff,filesz=struct.unpack_from('<QQQQ',b,off+24)
        nsects=struct.unpack_from('<I',b,off+64)[0]; segs.append((segname,vmaddr,vmsize,fileoff,filesz))
        for i in range(nsects):
            so=off+72+i*80
            sn=b[so:so+16].rstrip(b'\0').decode(); addr,size=struct.unpack_from('<QQ',b,so+32); fo=struct.unpack_from('<I',b,so+48)[0]
            secs.append((segname,sn,addr,size,fo))
    off+=sz
def v2o(v):
    for n,va,vs,fo,fs in segs:
        if va<=v<va+fs: return v-va+fo
    return None
def segof(v):
    for n,va,vs,fo,fs in segs:
        if va<=v<va+vs: return n
def i32(v): return struct.unpack_from('<i',b,v2o(v))[0]
def u32(v): return struct.unpack_from('<I',b,v2o(v))[0]
def u64(v): return struct.unpack_from('<Q',b,v2o(v))[0]
def cstr(v):
    o=v2o(v); e=b.index(b'\0',o); return b[o:e].decode('latin1')
def name_of(desc):
    parts=[]
    try:
        d=desc
        for _ in range(6):
            fl=u32(d); kind=fl&0x1f
            if kind in (16,17,18): parts.append(cstr(d+8+i32(d+8)))
            elif kind==1: parts.append('ext'); 
            elif kind==0: parts.append(cstr(d+8+i32(d+8))); break
            elif kind==2: parts.append('anon')
            p=i32(d+4)
            if p==0: break
            pa=d+4+p
            if pa&1: pa=0x180000000+(u64(pa&~1)&0x3ffffffff)
            d=pa
        return '.'.join(reversed(parts))
    except Exception as e: return '.'.join(reversed(parts))+'?'
text=[s for s in secs if s[1]=='__text'][0]
proto=[s for s in secs if s[1]=='__swift5_proto'][0]
print('segs',[(s[0],hex(s[1])) for s in segs],file=sys.stderr)
for i in range(proto[3]//4):
    e=proto[2]+i*4; cd=e+i32(e)
    pr=cd+i32(cd); 
    tref=cd+4+i32(cd+4); wt=i32(cd+8); flags=u32(cd+12)
    tk=(flags>>3)&7
    try:
        if tk==1: tref=0x180000000+(u64(tref)&0x3ffffffff)
    except Exception: continue
    if tk>1: continue
    # protocol name
    p=cd+i32(cd)
    try:
        if p&1: p=0x180000000+(u64(p&~1)&0x3ffffffff)
        pn=cstr(p+8+i32(p+8)) if v2o(p) is not None else 'extproto'
    except Exception: pn='?'
    tn=name_of(tref)
    full=tn+' : '+pn
    if not pat.search(full): continue
    if wt==0: print(full,'no wt'); continue
    w=cd+8+wt
    ents=[]
    for k in range(1,12):
        try: q=u64(w+8*k)
        except Exception: break
        ents.append(q)
    print(full,hex(w),' '.join(hex(x) for x in ents))
