#!/usr/bin/env bash
# scripts/show_build_commands.sh
# Show recommended CMake commands for common hosts and targets.
set -euo pipefail

print() { printf '%s\n' "$*"; }

print "Project: cpp-platform-lab"
print "Detected host: $(uname -s) $(uname -m)"
print

print "Common: configure + build (Ninja, RelWithDebInfo)"
print "  cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo"
print "  cmake --build build -j"
print

print "Run tests (RPATH verification runs first):"
print "  ctest --test-dir build --output-on-failure"
print

print "Shared vs static libraries:"
print "  Shared: cmake -S . -B build-shared -DBUILD_SHARED_LIBS=ON"
print "  Static: cmake -S . -B build-static -DBUILD_SHARED_LIBS=OFF"
print

if [[ "$(uname -s)" == "Linux" ]]; then
  print "Linux (native x64):"
  print "  cmake -S . -B build -G Ninja -DTARGET_ARCH=x64"
  print "Cross-compile aarch64 (example using provided toolchain file):"
  print "  cmake -S . -B build-aarch64 -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/aarch64-linux-gnu.cmake -DTARGET_ARCH=arm64"
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  print "macOS (Xcode generator example):"
  print "  cmake -S . -B build-mac -G Xcode -DTARGET_ARCH=arm64"
  print "iOS device (Xcode + toolchain):"
  print "  cmake -S . -B build-ios -G Xcode -DCMAKE_TOOLCHAIN_FILE=cmake/Toolchain-iOS.cmake -DCMAKE_OSX_SYSROOT=iphoneos -DTARGET_ARCH=arm64"
fi

if [[ "$(uname -s)" == "MINGW"* || "$(uname -s)" == "CYGWIN"* || "$(uname -s)" == "MSYS"* || "$(uname -s)" =~ "NT" ]]; then
  print "Windows (Visual Studio):"
  print "  cmake -S . -B build-vs-x64 -G \"Visual Studio 17 2022\" -A x64"
  print "  cmake --build build-vs-x64 --config Release"
fi

print
print "Android (NDK) example (requires ANDROID_NDK path):"
print "  cmake -S . -B build-android -G Ninja -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/android-ndk.cmake -DANDROID_NDK=/path/to/ndk -DANDROID_ABI=arm64-v8a -DTARGET_ARCH=arm64"
print
print "To see these lines inside CMake (configure-time) run:"
print "  cmake -P cmake/helpers/show_invocations.cmake"