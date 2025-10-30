cmake_minimum_required(VERSION 3.16)
project(reactphysics3d_dart)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set build type to Debug by default
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

# Compiler-specific options
if(MSVC)
    add_compile_options(/W4)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Thermion include directories (can be set from command line with -DTHERMION_INCLUDE_DIRS=/path/to/include)
set(THERMION_INCLUDE_DIRS "" CACHE PATH "Directory for Thermion headers")

# Find required packages
find_package(PkgConfig REQUIRED)

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include/c_api
    /Volumes/T7/projects/reactphysics3d/include
    /Users/nickfisher/Documents/mixworld/thermion_input_handler_component/native/include
)

# Add Thermion include directories if specified
if(THERMION_INCLUDE_DIRS)
    include_directories(${THERMION_INCLUDE_DIRS})
endif()

# Source files
set(ENGINE_SOURCES
    src/rp3d_c_api.cpp
)

# Create library for the C API
add_library(reactphysics3d_capi STATIC ${ENGINE_SOURCES})

# Link libraries for the C API
target_link_libraries(reactphysics3d_capi
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/macos/libreactphysics3d.a
)

# Note: To run tests, use dart test in the root directory

# Installation
install(TARGETS reactphysics3d_capi
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include
    FILES_MATCHING PATTERN "*.h"
)

# Custom target to run tests
# Note: Tests are run using dart test from the project root