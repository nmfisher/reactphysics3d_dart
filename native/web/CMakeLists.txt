cmake_minimum_required(VERSION 3.16)
project(reactphysics3d_dart LANGUAGES CXX)
if(NOT EMSCRIPTEN)
  message(FATAL_ERROR "Configure this target using emcmake cmake")
endif()
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/build/out")
include("${CMAKE_CURRENT_SOURCE_DIR}/reactphysics3d_dart.cmake")
add_executable(reactphysics3d_dart module_init.cpp)
# Keep all C API exports in both the release archive and standalone module.
target_link_libraries(reactphysics3d_dart PRIVATE
  -Wl,--whole-archive reactphysics3d_dart_static reactphysics3d
  -Wl,--no-whole-archive)
target_compile_options(reactphysics3d_dart PRIVATE -pthread -fexceptions)
target_link_options(reactphysics3d_dart PRIVATE
  --no-entry
  -pthread
  -sMODULARIZE=1
  -sEXPORT_NAME=reactphysics3d_dart
  -sENVIRONMENT=web,node
  -sWASM_BIGINT=1
  -sDISABLE_EXCEPTION_CATCHING=0
  -sALLOW_MEMORY_GROWTH=0
  -sINITIAL_MEMORY=134217728
  -sSTACK_SIZE=2097152
  -sFILESYSTEM=0
  "-sEXPORTED_FUNCTIONS=['_malloc','_free','_stackSave','_stackRestore','_stackAlloc']"
  "-sEXPORTED_RUNTIME_METHODS=['getValue','setValue','HEAPU8','stackSave','stackRestore','stackAlloc']")
