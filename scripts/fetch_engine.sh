#!/usr/bin/env bash
#
# Fetches the upstream ReactPhysics3D engine sources and verifies that the
# engine headers vendored in this repo (native/include/reactphysics3d) match
# the pinned engine tag. The Dart bindings are generated from the vendored
# headers, so a mismatch would mean the bindings and the compiled library
# disagree — this check fails the build instead of shipping that.
#
# Usage: scripts/fetch_engine.sh [engine-dir]
#
# Environment:
#   RP3D_ENGINE_REF   engine tag/commit to build (default: v0.10.2)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RP3D_ENGINE_REF="${RP3D_ENGINE_REF:-v0.10.2}"
ENGINE_DIR="${1:-${REPO_ROOT}/build/third_party/reactphysics3d}"
ENGINE_URL="https://github.com/DanielChappuis/reactphysics3d.git"

echo "==> Fetching ReactPhysics3D ${RP3D_ENGINE_REF} into ${ENGINE_DIR}"
mkdir -p "$(dirname "${ENGINE_DIR}")"
if [ ! -d "${ENGINE_DIR}/.git" ] || [ "$(git -C "${ENGINE_DIR}" describe --tags --exact-match HEAD 2>/dev/null || true)" != "${RP3D_ENGINE_REF}" ]; then
    echo "    cloning ${RP3D_ENGINE_REF}"
    rm -rf "${ENGINE_DIR}"
    git clone --quiet --depth 1 --branch "${RP3D_ENGINE_REF}" \
        "${ENGINE_URL}" "${ENGINE_DIR}"
fi

echo "==> Verifying vendored headers against ${RP3D_ENGINE_REF}"
if ! diff -r -q "${ENGINE_DIR}/include/reactphysics3d" \
        "${REPO_ROOT}/native/include/reactphysics3d" >/dev/null; then
    echo "ERROR: native/include/reactphysics3d does not match the engine at ${RP3D_ENGINE_REF}." >&2
    echo "       Update the vendored headers and regenerate both binding sets" >&2
    echo "       (ffigen/native.yaml and ffigen/web.yaml), or pin RP3D_ENGINE_REF" >&2
    echo "       to the tag the headers came from." >&2
    diff -r -q "${ENGINE_DIR}/include/reactphysics3d" \
        "${REPO_ROOT}/native/include/reactphysics3d" | head -20 >&2 || true
    exit 1
fi
echo "    headers identical to ${RP3D_ENGINE_REF}"
