# cmake/arch.cmake
# Architecture selection and mapping helper.
# Use -DTARGET_ARCH=<x86|x64|armv7|arm64> and -DALLOW_ARM32=ON to enable armv7.

option(ALLOW_ARM32 "Allow building for 32-bit ARM (armv7 / armeabi-v7a) targets" OFF)

set(_all_archs x86 x64 armv7 arm64)
if(NOT ALLOW_ARM32)
  list(REMOVE_ITEM _all_archs armv7)
endif()

set(SUPPORTED_ARCHS "${_all_archs}" CACHE STRING "List of supported architectures")
set_property(CACHE SUPPORTED_ARCHS PROPERTY STRINGS ${_all_archs})

set(TARGET_ARCH "" CACHE STRING "Target architecture to build for. One of: ${_all_archs}. Empty means native host arch.")
set_property(CACHE TARGET_ARCH PROPERTY STRINGS ${_all_archs})

if(TARGET_ARCH)
  list(FIND _all_archs "${TARGET_ARCH}" _idx)
  if(_idx EQUAL -1)
    message(FATAL_ERROR "Requested TARGET_ARCH='${TARGET_ARCH}' is not in supported list: ${_all_archs}. Set ALLOW_ARM32=ON to enable armv7 if needed.")
  endif()

  message(STATUS "Configuring for TARGET_ARCH=${TARGET_ARCH}")

  # macOS / iOS mapping
  if(APPLE)
    if(TARGET_ARCH STREQUAL "x86" OR TARGET_ARCH STREQUAL "x64")
      set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "CMake OSX architectures" FORCE)
    elseif(TARGET_ARCH STREQUAL "arm64")
      set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "CMake OSX architectures" FORCE)
    elseif(TARGET_ARCH STREQUAL "armv7")
      set(CMAKE_OSX_ARCHITECTURES "armv7" CACHE STRING "CMake OSX architectures" FORCE)
    endif()
    message(STATUS "Set CMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}")
  endif()

  # Android mapping (NDK)
  if(ANDROID)
    if(TARGET_ARCH STREQUAL "x86")
      set(ANDROID_ABI "x86" CACHE STRING "Android ABI" FORCE)
    elseif(TARGET_ARCH STREQUAL "x64")
      set(ANDROID_ABI "x86_64" CACHE STRING "Android ABI" FORCE)
    elseif(TARGET_ARCH STREQUAL "armv7")
      set(ANDROID_ABI "armeabi-v7a" CACHE STRING "Android ABI" FORCE)
    elseif(TARGET_ARCH STREQUAL "arm64")
      set(ANDROID_ABI "arm64-v8a" CACHE STRING "Android ABI" FORCE)
    endif()
    message(STATUS "Set ANDROID_ABI=${ANDROID_ABI}")
  endif()

  # Generic processor hint for some toolchains
  if(NOT DEFINED CMAKE_SYSTEM_PROCESSOR OR CMAKE_SYSTEM_PROCESSOR STREQUAL "")
    if(TARGET_ARCH STREQUAL "x86")
      set(CMAKE_SYSTEM_PROCESSOR "i386" CACHE STRING "Hint for system processor" FORCE)
    elseif(TARGET_ARCH STREQUAL "x64")
      set(CMAKE_SYSTEM_PROCESSOR "x86_64" CACHE STRING "Hint for system processor" FORCE)
    elseif(TARGET_ARCH STREQUAL "armv7")
      set(CMAKE_SYSTEM_PROCESSOR "armv7" CACHE STRING "Hint for system processor" FORCE)
    elseif(TARGET_ARCH STREQUAL "arm64")
      set(CMAKE_SYSTEM_PROCESSOR "aarch64" CACHE STRING "Hint for system processor" FORCE)
    endif()
    message(STATUS "CMAKE_SYSTEM_PROCESSOR set to ${CMAKE_SYSTEM_PROCESSOR}")
  endif()

  # Advice for Visual Studio users (generator platform must be selected at configure time)
  if(CMAKE_GENERATOR MATCHES "Visual Studio" OR CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    message(STATUS "When using Visual Studio re-run CMake with the appropriate -A. Recommended examples:")
    if(TARGET_ARCH STREQUAL "x86")
      message(STATUS "  cmake -G \"Visual Studio 17 2022\" -A Win32 -S . -B build-windows-x86")
    elseif(TARGET_ARCH STREQUAL "x64")
      message(STATUS "  cmake -G \"Visual Studio 17 2022\" -A x64 -S . -B build-windows-x64")
    elseif(TARGET_ARCH STREQUAL "arm64")
      message(STATUS "  cmake -G \"Visual Studio 17 2022\" -A ARM64 -S . -B build-windows-arm64")
    endif()
  else()
    message(STATUS "If cross-compiling provide an appropriate toolchain file via -DCMAKE_TOOLCHAIN_FILE=...")
  endif()

else()
  message(STATUS "No TARGET_ARCH requested; building for native/default architecture")
endif()