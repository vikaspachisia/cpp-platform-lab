# cmake/toolchains/android-ndk.cmake
# Minimal wrapper that forwards to the Android NDK CMake toolchain file.
# Usage:
#  cmake -S . -B build-android -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/android-ndk.cmake -DANDROID_NDK=/path/to/ndk
if(NOT DEFINED ANDROID_NDK)
  set(ANDROID_NDK $ENV{ANDROID_NDK} CACHE PATH "Path to Android NDK (or set ANDROID_NDK env var)" FORCE)
endif()

if(NOT ANDROID_NDK OR NOT EXISTS "${ANDROID_NDK}")
  message(FATAL_ERROR "ANDROID_NDK not set or path does not exist. Set -DANDROID_NDK=/path/to/ndk or set ANDROID_NDK env var.")
endif()

set(TOOLCHAIN_PATH "${ANDROID_NDK}/build/cmake/android.toolchain.cmake")
if(NOT EXISTS "${TOOLCHAIN_PATH}")
  message(FATAL_ERROR "Android NDK toolchain not found at ${TOOLCHAIN_PATH}")
endif()

# Forward common NDK variables if user provided them
if(DEFINED ANDROID_ABI)
  set(ANDROID_ABI ${ANDROID_ABI} CACHE STRING "Android ABI" FORCE)
endif()
if(DEFINED ANDROID_PLATFORM)
  set(ANDROID_PLATFORM ${ANDROID_PLATFORM} CACHE STRING "Android API level" FORCE)
endif()

include("${TOOLCHAIN_PATH}")