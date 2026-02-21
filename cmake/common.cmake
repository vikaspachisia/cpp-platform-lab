# cmake/common.cmake
cmake_minimum_required(VERSION 3.18)

# Common project-wide defaults (can be overridden before include)
if(NOT DEFINED PROJECT_CXX_STANDARD)
  set(PROJECT_CXX_STANDARD 17)
endif()
set(CMAKE_CXX_STANDARD ${PROJECT_CXX_STANDARD})
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Ensure threads are available to callers
find_package(Threads REQUIRED)

# Stable build layout: put runtime libs + exes under build/bin, archives under build/lib
function(set_runtime_dirs target)
  set_target_properties(${target} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
  )
endfunction()

# Platform-appropriate RPATH helper for executables
function(set_rpath_for_exe target)
  if(APPLE)
    set(_rpath "@executable_path")
  elseif(WIN32)
    set(_rpath "")
  else()
    # literal $ORIGIN
    set(_rpath "\$ORIGIN")
  endif()

  if(_rpath)
    set_target_properties(${target} PROPERTIES
      BUILD_RPATH "${_rpath}"
      INSTALL_RPATH "${_rpath}"
      BUILD_WITH_INSTALL_RPATH TRUE
    )
  endif()
endfunction()

# Convenience to create platformlib (shared + static) and basic install
# Usage:
#   add_platform_library(<name> <sources...> <include-dir>)
# Example:
#   add_platform_library(platformlib "${CMAKE_CURRENT_SOURCE_DIR}/platform.cpp" "${CMAKE_CURRENT_SOURCE_DIR}")
function(add_platform_library name)
  if(ARGC LESS 2)
    message(FATAL_ERROR "add_platform_library requires at least 2 args: name, sources..., include-dir")
  endif()

  # Last argument is include directory
  list(GET ARGV -1 include_dir)
  # All previous args are sources (skip first which is name)
  list(SUBLIST ARGV 1 -1 sources)

  add_library(${name} ${sources})
  target_include_directories(${name}
    PUBLIC $<BUILD_INTERFACE:${include_dir}>
           $<INSTALL_INTERFACE:include>
  )
  # link threads by default
  target_link_libraries(${name} PRIVATE Threads::Threads)

  # versioning
  set_target_properties(${name} PROPERTIES VERSION 0.1.0 SOVERSION 0)

  set_runtime_dirs(${name})

  # static variant
  add_library(${name}_static STATIC ${sources})
  target_include_directories(${name}_static
    PUBLIC $<BUILD_INTERFACE:${include_dir}>
           $<INSTALL_INTERFACE:include>
  )
  target_link_libraries(${name}_static PRIVATE Threads::Threads)
  set_target_properties(${name}_static PROPERTIES OUTPUT_NAME ${name})
  set_runtime_dirs(${name}_static)

  # install rules
  install(TARGETS ${name} ${name}_static
    EXPORT ${name}Targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    INCLUDES DESTINATION include
  )

  # install public headers if present in include_dir (platform.h expected)
  if(EXISTS "${include_dir}/platform.h")
    install(FILES "${include_dir}/platform.h" DESTINATION include)
  endif()

  install(EXPORT ${name}Targets
    FILE ${name}Targets.cmake
    NAMESPACE ${name}::
    DESTINATION lib/cmake/${name}
  )
endfunction()

# ------------------------------------------------------------------
# App registration API (extended)
# register_app(<target> [RUN_REGEX <regex>] [TEST_NAME <name>] [ARGS <arg1> <arg2> ...]
#              [DEPENDS <target1> <target2> ...] [NO_INSTALL])
#
# - Sets runtime dirs and rpath for the target
# - Optionally wires dependencies via DEPENDS
# - Optionally stores RUN_REGEX / TEST_NAME / ARGS used by tests
# - Installs the target into bin by default (omit install with NO_INSTALL)
# - Records the target in a global REGISTERED_APPS list used by tests
# ------------------------------------------------------------------
function(register_app target)
  # options / single-value / multi-value
  cmake_parse_arguments(R "NO_INSTALL" "TEST_NAME;RUN_REGEX;TYPE;INSTALL_CONFIG" "DEPENDS;ARGS" ${ARGN})

  if(NOT TARGET ${target})
    message(FATAL_ERROR "register_app: target '${target}' does not exist")
  endif()

  # Wire declared dependencies so build order is correct
  if(R_DEPENDS)
    foreach(_dep IN LISTS R_DEPENDS)
      if(TARGET ${_dep})
        add_dependencies(${target} ${_dep})
      else()
        message(WARNING "register_app: declared DEPENDS target '${_dep}' does not exist (ignored)")
      endif()
    endforeach()
  endif()

  # Ensure runtime layout and rpath are set
  set_runtime_dirs(${target})
  set_rpath_for_exe(${target})

  # Install unless explicit NO_INSTALL option provided
  if(NOT R_NO_INSTALL)
    install(TARGETS ${target} RUNTIME DESTINATION bin)
  endif()

  # Record the app target in a global list
  get_property(_cur_apps GLOBAL PROPERTY REGISTERED_APPS)
  if(NOT _cur_apps)
    set(_cur_apps "")
  endif()
  set_property(GLOBAL APPEND PROPERTY REGISTERED_APPS "${target}")

  # Store optional run regex as a global property keyed by target name
  if(R_RUN_REGEX)
    set_property(GLOBAL PROPERTY "APP_${target}_RUN_REGEX" "${R_RUN_REGEX}")
  endif()

  # Store optional test name override
  if(R_TEST_NAME)
    set_property(GLOBAL PROPERTY "APP_${target}_TEST_NAME" "${R_TEST_NAME}")
  endif()

  # Store optional ARGS (multi-valued). Keep as semicolon-separated list.
  if(R_ARGS)
    # R_ARGS is already a list; store it
    set_property(GLOBAL PROPERTY "APP_${target}_ARGS" "${R_ARGS}")
  endif()

  # Store TYPE (informational)
  if(R_TYPE)
    set_property(GLOBAL PROPERTY "APP_${target}_TYPE" "${R_TYPE}")
  endif()

  # Store any INSTALL_CONFIG (multi-config installer hint)
  if(R_INSTALL_CONFIG)
    set_property(GLOBAL PROPERTY "APP_${target}_INSTALL_CONFIG" "${R_INSTALL_CONFIG}")
  endif()
endfunction()

# Helper: return registered apps into a variable
# Usage: get_registered_apps(VAR)
function(get_registered_apps out_var)
  get_property(_apps GLOBAL PROPERTY REGISTERED_APPS)
  if(NOT _apps)
    set(_apps "" PARENT_SCOPE)
  else()
    set(${out_var} "${_apps}" PARENT_SCOPE)
  endif()
endfunction()