cmake_minimum_required(VERSION 3.16)

set(PROJECT_NAME "reactphysics3d_dart")
project(${PROJECT_NAME})

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif(NOT CMAKE_BUILD_TYPE)

set(MODULE_NAME ${PROJECT_NAME})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -std=c++17 -Wno-invalid-specialization -DEMSCRIPTEN_HAS_UNBOUND_TYPE_NAMES=1")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")

# Emscripten link options
add_link_options(
    --bind
    -sALLOW_TABLE_GROWTH=1
    -sALLOW_MEMORY_GROWTH=0
    -sEXPORT_NAME=${MODULE_NAME}
    -sINITIAL_MEMORY=512mb
    -sMODULARIZE
    -sERROR_ON_UNDEFINED_SYMBOLS=0
    -sEXPORTED_RUNTIME_METHODS=wasmExports,wasmTable,addFunction,removeFunction,ccall,cwrap,intArrayFromString,intArrayToString,getValue,setValue,UTF8ToString,stringToUTF8,writeArrayToMemory,lengthBytesUTF8,HEAPU8,HEAPF32
    -sEXPORTED_FUNCTIONS=_malloc,stackAlloc,_free,stackSave,stackRestore
    -sPTHREAD_POOL_SIZE=1
    -sALLOW_BLOCKING_ON_MAIN_THREAD=1
    -sMALLOC=mimalloc
    -sNO_DISABLE_EXCEPTION_CATCHING
    -sASYNCIFY=0
    -sFETCH=0
    -sSHARED_MEMORY=0
    -sFILESYSTEM=0
    -sUSE_PTHREADS
    -sSTACK_SIZE=10485760
    -pthread
)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_link_options(
      -sASSERTIONS=2
      -sSAFE_HEAP=1
      -sWARN_UNALIGNED=1
  )
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wcast-align -Wover-aligned")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wcast-align -Wover-aligned")
endif()

link_directories("${CMAKE_CURRENT_SOURCE_DIR}/lib")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY build/out)

# Include the ReactPhysics3D Dart plugin configuration
include("${CMAKE_CURRENT_SOURCE_DIR}/reactphysics3d_dart.cmake")

# Create WebAssembly module executable from the static libraries.
#
# --whole-archive keeps every EMSCRIPTEN_KEEPALIVE entry point in
# rp3d_c_api.cpp alive: nothing in module_init.cpp references them, so
# without it the linker would strip the entire C API from the module.
add_executable(${MODULE_NAME} module_init.cpp)

set_target_properties(${MODULE_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)

target_link_libraries(${MODULE_NAME}
    -Wl,--whole-archive
    reactphysics3d_dart_static
    reactphysics3d
    -Wl,--no-whole-archive
)

