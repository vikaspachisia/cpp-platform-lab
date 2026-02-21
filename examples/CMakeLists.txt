# examples/CMakeLists.txt
cmake_minimum_required(VERSION 3.18)

include(${CMAKE_SOURCE_DIR}/cmake/common.cmake)

# Example: implicit linking to library (link-time)
add_executable(platform_app main.cpp)
target_include_directories(platform_app PRIVATE ${CMAKE_SOURCE_DIR}/lib)
target_link_libraries(platform_app PRIVATE platformlib)
# register the app and the expected run output regex
register_app(platform_app RUN_REGEX "library returned 0")

# Example: explicit runtime loader
add_executable(loader_app loader.cpp)
target_include_directories(loader_app PRIVATE ${CMAKE_SOURCE_DIR}/lib)
# loader app uses runtime loading; expect it to print the platformlib message
register_app(loader_app RUN_REGEX "platformlib: running")

# On UNIX link against libdl for runtime loading support if available
if(UNIX)
  find_library(DL_LIB dl)
  if(DL_LIB)
    target_link_libraries(loader_app PRIVATE ${DL_LIB})
  endif()
endif()