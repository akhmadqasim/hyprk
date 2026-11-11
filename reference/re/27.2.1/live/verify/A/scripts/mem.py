import ctypes, struct, sys
libc=ctypes.CDLL(None)
libc._dyld_image_count.restype=ctypes.c_uint32
libc._dyld_get_image_vmaddr_slide.restype=ctypes.c_long
libc._dyld_get_image_name.restype=ctypes.c_char_p
libc._dyld_get_image_header.restype=ctypes.c_void_p
def slide():
    for i in range(libc._dyld_image_count()):
        n=libc._dyld_get_image_name(i).decode()
        if n.startswith('/usr/lib/system/') or n=='/usr/lib/libSystem.B.dylib':
            return libc._dyld_get_image_vmaddr_slide(i)
SL=slide()
def rd(a,n): return ctypes.string_at(a+SL,n)
def u32(a): return struct.unpack('<I',rd(a,4))[0]
def f64(a): return struct.unpack('<d',rd(a,8))[0]
def stub(a):
    i0,i1,i2=u32(a),u32(a+4),u32(a+8)
    if (i0&0x9f000000)==0x90000000:
        immlo=(i0>>29)&3; immhi=(i0>>5)&0x7ffff; imm=(immhi<<2)|immlo
        if imm&(1<<20): imm-=1<<21
        page=(a&~0xfff)+(imm<<12)
        if (i1&0xffc00000)==0x91000000:
            return page+((i1>>10)&0xfff), 'adrp/add', hex(i2)
        if (i1&0xffc00000)==0xf9400000:
            p=page+((i1>>10)&0xfff)*8
            v=struct.unpack('<Q',rd(p,8))[0]
            return (v&0x7fffffffffff)-SL if v else 0, 'adrp/ldr@%x'%p, hex(i2)
    return None, hex(i0), hex(i1)
def sym(lib,name):
    h=ctypes.CDLL(lib); 
    try: return ctypes.cast(getattr(h,name),ctypes.c_void_p).value - SL
    except Exception as e: return None
if __name__=='__main__':
    print('slide',hex(SL))
