# cmake/feature_detection.cmake
# Centralized feature checks: thread_local, dlopen/LoadLibrary, Threads.
include(CheckCXXSourceCompiles)
include(CheckSymbolExists)

# Check for C++ thread_local support
check_cxx_source_compiles("
  thread_local int tls_test = 0;
  int main() { (void)tls_test; return 0; }
" HAVE_THREAD_LOCAL)
if(HAVE_THREAD_LOCAL)
  message(STATUS "C++ thread_local supported")
  add_compile_definitions(HAVE_THREAD_LOCAL=1)
else()
  message(STATUS "C++ thread_local NOT supported")
endif()

# Check for dlopen on POSIX (dlfcn.h)
if(UNIX AND NOT APPLE)
  check_symbol_exists(dlopen "dlfcn.h" HAVE_DLOPEN)
elseif(APPLE)
  # On macOS / iOS dlfcn.h exists similarly
  check_symbol_exists(dlopen "dlfcn.h" HAVE_DLOPEN)
elseif(WIN32)
  # Windows: prefer Unicode / extended APIs; fall back to ANSI
  check_symbol_exists(LoadLibraryW "windows.h" HAVE_LOADLIBRARY_W)
  check_symbol_exists(LoadLibraryExW "windows.h" HAVE_LOADLIBRARYEX_W)

  if(HAVE_LOADLIBRARY_W)
    set(HAVE_LOADLIBRARY 1 CACHE INTERNAL "Have LoadLibrary API")
    message(STATUS "LoadLibraryW detected")
    add_compile_definitions(HAVE_LOADLIBRARY=1 USE_LOADLIBRARY_W=1)
  elseif(HAVE_LOADLIBRARYEX_W)
    set(HAVE_LOADLIBRARY 1 CACHE INTERNAL "Have LoadLibraryExW API")
    message(STATUS "LoadLibraryExW detected")
    add_compile_definitions(HAVE_LOADLIBRARY=1 USE_LOADLIBRARYEX_W=1)
  else()
    check_symbol_exists(LoadLibraryA "windows.h" HAVE_LOADLIBRARY_A)
    if(HAVE_LOADLIBRARY_A)
      set(HAVE_LOADLIBRARY 1 CACHE INTERNAL "Have LoadLibraryA API")
      message(STATUS "LoadLibraryA detected (ANSI)")
      add_compile_definitions(HAVE_LOADLIBRARY=1 USE_LOADLIBRARY_A=1)
    else()
      message(STATUS "No LoadLibrary symbol detected")
    endif()
  endif()
endif()

if(HAVE_DLOPEN)
  message(STATUS "dlopen detected")
  add_compile_definitions(HAVE_DLOPEN=1)
endif()
if(HAVE_LOADLIBRARY)
  message(STATUS "LoadLibrary API detected")
  add_compile_definitions(HAVE_LOADLIBRARY=1)
endif()

# Threads detection
find_package(Threads REQUIRED)
if(Threads_FOUND)
  message(STATUS "Threads found: ${CMAKE_THREAD_LIBS_INIT}")
  add_compile_definitions(HAVE_THREADS=1)
endif()