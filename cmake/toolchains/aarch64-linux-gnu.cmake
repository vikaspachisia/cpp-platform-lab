# cmake/toolchains/aarch64-linux-gnu.cmake
# Example Linux cross toolchain file for aarch64 (aarch64-linux-gnu).
# Install or provide a matching cross-compiler toolchain (gcc/clang) and adjust paths.
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Path to the cross-compilers (adjust as needed)
# Example: /usr/bin/aarch64-linux-gnu-gcc
if(NOT DEFINED CMAKE_C_COMPILER)
  set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc CACHE STRING "C compiler" FORCE)
endif()
if(NOT DEFINED CMAKE_CXX_COMPILER)
  set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++ CACHE STRING "C++ compiler" FORCE)
endif()

# Optional sysroot hint (uncomment and set if you have a sysroot)
# set(CMAKE_SYSROOT /path/to/aarch64/sysroot)

# Adjust search behavior
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)