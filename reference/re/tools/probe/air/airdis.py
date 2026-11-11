# airdis.py <function>...: AIR bitcode of the named metallib functions -> LLVM IR (.ll) with llvmlite (pip install llvmlite). Run mtlb.py first.
import pickle,sys,mmap,struct
import llvmlite.binding as b
M='/System/Library/Frameworks/QuartzCore.framework/Versions/A/Resources/default.metallib'
f=open(M,'rb'); mm=mmap.mmap(f.fileno(),0,prot=mmap.PROT_READ)
idx=pickle.load(open('mtlb.idx','rb'))[0]
for name in sys.argv[1:]:
    e=[x for x in idx if x[0]==name][0]
    bc=bytes(mm[e[3]:e[3]+e[2]])
    print(name,bc[:4].hex(),len(bc))
    if bc[:4]==bytes.fromhex('dec0170b'):
        _,ver,off,size,cpu=struct.unpack_from('<5I',bc,0); bc=bc[off:off+size]
    try:
        m=b.parse_bitcode(bc); open(name+'.ll','w').write(str(m)); print('ok',len(str(m)))
    except Exception as ex: print('ERR',str(ex)[:500]); open(name+'.bc','wb').write(bc)
