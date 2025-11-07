# ReactPhysics3D Dart Plugin Configuration
# This configuration builds a static library for ReactPhysics3D
# that can be linked into the mixworld client build.

message(STATUS "Building ReactPhysics3D static library")

# ReactPhysics3D source files
set(RP3D_DART_SOURCES
  "${CMAKE_CURRENT_LIST_DIR}/../src/rp3d_c_api.cpp"
)

# ReactPhysics3D include directories
set(RP3D_DART_INCLUDE_DIRS
  "${CMAKE_CURRENT_LIST_DIR}/../include"
  "${CMAKE_CURRENT_LIST_DIR}/../include/c_api"
)

# Import the actual ReactPhysics3D library
add_library(reactphysics3d STATIC IMPORTED)
set_property(TARGET reactphysics3d PROPERTY
  IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/libreactphysics3d.a")

# Create a static library for ReactPhysics3D C API wrapper
add_library(reactphysics3d_dart_static STATIC ${RP3D_DART_SOURCES})

# Set include directories for the library
target_include_directories(reactphysics3d_dart_static PUBLIC ${RP3D_DART_INCLUDE_DIRS})

# Set compile definitions for the library
target_compile_definitions(reactphysics3d_dart_static PUBLIC
  "EMSCRIPTEN_HAS_UNBOUND_TYPE_NAMES=1"
)

# Set compile options for the library
target_compile_options(reactphysics3d_dart_static PRIVATE
  "-stdlib=libc++"
  "-std=c++17"
  "-Wno-invalid-specialization"
  "-DEMSCRIPTEN_HAS_UNBOUND_TYPE_NAMES=1"
  "-matomics"
  "-mbulk-memory"
)

# Link the actual ReactPhysics3D library to the wrapper
target_link_libraries(reactphysics3d_dart_static PUBLIC reactphysics3d)

# Export both libraries for use in the main build
# Append to EXTERNAL_ALL_LIBRARIES so they get linked into the final executable
list(APPEND EXTERNAL_ALL_LIBRARIES reactphysics3d_dart_static reactphysics3d)