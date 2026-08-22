#!/usr/bin/env bash
#
# Builds the web (Emscripten/wasm32) artifacts of reactphysics3d_dart:
#
#   native/web/libreactphysics3d.a       engine static library (wasm32) —
#                                       what reactphysics3d_dart.cmake's
#                                       IMPORTED library points at, i.e. what
#                                       a downstream wasm link needs
#   build/web/libreactphysics3d_dart.a   C API wrapper static library
#   build/web/build/out/reactphysics3d_dart.js/.wasm
#                                       standalone module (EXPORT_NAME
#                                       reactphysics3d_dart), built here so
#                                       the libraries are proven to link and
#                                       their _rp3d_* exports verified
#
# The build is then verified two ways: llvm-nm on the wrapper archive (the
# symbols really are in the artifact) and a grep over the linked module glue
# (they survived the link). scripts/fetch_engine.sh additionally refuses to
# build against engine headers that differ from the vendored ones.
#
# Usage: scripts/build_web_artifacts.sh
#
# Environment:
#   RP3D_ENGINE_REF   engine tag to build (default: v0.10.2)
#   RP3D_ENGINE_DIR   where to clone the engine (default: build/third_party/reactphysics3d)
#   EMSDK             emsdk root; if unset the script assumes emcmake/emmake
#                     are already on PATH

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RP3D_ENGINE_REF="${RP3D_ENGINE_REF:-v0.10.2}"
RP3D_ENGINE_DIR="${RP3D_ENGINE_DIR:-${REPO_ROOT}/build/third_party/reactphysics3d}"
ENGINE_BUILD_DIR="${RP3D_ENGINE_DIR}/build-web"
MODULE_BUILD_DIR="${REPO_ROOT}/build/web"

# Flags the engine must be compiled with: atomics/bulk-memory are required by
# the -sUSE_PTHREADS link of the wrapper module, and -pthread matches how the
# wrapper itself is compiled (reactphysics3d_dart.cmake).
ENGINE_CXX_FLAGS="-pthread -matomics -mbulk-memory"

if [ -n "${EMSDK:-}" ]; then
    # shellcheck disable=SC1091
    source "${EMSDK}/emsdk_env.sh" >/dev/null 2>&1
fi
command -v emcmake >/dev/null || {
    echo "ERROR: emcmake not found. Install the Emscripten SDK and set EMSDK," >&2
    echo "       e.g.:" >&2
    echo "         git clone https://github.com/emscripten-core/emsdk" >&2
    echo "         ./emsdk/emsdk install 6.0.4 && ./emsdk/emsdk activate 6.0.4" >&2
    echo "         export EMSDK=\$PWD/emsdk" >&2
    exit 1
}

"${REPO_ROOT}/scripts/fetch_engine.sh" "${RP3D_ENGINE_DIR}"

echo "==> Building the engine static library (wasm32)"
emcmake cmake -S "${RP3D_ENGINE_DIR}" -B "${ENGINE_BUILD_DIR}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="${ENGINE_CXX_FLAGS}" \
    -DRP3D_COMPILE_TESTS=OFF \
    -DRP3D_COMPILE_TESTBED=OFF
emmake cmake --build "${ENGINE_BUILD_DIR}" -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"

ENGINE_LIB="${ENGINE_BUILD_DIR}/libreactphysics3d.a"
[ -f "${ENGINE_LIB}" ] || { echo "ERROR: ${ENGINE_LIB} was not produced" >&2; exit 1; }
cp "${ENGINE_LIB}" "${REPO_ROOT}/native/web/libreactphysics3d.a"
echo "    staged native/web/libreactphysics3d.a"

echo "==> Building the wrapper library and standalone module"
emcmake cmake -S "${REPO_ROOT}/native/web" -B "${MODULE_BUILD_DIR}" \
    -DCMAKE_BUILD_TYPE=Release
emmake cmake --build "${MODULE_BUILD_DIR}" -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"

WRAPPER_LIB="${MODULE_BUILD_DIR}/libreactphysics3d_dart.a"
MODULE_JS="${MODULE_BUILD_DIR}/build/out/reactphysics3d_dart.js"
MODULE_WASM="${MODULE_BUILD_DIR}/build/out/reactphysics3d_dart.wasm"
for f in "${WRAPPER_LIB}" "${MODULE_JS}" "${MODULE_WASM}"; do
    [ -f "${f}" ] || { echo "ERROR: ${f} was not produced" >&2; exit 1; }
done

echo "==> Verifying the C API exports"

