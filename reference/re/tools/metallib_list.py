import struct, sys, mmap
P='air.metallib'  # first (air64) slice of QuartzCore.framework/Resources/default.metallib: dd skip=0x1b0 count=0x2a735c
f=open(P,'rb'); m=mmap.mmap(f.fileno(),0,access=mmap.ACCESS_READ)
assert m[:4]==b'MTLB'
fsz,flo,fls,pmo,pms,vmo,vms,bco,bcs=struct.unpack_from('<9Q',m,0x10)
n=struct.unpack_from('<I',m,flo)[0]
off=flo+4
funcs=[]
for i in range(n):
    esz=struct.unpack_from('<I',m,off)[0]
    p=off+4; e={}
    while p<off+esz:
        tag=m[p:p+4]; p+=4
        if tag==b'ENDT': break
        sz=struct.unpack_from('<H',m,p)[0]; p+=2
        d=m[p:p+sz]; p+=sz
        if tag==b'NAME': e['name']=d.rstrip(b'\0').decode()
        elif tag==b'TYPE': e['type']=d[0]
        elif tag==b'MDSZ': e['size']=struct.unpack('<Q',d)[0]
        elif tag==b'OFFT': e['pub'],e['priv'],e['bc']=struct.unpack('<3Q',d)
    funcs.append(e); off+=esz
if __name__=='__main__':
    pat=sys.argv[1] if len(sys.argv)>1 else ''
    for e in funcs:
        if pat in e.get('name',''): print(e)
    print(len(funcs),hex(bco),bcs)
    if len(sys.argv)>2:
        for e in funcs:
            if e['name']==sys.argv[2]:
                open(sys.argv[2]+'.bc','wb').write(m[bco+e['bc']:bco+e['bc']+e['size']])
