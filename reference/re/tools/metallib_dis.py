import sys, struct
import llvmlite.binding as llvm
from metallib_list import funcs, m, bco
name=sys.argv[1]
for e in funcs:
    if e['name']==name:
        b=bytes(m[bco+e['bc']:bco+e['bc']+e['size']])
        if b[:4]==b'\xde\xc0\x17\x0b':
            o,s=struct.unpack_from('<II',b,8); b=b[o:o+s]
        mod=llvm.parse_bitcode(b)
        open(name+'.ll','w').write(str(mod))
        print(name,len(str(mod)))
