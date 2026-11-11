#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <mach-o/dyld.h>
// gotsym <dylib> <unslid image base hex> <addr hex>... : resolves pointers stored at unslid shared-cache addresses
// "c:<addr>" resolves a code/data address itself (e.g. a bl target); "d:<addr>" prints the double/float stored there
int main(int argc, char **argv) {
    void *h = dlopen(argv[1], RTLD_NOW);
    if (!h) { printf("dlopen failed %s\n", dlerror()); return 1; }
    intptr_t slide = 0; int found = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *n = _dyld_get_image_name(i);
        if (strstr(n, strrchr(argv[1], '/') + 1)) { slide = (intptr_t)_dyld_get_image_header(i) - (intptr_t)strtoull(argv[2], 0, 16); found = 1; break; }
    }
    if (!found) { printf("image not found\n"); return 1; }
    for (int i = 3; i < argc; i++) {
        char *a = argv[i]; Dl_info di;
        if (a[0] == 'c') { uint64_t v = strtoull(a + 2, 0, 16) + slide; if (dladdr((void *)v, &di) && di.dli_sname) printf("%s -> %s + %ld (%s)\n", a, di.dli_sname, (long)(v - (uint64_t)di.dli_saddr), strrchr(di.dli_fname, '/')); else printf("%s -> ?\n", a); continue; }
        if (a[0] == 't') {   // auth stub: adrp x17 ; add x17 ; ldr x16,[x17] ; braa
            uint64_t un = strtoull(a + 2, 0, 16); uint32_t *p = (uint32_t *)(un + slide);
            uint32_t i0 = p[0], i1 = p[1];
            int64_t immhi = (i0 >> 5) & 0x7ffff, immlo = (i0 >> 29) & 3; int64_t imm = ((immhi << 2) | immlo) << 12; if (imm & (1LL << 32)) imm -= (1LL << 33);
            uint64_t page = ((uint64_t)p & ~0xfffULL) + imm; uint64_t off = (i1 >> 10) & 0xfff;
            uint64_t slot = page + off; uint64_t v = *(uint64_t *)slot & 0x00007fffffffffffULL;
            if (dladdr((void *)v, &di) && di.dli_sname) printf("%s -> %s + %ld (%s)\n", a, di.dli_sname, (long)(v - (uint64_t)di.dli_saddr), strrchr(di.dli_fname, '/')); else printf("%s -> slot %llx val %llx ? (insn %08x %08x)\n", a, (unsigned long long)(slot - slide), (unsigned long long)v, i0, i1);
            continue; }
        if (a[0] == 's') { uint64_t v = strtoull(a + 2, 0, 16) + slide; printf("%s -> \"%.120s\"\n", a, (char *)v); continue; }
        if (a[0] == 'd') { uint64_t v = strtoull(a + 2, 0, 16) + slide; printf("%s -> double %.9g float %.9g u64 0x%llx\n", a, *(double *)v, *(float *)v, *(unsigned long long *)v); continue; }
        uint64_t p = strtoull(a, 0, 16) + slide;
        uint64_t v = *(uint64_t *)p & 0x00007fffffffffffULL;
        if (dladdr((void *)v, &di) && di.dli_sname) printf("%s -> %s + %ld (%s)\n", a, di.dli_sname, (long)(v - (uint64_t)di.dli_saddr), strrchr(di.dli_fname, '/'));
        else printf("%s -> 0x%llx ?\n", a, (unsigned long long)v);
    }
    return 0;
}
