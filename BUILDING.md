# Building ReactPhysics3D Libraries

The Dart bindings require a precompiled static library (`libreactphysics3d.a`) for each target platform. This covers building the core ReactPhysics3D C++ library from source.

## Prerequisites

- CMake 3.10+
- A C++17 compiler for your target platform

The ReactPhysics3D source is included at `native/include/reactphysics3d/`. The C API wrapper lives at `native/src/rp3d_c_api.cpp`.

## Regenerating the Dart bindings

Both binding sets are generated from `native/include/c_api/rp3d_c_api.h`:

```bash
dart run ffigen --config ffigen/native.yaml     # lib/src/bindings/src/rp3d_ffi.g.dart
dart run ffigen_js --config ffigen/web.yaml     # lib/src/bindings/src/rp3d_js_interop.g.dart
```

`ffigen_js` additionally needs libclang on the machine (same requirement as `ffigen`).

The web bindings are checked in CI by compiling `tool/web_bindings_smoke.dart`
with `dart compile js`, because they only load through the conditional export
in `lib/src/bindings/src/bindings.dart` and are excluded from `dart analyze`.

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

Requires [Emscripten](https://emscripten.org/) (the artifacts are built with
emsdk 6.0.4; use the same or newer).

The one-command build clones the engine at the pinned tag, verifies it matches
the vendored headers, builds the engine and C API wrapper static libraries and
links the standalone module:

```bash
scripts/build_web_artifacts.sh        # needs EMSDK=<path> or emcmake on PATH
```

It also verifies the result: the ~143 `rp3d_*` entry points must be present in
the wrapper archive and in the linked module, and the module must actually
simulate under node (a body dropped from y=10 must fall).

Equivalently, by hand (after putting an Emscripten `libreactphysics3d.a` into
`native/web/`, which is what the script does):

```bash
emcmake cmake -B build-wasm -S native/web
cmake --build build-wasm
```

Outputs:

- `native/web/libreactphysics3d.a` — engine static library (wasm32); this is
  the file `native/web/reactphysics3d_dart.cmake` imports, i.e. what a
  downstream wasm link (thermion's `EXTERNAL_PROJECTS` hook) needs.
- `build-wasm/libreactphysics3d_dart.a` — C API wrapper static library.
- `build-wasm/build/out/reactphysics3d_dart.js` and `reactphysics3d_dart.wasm`
  — the standalone modularized module (`EXPORT_NAME=reactphysics3d_dart`) the
  generated JS interop bindings load. Built with `-sUSE_PTHREADS`, so the page
  must be cross-origin isolated (COOP/COEP headers).

## Release artifacts

[`.github/workflows/build-artifacts.yml`](.github/workflows/build-artifacts.yml)
builds the prebuilt libraries on every pull request (verification only) and
publishes them to a GitHub Release when a `v*` tag is pushed:

```bash
git tag v0.1.0 && git push origin v0.1.0
```

| Artifact (`reactphysics3d_dart-<version>-<platform>.zip`) | Contents |
|---|---|
| `web-emscripten` | `libreactphysics3d.a` (engine, wasm32) + `libreactphysics3d_dart.a` (C API wrapper), built with `-pthread -matomics -mbulk-memory`. Extract into `native/web/` next to `reactphysics3d_dart.cmake`. Link with the same or newer Emscripten. |
| `web-module` | The standalone `reactphysics3d_dart.js`/`.wasm` module, for loading the library directly on a page instead of linking it into another wasm. |
| `linux-x86_64`, `linux-aarch64`, `macos-arm64`, `macos-x86_64`, `windows-x64` | `libreactphysics3d.a` (`reactphysics3d.lib` on Windows) — the same libraries committed under `native/<os>/<arch>/`. |

Each zip contains a `README.txt` manifest with the exact engine tag and
toolchain versions. The engine tag (`RP3D_ENGINE_REF`, currently `v0.10.2`) is
pinned in the workflow, and `scripts/fetch_engine.sh` fails the build if the
engine headers at that tag differ from `native/include/reactphysics3d/` — the
Dart bindings are generated from the vendored headers, so they must stay in
sync.

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
