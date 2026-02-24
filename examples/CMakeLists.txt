# examples/CMakeLists.txt
cmake_minimum_required(VERSION 3.18)

include(${CMAKE_SOURCE_DIR}/cmake/common.cmake)

# Example: implicit linking to library (link-time)
add_executable(platform_app main.cpp)
target_include_directories(platform_app PRIVATE ${CMAKE_SOURCE_DIR}/lib)
target_link_libraries(platform_app PRIVATE platformlib)
# register the app and the expected run output regex
register_app(platform_app RUN_REGEX "library returned 0")

# Example: explicit runtime loader (platform-specific implementation)
set(LOADER_IMPL_SRC "")

if(WIN32)
  list(APPEND LOADER_IMPL_SRC ${CMAKE_CURRENT_SOURCE_DIR}/loader_win.cpp)
else()
  list(APPEND LOADER_IMPL_SRC ${CMAKE_CURRENT_SOURCE_DIR}/loader_posix.cpp)
endif()

add_executable(loader_app ${CMAKE_CURRENT_SOURCE_DIR}/loader.cpp ${LOADER_IMPL_SRC})
target_include_directories(loader_app PRIVATE ${CMAKE_SOURCE_DIR}/lib ${CMAKE_CURRENT_SOURCE_DIR})
# loader app uses runtime loading; expect it to print the platformlib message
register_app(loader_app RUN_REGEX "platformlib: running")

# On UNIX link against libdl for runtime loading support if available
if(UNIX)
  find_library(DL_LIB dl)
  if(DL_LIB)
    target_link_libraries(loader_app PRIVATE ${DL_LIB})
  endif()
endif()