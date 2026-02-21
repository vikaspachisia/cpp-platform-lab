cmake_minimum_required(VERSION 3.18)
project(cpp-platform-lab LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Options
option(BUILD_SHARED_LIBS "Build libraries as shared by default" ON)
option(BUILD_EXAMPLES "Build example executables" ON)
option(ENABLE_PACKAGING "Enable CPack packaging targets" ON)

# Print invocation helper (disabled by default)
option(PRINT_INVOCATIONS "Print recommended CMake invocations at configure time" OFF)

# Detect platform string for messages
if(WIN32)
  set(TARGET_PLATFORM "windows")
elseif(APPLE)
  set(TARGET_PLATFORM "apple")
elseif(ANDROID)
  set(TARGET_PLATFORM "android")
elseif(UNIX)
  set(TARGET_PLATFORM "linux")
else()
  set(TARGET_PLATFORM "unknown")
endif()

message(STATUS "Configuring cpp-platform-lab for: ${TARGET_PLATFORM}")
message(STATUS "BUILD_SHARED_LIBS = ${BUILD_SHARED_LIBS}")

# Include modularized settings
include(${CMAKE_SOURCE_DIR}/cmake/arch.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/feature_detection.cmake)

# Optional: print recommended invocations at configure time
if(PRINT_INVOCATIONS)
  if(EXISTS "${CMAKE_SOURCE_DIR}/cmake/helpers/show_invocations.cmake")
    message(STATUS "PRINT_INVOCATIONS=ON — showing recommended CMake invocations")
    include("${CMAKE_SOURCE_DIR}/cmake/helpers/show_invocations.cmake")
  else()
    message(WARNING "PRINT_INVOCATIONS=ON but helper not found: ${CMAKE_SOURCE_DIR}/cmake/helpers/show_invocations.cmake")
  endif()
endif()

# Subdirectories
add_subdirectory(lib)

if(BUILD_EXAMPLES)
  add_subdirectory(examples)
endif()

# Tests
if(BUILD_TESTING)
  add_subdirectory(tests)
endif()

# Install packaging
if(ENABLE_PACKAGING)
    
    if(NOT CPack_Configuration_included)
        include(CPack)
    endif()
  set(CPACK_PACKAGE_NAME "cpp-platform-lab")
  set(CPACK_PACKAGE_VENDOR "cpp-platform-lab")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Platform lab - libraries and examples")
  set(CPACK_PACKAGE_VERSION_MAJOR 0)
  set(CPACK_PACKAGE_VERSION_MINOR 1)
  set(CPACK_PACKAGE_VERSION_PATCH 0)
  set(CPACK_GENERATOR "TGZ;ZIP")
endif()

file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/USAGE.md" DESTINATION "${CMAKE_BINARY_DIR}")
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/scripts/show_build_commands.sh" DESTINATION "${CMAKE_BINARY_DIR}")
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/cmake/helpers/show_invocations.cmake" DESTINATION "${CMAKE_BINARY_DIR}")

execute_process(COMMAND ${CMAKE_COMMAND} -E chmod +x "${CMAKE_BINARY_DIR}/show_build_commands.sh")

