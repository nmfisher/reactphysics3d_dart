# Building and validating

The repository contains ReactPhysics3D **0.10.2 headers**, its C bridge, and
precompiled native archives. It does not contain the upstream C++ implementation
or a root CMake project. Rebuilding the core requires a matching upstream source
tree. Keep its precision/build configuration consistent with the bundled headers;
do not enable double precision with the current wrapper build.

## Native

With a compatible Dart SDK (`dart:ffi` typed-data address support and native build
hooks), run:

```sh
dart pub get
dart run example/quick_start.dart
dart test
```

The build hook compiles `native/src/rp3d_c_api.cpp` and
`native/src/dart_sendport_listener.cpp`, using the running Dart SDK's API headers
for port notifications. It links the appropriate archive:

| Target | Archive |
| --- | --- |
| macOS arm64 | `native/macos/libreactphysics3d.a` |
| Linux arm64 | `native/linux/arm64/libreactphysics3d.a` |
| Linux x86_64 | `native/linux/x86_64/libreactphysics3d.a` |

The macOS archive was built for macOS 15; rebuild it for an older deployment target
if required. iOS, Android, Windows, and macOS x86_64 require compatible archives and
additional library-path/toolchain configuration in `hook/build.dart`; this
repository does not currently provide a complete build setup for those targets.

To rebuild a core archive from a matching upstream source checkout:

```sh
cmake -S /path/to/reactphysics3d -B /tmp/rp3d-core \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DRP3D_DOUBLE_PRECISION_ENABLED=OFF -DRP3D_COMPILE_TESTS=OFF
cmake --build /tmp/rp3d-core --parallel
```

Copy the resulting `libreactphysics3d.a` to the corresponding path above. For
cross-compilation, supply the target's CMake toolchain and architecture settings.

## WebAssembly

Run `scripts/build_web_artifacts.sh` with `EMSDK` set to build and verify the
engine archive, C API wrapper archive, and standalone module. It checks the
engine headers against the vendored headers.

For a manual build, activate Emscripten and provide a matching wasm32 core archive at
`native/web/libreactphysics3d.a` (not included in source control). Build that archive
from the upstream source using `emcmake cmake`, with `-pthread` and matching
single-precision settings, then build this bridge:

```sh
emcmake cmake -S native/web -B /tmp/rp3d-web -DCMAKE_BUILD_TYPE=Release
cmake --build /tmp/rp3d-web --parallel
```

Serve `/tmp/rp3d-web/build/out/reactphysics3d_dart.js` and its `.wasm` alongside your app.
The default module factory is `reactphysics3d_dart`. See README for initialization.
The build uses fixed 128 MiB shared memory and requires these response headers:

```text
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

The C++ bridge owns persistent geometry copies. The Dart web adapter frees
per-call temporary heap buffers and restores the Emscripten stack. Native pointer
results and borrowed views must obey the same lifecycle rules as FFI.

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

## Regenerate bindings

After changing the C header, regenerate both backends:

```sh
dart run ffigen --config ffigen/native.yaml
EMSDK=/path/to/emsdk dart run tool/generate_web_bindings.dart
```

Web generation must use wasm32 layouts, not the host ABI. The script supplies the
Emscripten sysroot and disables automatic macOS includes. Collision masks use `uint16_t` in the C header so ffigen_js emits their bindings.

The polygon factory now takes an explicit face count. The old global event-buffer
functions have been replaced with per-listener queue functions. Rebuild existing
native/WASM bridge binaries when upgrading; old bridge binaries are incompatible.

## Checks

```sh
dart analyze lib test example tool
dart test
dart compile js tool/web_smoke.dart -o /tmp/rp3d-web/build/out/smoke.js
node tool/run_web_smoke.cjs /tmp/rp3d-web/build/out
```

`tool/web_smoke.dart` exercises the real WASM module and expects an instantiated
module on `globalThis.rp3d`. It covers simulation, queries, events, polygon data,
large terrain input, and repeated transform reads. It can run in a cross-origin
isolated browser or with Node after instantiating the module and setting
`globalThis.self = globalThis`.
