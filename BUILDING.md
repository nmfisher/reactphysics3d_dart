# Building and validating

The repository contains ReactPhysics3D **0.10.2 headers**, its C bridge, and
precompiled native archives. It does not contain the upstream C++ implementation
or a root CMake project. Rebuilding the core requires a matching upstream source
tree. Keep its precision/build configuration consistent with the bundled headers;
do not enable double precision with the current wrapper build.

## Native

With Dart 3.10 or later and a C++17 toolchain, run:

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
| Windows x64 | `native/windows/x86_64/reactphysics3d.lib` |

The bundled macOS archive targets macOS 13 or later. The table lists the native
targets supported by the pub.dev package. Windows requires the MSVC C++
toolchain. For a source build targeting macOS x86_64, place the matching
release archive in `native/macos/x86_64/`.

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

The files in `native/web/` serve two purposes.

- `reactphysics3d_dart.js` and `reactphysics3d_dart.wasm` for the browser.
- `libreactphysics3d.a` and `libreactphysics3d_dart.a` for downstream
  Emscripten links. They were built with Emscripten 6.0.4 using
  `-pthread -matomics -mbulk-memory`.

Use `dart pub unpack reactphysics3d_dart:0.1.0 --no-resolve` to extract these
files from the published package.

From a [repository checkout](https://github.com/nmfisher/reactphysics3d_dart),
run `scripts/build_web_artifacts.sh` with `EMSDK` set to build and verify the
engine archive, C API wrapper archive, and standalone module. The script checks
the engine headers against the vendored headers. To update the bundle, copy
`build/web/libreactphysics3d_dart.a` and the module files from
`build/web/build/out/` into `native/web/`. The script updates the engine
archive there as part of the build.

For a manual bridge build with the bundled wasm32 core, activate Emscripten
and run:

```sh
emcmake cmake -S native/web -B /tmp/rp3d-web -DCMAKE_BUILD_TYPE=Release
cmake --build /tmp/rp3d-web --parallel
```

Serve the bundled module or the one built in `/tmp/rp3d-web/build/out/` alongside your app.
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

The Build artifacts workflow builds these ZIPs on pull requests and manual runs.
The Publish to pub.dev workflow builds them again for each version tag and attaches
them to the GitHub release.

| Artifact (`reactphysics3d_dart-<version>-<platform>.zip`) | Contents |
|---|---|
| `web-emscripten` | `libreactphysics3d.a` (engine, wasm32) + `libreactphysics3d_dart.a` (C API wrapper), built with `-pthread -matomics -mbulk-memory`. Extract into `native/web/` next to `reactphysics3d_dart.cmake`. Link with the same or newer Emscripten. |
| `web-module` | The standalone `reactphysics3d_dart.js`/`.wasm` module, for loading the library directly on a page instead of linking it into another wasm. |
| `linux-x86_64`, `linux-aarch64`, `macos-arm64`, `macos-x86_64`, `windows-x64` | `libreactphysics3d.a` (`reactphysics3d.lib` on Windows) built from the pinned engine source. |

Each zip contains a `README.txt` manifest and the applicable licenses.
`RP3D_ENGINE_REF` in the workflow pins the engine commit. The fetch script checks
that the engine headers at that commit match `native/include/reactphysics3d/`.

### Configure publishing

1. Publish the first version manually with `dart pub publish` from the release
   commit. Pub.dev requires an existing package for automated publishing.
2. On the package's pub.dev Admin tab, enable automated publishing for
   `nmfisher/reactphysics3d_dart` with tag pattern `v{{version}}`. Configure
   required reviewers on the GitHub `pub.dev` environment if publication
   should wait for maintainer approval.
3. Add a fine-grained GitHub PAT as the repository secret `RELEASE_TOKEN`.
   Grant **Contents: read and write** and **Actions: read and write** for
   this repository so a workflow-created tag triggers the publishing workflow.

### Cut a release

Update `pubspec.yaml` and `CHANGELOG.md`, then push the release commit to
`master`. Dispatch **Create Release** from Actions or run
`gh workflow run release.yml`. The workflow reads the version from
`pubspec.yaml` by default and pushes an annotated `v<version>` tag.

The tag starts **Publish to pub.dev**. It checks the tag and package version,
runs the package dry run and CI, builds the ZIPs, and creates the GitHub release.
Once automated publishing is enabled, the `pub.dev` job uploads the package
using GitHub OIDC. If the package is new, the workflow creates the GitHub
release and leaves the first pub.dev upload to the maintainer. A manual dispatch
of **Publish to pub.dev** runs validation only. If a tagged run fails, rerun
that run after resolving the failure.

## Regenerate bindings

After changing the C header in a repository checkout, regenerate both backends:

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
