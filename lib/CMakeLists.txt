# lib/CMakeLists.txt
cmake_minimum_required(VERSION 3.18)

message(STATUS "Configuring cpp-platform-lab lib for: ${TARGET_PLATFORM}")

# Include common helpers
include(${CMAKE_SOURCE_DIR}/cmake/common.cmake)

# Sources (use absolute paths so add_platform_library can infer header locations reliably)
set(LIB_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/platform.cpp)

# Add the library with explicit include dir
add_platform_library(platformlib ${LIB_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR})