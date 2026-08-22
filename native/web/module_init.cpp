/*
 * Standalone ReactPhysics3D web module.
 *
 * Every entry point in native/src/rp3d_c_api.cpp is EMSCRIPTEN_KEEPALIVE, so
 * the real exports of this module come from the static libraries linked in
 * CMakeLists.txt (kept alive there with --whole-archive). This translation
 * unit only gives the module target a source file and one trivial export a
 * loader can use to confirm the module initialised.
 */

#include <emscripten.h>

extern "C" EMSCRIPTEN_KEEPALIVE int rp3d_module_init(void) {
    return 1;
}
