# List the functions of QuartzCore default.metallib (slice 0, MTLB) and save an index (name, type, size, offset).
import struct,sys,mmap,pickle
M='/System/Library/Frameworks/QuartzCore.framework/Versions/A/Resources/default.metallib'
f=open(M,'rb'); mm=mmap.mmap(f.fileno(),0,prot=mmap.PROT_READ)
magic,nf=struct.unpack_from('>II',mm,0)
allout={}
for i in range(nf):
    ct,cs,off,size,al=struct.unpack_from('>iiIII',mm,8+20*i)
    base=off
    if mm[base:base+4]!=b"MTLB": print("slice",i,hex(ct&0xffffffff),cs,off,size,mm[base:base+4]); continue
    hdr=struct.unpack_from('<4sHHHHHHQ8Q',mm,base)
    fl_off,fl_size,pub_off,pub_size,priv_off,priv_size,bc_off,bc_size=hdr[8:16]
    n=struct.unpack_from('<I',mm,base+fl_off)[0]
    print('slice',i,hex(ct&0xffffffff),cs,'off',off,'size',size,mm[base:base+4],'nfunc',n)
    o=base+fl_off+4; out=[]
    for k in range(n):
        sz=struct.unpack_from('<I',mm,o)[0]; e=o+sz; p=o+4; d={}
        while p<e:
            tag=mm[p:p+4]; p+=4
            if tag==b'ENDT': break
            ln=struct.unpack_from('<H',mm,p)[0]; p+=2; d[tag.decode()]=mm[p:p+ln]; p+=ln
        o=e
        name=d['NAME'].rstrip(b'\0').decode(); md=struct.unpack('<Q',d['MDSZ'])[0]; offs=struct.unpack('<3Q',d['OFFT'])
        out.append((name,d['TYPE'][0],md,base+bc_off+offs[2]))
    allout[i]=out
pickle.dump(allout,open('mtlb.idx','wb'))
for x in allout[0]:
    if 'glass' in x[0]: print(x)
