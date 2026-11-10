#include <dlfcn.h>
#include <stdio.h>
typedef int (*fn_t)(const char*, const char*, void (^)(unsigned, unsigned));
int main(int c, char** v){
  void* h=dlopen("/usr/lib/dsc_extractor.bundle",RTLD_NOW); if(!h){puts(dlerror());return 1;}
  fn_t f=(fn_t)dlsym(h,"dyld_shared_cache_extract_dylibs_progress"); if(!f){puts("nosym");return 1;}
  return f(v[1],v[2],^(unsigned a,unsigned b){});
}
