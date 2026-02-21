# cpp-platform-lab — Usage & build matrix

This file documents common workflows to configure, build, test and package the project across platforms and architectures.

Prerequisites
- CMake >= 3.18
- A recent compiler (MSVC/Clang/GCC) appropriate to your target.
- Android: Android NDK (set `ANDROID_NDK` or pass `-DANDROID_NDK=...`).
- Optional: `rg` (ripgrep) for fast searching.

Quick commands (create a fresh build directory per config)
- Configure + build (Ninja, native):
  - `cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo`
  - `cmake --build build -j`

- Run tests (RPATH verification runs first):
  - `ctest --test-dir build --output-on-failure`

- Manual RPATH verification:
  - `cmake --build build --target verify_rpath`

- Build shared vs static:
  - Shared (default): `cmake -S . -B build-shared -DBUILD_SHARED_LIBS=ON`
  - Static: `cmake -S . -B build-static -DBUILD_SHARED_LIBS=OFF`

Using CMake Presets
- List available presets:
  - `cmake --list-presets`
- Configure using a preset (example):
  - `cmake --preset ninja-linux-x64`
  - `cmake --build --preset ninja-linux-x64 -- -j`

Platform examples

- Windows (Visual Studio 2022)
  - Configure (generator platform chosen via `-A`):
    - `cmake -S . -B build-vs-x64 -G "Visual Studio 17 2022" -A x64`
    - `cmake --build build-vs-x64 --config Release`
  - Open in Visual Studio: __File > Open > Folder__ and select the repo root.

- Linux (native x64)
  - `cmake -S . -B build -G Ninja -DTARGET_ARCH=x64`
  - `cmake --build build -j`
  - `ctest --test-dir build --output-on-failure`

- Cross-compile Linux aarch64 (example)
  - `cmake -S . -B build-aarch64 -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/aarch64-linux-gnu.cmake -DTARGET_ARCH=arm64`
  - `cmake --build build-aarch64 -j`
  - Note: runtime execution requires device/emulator — RPATH checks run on the built ELF metadata.

- macOS / iOS
  - macOS (Xcode or Ninja):
    - `cmake -S . -B build-mac -G Xcode -DTARGET_ARCH=arm64`
  - iOS device (Xcode generator + toolchain):
    - `cmake -S . -B build-ios -G Xcode -DCMAKE_TOOLCHAIN_FILE=cmake/Toolchain-iOS.cmake -DCMAKE_OSX_SYSROOT=iphoneos -DTARGET_ARCH=arm64`

- Android (NDK)
  - `cmake -S . -B build-android -G Ninja -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/android-ndk.cmake -DANDROID_NDK=/path/to/ndk -DANDROID_ABI=arm64-v8a -DTARGET_ARCH=arm64`
  - `cmake --build build-android -- -j`

Variables of interest
- `TARGET_ARCH` — `x86`, `x64`, `armv7`, `arm64` (empty = native)
- `ALLOW_ARM32` — OFF by default; set `-DALLOW_ARM32=ON` to enable `armv7`
- `BUILD_SHARED_LIBS` — ON (shared) / OFF (static)
- `ENABLE_PACKAGING` — ON to enable CPack packaging targets

Helpers included
- `scripts/show_build_commands.sh` — prints recommended cmake commands for your host
- `cmake/helpers/show_invocations.cmake` — CMake script that prints recommended invocation lines (run with `cmake -P cmake/helpers/show_invocations.cmake`)

Notes & tips
- Always use a fresh build directory per (generator, arch, config) combination.
- Use `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` for editor tooling (clangd).
- If tests fail due to loader issues, run the `verify_rpath` target or inspect binary RPATHs with `readelf -d` (Linux) / `otool -l` (macOS).

Adding new apps (extendible workflow)
- Create your executable source under a subfolder (e.g. `apps/my_app/main.cpp`) or in `examples/`.
- Add the executable target in the corresponding CMake file, then call `register_app()`.

What `register_app()` does
- Configures runtime output directories for the target (build/bin).
- Sets platform-appropriate RPATH for the executable so it can find shared libs in the same folder.
- Adds an install rule to put the executable into `bin` on `cmake --install`.
- Records the target in a global REGISTERED_APPS list so `tests/CMakeLists.txt` will:
  - add a per-app RPATH verification test, and
  - add a per-app functional test which will use the optional RUN_REGEX as the pass expression.

This lets you add more apps without changing the tests — just create the target and call `register_app()`.