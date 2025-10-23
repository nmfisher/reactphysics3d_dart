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
    ${CMAKE_CURRENT_SOURCE_DIR}/reactphysics3d/include
    ${CMAKE_CURRENT_SOURCE_DIR}/reactphysics3d/include/c_api
    /Volumes/T7/projects/reactphysics3d/include
    ${CMAKE_CURRENT_SOURCE_DIR}/reactphysics3d/include
)

# Add Thermion include directories if specified
if(THERMION_INCLUDE_DIRS)
    include_directories(${THERMION_INCLUDE_DIRS})
endif()

# Source files
set(ENGINE_SOURCES
    reactphysics3d/src/rp3d_c_api.cpp
)

set(PHYSICS_MANAGER_SOURCES
    reactphysics3d/src/PhysicsComponentManager.cpp
    reactphysics3d/src/CharacterController.cpp
)

# Create library for the C API
add_library(reactphysics3d_capi STATIC ${ENGINE_SOURCES})

# Create library for the PhysicsComponentManager
add_library(physics_component_manager STATIC ${PHYSICS_MANAGER_SOURCES})

# Link libraries
target_link_libraries(physics_component_manager
    reactphysics3d_capi
    ${CMAKE_CURRENT_SOURCE_DIR}/reactphysics3d/lib/macos/libreactphysics3d.a
)

# Create an executable for testing
add_executable(physics_test
    test/physics_test.cpp
)

target_link_libraries(physics_test
    physics_component_manager
    reactphysics3d_capi
    ${CMAKE_CURRENT_SOURCE_DIR}/reactphysics3d/lib/macos/libreactphysics3d.a
)

# Create an executable for character controller testing
add_executable(character_jump_test
    test/character_jump_test.cpp
)

target_link_libraries(character_jump_test
    physics_component_manager
    reactphysics3d_capi
    ${CMAKE_CURRENT_SOURCE_DIR}/reactphysics3d/lib/macos/libreactphysics3d.a
)

# Installation
install(TARGETS physics_component_manager reactphysics3d_capi
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY reactphysics3d/include/
    DESTINATION include
    FILES_MATCHING PATTERN "*.h"
)

# Custom target to run tests
add_custom_target(run_test
    COMMAND physics_test
    DEPENDS physics_test
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Running physics test"
)