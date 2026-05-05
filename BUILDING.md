# Building ReactPhysics3D Libraries

The Dart bindings require a precompiled static library (`libreactphysics3d.a`) for each target platform. This covers building the core ReactPhysics3D C++ library from source.

## Prerequisites

- CMake 3.10+
- A C++17 compiler for your target platform

The ReactPhysics3D source is included at `native/include/reactphysics3d/`. The C API wrapper lives at `native/src/rp3d_c_api.cpp`.

## macOS (arm64)

```bash
cmake -B build-macos
cmake --build build-macos
```

Output: `build-macos/libreactphysics3d.a`

## iOS (arm64)

Requires Xcode.

```bash
cmake -B build-ios -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0
cmake --build build-ios
```

Output: `build-ios/libreactphysics3d.a`

For the iOS simulator, add `-DCMAKE_OSX_SYSROOT=iphonesimulator`.

## Android (arm64-v8a)

Requires the [Android NDK](https://developer.android.com/ndk).

```bash
cmake -B build-android \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-21
cmake --build build-android
```

Set `ANDROID_NDK` to your NDK path (e.g. `~/Library/Android/sdk/ndk/28.2.13676358`).

Other ABIs: replace `arm64-v8a` with `armeabi-v7a`, `x86`, or `x86_64` and repeat.

## Linux (arm64)

On an arm64 Linux machine, or via Docker on Apple Silicon:

```bash
cmake -B build-linux
cmake --build build-linux
```

### Cross-compiling from macOS (arm64)

```bash
docker run --rm -v "$(pwd)":/src -w /src ubuntu:22.04 \
  bash -c "apt-get update -qq && apt-get install -y -qq g++ cmake &&
           cmake -B build-linux && cmake --build build-linux"
```

This produces an arm64 Linux library (matches the Docker host architecture).

### Linux (x86_64)

On an x86_64 Linux machine:

```bash
cmake -B build-linux
cmake --build build-linux
```

Cross-compiling x86_64 from macOS requires Docker with Rosetta emulation enabled (Docker Desktop > General > "Use Rosetta for x86_64/amd64 emulation"). Without it, QEMU emulation hits file descriptor limits:

```bash
docker run --rm --platform linux/amd64 -v "$(pwd)":/src -w /src ubuntu:22.04 \
  bash -c "apt-get update -qq && apt-get install -y -qq g++ cmake &&
           cmake -B build-linux-x86_64 && cmake --build build-linux-x86_64"
```

## Windows

With Visual Studio 2022:

```bash
cmake -B build-windows -G "Visual Studio 17 2022"
cmake --build build-windows --config Release
```

Output: `build-windows/Release/reactphysics3d.lib`

## WebAssembly

Requires [Emscripten](https://emscripten.org/).

```bash
emcmake cmake -B build-wasm -S native/web
cmake --build build-wasm
```

Output: `build-wasm/build/out/reactphysics3d_dart.js` and `reactphysics3d_dart.wasm`

## Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `RP3D_DOUBLE_PRECISION_ENABLED` | OFF | Use double precision floating point |
| `RP3D_PROFILING_ENABLED` | OFF | Enable performance profiling |
| `RP3D_COMPILE_TESTS` | OFF | Build unit tests |

Example with double precision:

```bash
cmake -B build -DRP3D_DOUBLE_PRECISION_ENABLED=ON
cmake --build build
```
