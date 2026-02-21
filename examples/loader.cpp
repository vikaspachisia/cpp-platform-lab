#include "platform.h"
#include <iostream>

#if defined(_WIN32)
  #include <windows.h>
  using lib_handle_t = HMODULE;
#else
  #include <dlfcn.h>
  using lib_handle_t = void*;
#endif

int main()
{
    std::cout << "loader_app: runtime loading library\n";
    lib_handle_t h = nullptr;
#if defined(_WIN32)
    h = LoadLibraryA("platformlib.dll");
    if(!h) {
        std::cerr << "loader_app: failed to LoadLibraryA\n";
        return 2;
    }
    auto fn = (int(*)())GetProcAddress(h, "platform_lib_run");
    if(!fn) {
        std::cerr << "loader_app: failed to GetProcAddress\n";
        FreeLibrary(h);
        return 3;
    }
    int rc = fn();
    FreeLibrary(h);
    return rc;
#else
    // Try .so/.dylib names
    const char* candidates[] = { "libplatformlib.so", "libplatformlib.dylib", "platformlib.so", nullptr };
    for(const char** p = candidates; *p; ++p) {
        h = dlopen(*p, RTLD_NOW);
        if(h) break;
    }
    if(!h) {
        std::cerr << "loader_app: failed to dlopen library\n";
        return 2;
    }
    using fn_t = int(*)();
    auto sym = (fn_t)dlsym(h, "platform_lib_run");
    if(!sym) {
        std::cerr << "loader_app: failed to find symbol platform_lib_run\n";
        dlclose(h);
        return 3;
    }
    int rc = sym();
    dlclose(h);
    return rc;
#endif
}