# Entry points downstream builds rely on (the ones thermion's wasm link
# requires); the wrapper exports 142 rp3d_* functions in total. Wasm object
# symbols carry no leading underscore — the "_" is a JS-side convention, so
# the archive check matches unprefixed names and the glue check prefixed ones.
REQUIRED_EXPORTS=(
    rp3d_physics_common_create
    rp3d_physics_common_create_physics_world
    rp3d_physics_common_create_box_shape
    rp3d_physics_common_create_sphere_shape
    rp3d_world_update
    rp3d_world_create_rigid_body
    rp3d_body_get_transform
)

NM="$(command -v llvm-nm || true)"
if [ -z "${NM}" ] && [ -n "${EMSDK:-}" ]; then
    NM="$(find "${EMSDK}/upstream/bin" -name 'llvm-nm*' -type f | head -1)"
fi
if [ -n "${NM}" ] && [ -x "${NM}" ]; then
    DEFINED="$("${NM}" --defined-only "${WRAPPER_LIB}" | awk '{print $NF}' | grep -v '^\.L' || true)"
    NB_EXPORTS="$(printf '%s\n' "${DEFINED}" | grep -c '^rp3d_' || true)"
    echo "    ${NB_EXPORTS} rp3d_* symbols defined in libreactphysics3d_dart.a"
    if [ "${NB_EXPORTS}" -lt 140 ]; then
        echo "ERROR: expected at least 140 rp3d_* symbols in the wrapper archive" >&2
        exit 1
    fi
    for sym in "${REQUIRED_EXPORTS[@]}"; do
        printf '%s\n' "${DEFINED}" | grep -qx "${sym}" || {
            echo "ERROR: ${sym} missing from ${WRAPPER_LIB}" >&2
            exit 1
        }
    done
else
    echo "    llvm-nm not found, skipping the archive symbol check"
fi

# The glue assigns each export as Module["_name"]=wasmExports["_name"], so
# grepping the module glue proves the symbols survived the link. Emscripten
# minifies wasm-internal names but keeps exported ones.
GLUE_EXPORTS="$(grep -o 'Module\["_rp3d_[a-z0-9_]*"\]' "${MODULE_JS}" | sort -u || true)"
NB_GLUE="$(printf '%s\n' "${GLUE_EXPORTS}" | grep -c '^Module' || true)"
echo "    ${NB_GLUE} _rp3d_* exports on the module object"
if [ "${NB_GLUE}" -lt 140 ]; then
    echo "ERROR: expected at least 140 _rp3d_* exports in ${MODULE_JS}" >&2
    exit 1
fi
for sym in "${REQUIRED_EXPORTS[@]}"; do
    printf '%s\n' "${GLUE_EXPORTS}" | grep -qx "Module\[\"_${sym}\"\]" || {
        echo "ERROR: ${sym} missing from the module glue ${MODULE_JS}" >&2
        exit 1
    }
done

echo "==> Smoke-testing the module under node"
# Drop a body from y=10 for 2s of updates and check gravity pulled it down:
# after t seconds it should be near 10 - g*t^2/2 = -9.62. This exercises the
# engine (not just the wrappers) and fails on a module that links but cannot
# actually simulate.
NODE_BIN="$(command -v node || true)"
if [ -z "${NODE_BIN}" ] && [ -n "${EMSDK:-}" ]; then
    NODE_BIN="$(find "${EMSDK}/node" -name node -type f | head -1)"
fi
if [ -n "${NODE_BIN}" ] && [ -x "${NODE_BIN}" ]; then
    "${NODE_BIN}" - "${MODULE_JS}" <<'EOF'
const moduleJs = process.argv[2];
require(moduleJs)().then(Module => {
    const common = Module._rp3d_physics_common_create();
    const world = Module._rp3d_physics_common_create_physics_world(common);
    // RP3D_Transform: position (3 floats) + quaternion (4 floats)
    const tr = Module._malloc(28);
    [0, 10, 0, 0, 0, 0, 1].forEach((v, i) => Module.setValue(tr + 4 * i, v, "float"));
    const body = Module._rp3d_world_create_rigid_body(world, tr);
    for (let i = 0; i < 120; i++) Module._rp3d_world_update(world, 1 / 60);
    const out = Module._malloc(28);
    Module._rp3d_body_get_transform(body, out);
    const y = Module.getValue(out + 4, "float");
    if (Number.isNaN(y) || y > 9.0) {
        console.error(`SMOKE FAILED: body at y=${y} after 2s of updates, expected it to fall`);
        process.exit(1);
    }
    console.log(`    body fell from y=10 to y=${y.toFixed(3)} in 2s of updates`);
}).catch(e => { console.error("SMOKE FAILED:", e && e.message || e); process.exit(1); });
EOF
else
    echo "    node not found, skipping the module smoke test"
fi

echo "==> Web artifacts built and verified:"
ls -lh "${REPO_ROOT}/native/web/libreactphysics3d.a" \
       "${WRAPPER_LIB}" "${MODULE_JS}" "${MODULE_WASM}"
