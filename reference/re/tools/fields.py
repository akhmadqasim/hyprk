import struct,sys,re
b=open(sys.argv[1],'rb').read()
ncmds=struct.unpack_from('<I',b,16)[0]; off=32; secs={}; segs=[]
for _ in range(ncmds):
    cmd,sz=struct.unpack_from('<II',b,off)
    if cmd==0x19:
        vmaddr,vmsize,fileoff,filesz=struct.unpack_from('<QQQQ',b,off+24); segs.append((vmaddr,vmsize,fileoff,filesz))
        for i in range(struct.unpack_from('<I',b,off+64)[0]):
            so=off+72+i*80; secs[b[so:so+16].rstrip(b'\0').decode()]=struct.unpack_from('<QQ',b,so+32)
    off+=sz
def v2o(v):
    for va,vs,fo,fs in segs:
        if va<=v<va+fs: return v-va+fo
    raise KeyError(hex(v))
def i32(v): return struct.unpack_from('<i',b,v2o(v))[0]
def u32(v): return struct.unpack_from('<I',b,v2o(v))[0]
def u16(v): return struct.unpack_from('<H',b,v2o(v))[0]
def u64(v): return struct.unpack_from('<Q',b,v2o(v))[0]
def cstr(v):
    o=v2o(v); e=b.index(b'\0',o); return b[o:e].decode('latin1')
def ctxname(d):
    parts=[]
    try:
        for _ in range(8):
            k=u32(d)&0x1f
            if k in (16,17,18,3,0): parts.append(cstr(d+8+i32(d+8)))
            if k==0: break
            p=i32(d+4)
            if not p: break
            pa=d+4+p
            if pa&1: pa=0x180000000+(u64(pa&~1)&0x3ffffffff)
            d=pa
    except Exception: parts.append('?')
    return '.'.join(reversed(parts[:-1])) if len(parts)>1 else '.'.join(parts)
def mangled(v):
    o=v2o(v); out=''
    while b[o]:
        c=b[o]
        if 1<=c<=0x17:
            tgt=(v+(o-v2o(v))+1)+struct.unpack_from('<i',b,o+1)[0]
            if c==2:
                try: tgt=0x180000000+(u64(tgt)&0x3ffffffff)
                except Exception: tgt=None
            try: out+='{'+(ctxname(tgt) if tgt else 'ext')+'}'
            except Exception: out+='{?}'
            o+=5
        elif 0x18<=c<=0x1f: o+=9; out+='{abs}'
        else: out+=chr(c); o+=1
    return out
a,s=secs['__swift5_fieldmd']; p=a; pat=re.compile(sys.argv[2])
while p<a+s:
    tn=mangled(p+i32(p)) if i32(p) else '?'
    kind=u16(p+8); rs=u16(p+10); n=u32(p+12)
    if pat.search(tn):
        print('##',tn,'kind',kind)
        for i in range(n):
            r=p+16+i*rs
            t=mangled(r+4+i32(r+4)) if i32(r+4) else '-'
            print('   ',cstr(r+8+i32(r+8)),':',t)
    p+=16+n*rs
