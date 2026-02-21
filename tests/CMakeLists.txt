# tests/CMakeLists.txt
cmake_minimum_required(VERSION 3.18)

message(STATUS "Configuring cpp-platform-lab tests for: ${TARGET_PLATFORM}")

include(${CMAKE_SOURCE_DIR}/cmake/common.cmake)

enable_testing()

# Get list of registered apps (populated by register_app calls in subdirs)
get_registered_apps(REGISTERED_APPS)

if(NOT REGISTERED_APPS)
  message(WARNING "No registered apps found. Add executables and call register_app(<target> [RUN_REGEX <regex>] ...) in subdirs.")
endif()

# Compute environment for dynamic loader to find built shared libs
if(WIN32)
  set(_env_template "PATH=$<TARGET_FILE_DIR:%s>;$ENV{PATH}")
elseif(APPLE)
  set(_env_template "DYLD_LIBRARY_PATH=$<TARGET_FILE_DIR:%s>:$ENV{DYLD_LIBRARY_PATH}")
else()
  set(_env_template "LD_LIBRARY_PATH=$<TARGET_FILE_DIR:%s>:$ENV{LD_LIBRARY_PATH}")
endif()

# RPATH expected value per platform
if(APPLE)
  set(EXPECTED_RPATH "@executable_path")
elseif(WIN32)
  set(EXPECTED_RPATH "WINDOWS_DOT_DLL_CHECK")
else()
  set(EXPECTED_RPATH "\$ORIGIN")
endif()

# For each registered app add a verify_rpath test and a functional run test
foreach(app IN LISTS REGISTERED_APPS)
  # 1) verify rpath metadata test
  add_test(NAME verify_rpath_${app}
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_SOURCE_DIR}/cmake/check_rpath.cmake
            "$<TARGET_FILE:${app}>" "${EXPECTED_RPATH}"
  )

  # set environment for this test (so dynamic loader finds libs)
  string(REPLACE "%s" "${app}" _env_eval "${_env_template}")
  set_tests_properties(verify_rpath_${app} PROPERTIES ENVIRONMENT "${_env_eval}")

  # 2) functional run test
  # If a TEST_NAME override was stored, use it; otherwise name test run_<target>
  get_property(_test_name GLOBAL PROPERTY "APP_${app}_TEST_NAME")
  if(_test_name)
    set(_run_test_name "${_test_name}")
  else()
    set(_run_test_name "run_${app}")
  endif()

  # Retrieve optional args list
  get_property(_args GLOBAL PROPERTY "APP_${app}_ARGS")

  if(_args)
    # _args is semicolon-separated list; expand in add_test
    add_test(NAME ${_run_test_name}
      COMMAND $<TARGET_FILE:${app}> ${_args}
    )
  else()
    add_test(NAME ${_run_test_name}
      COMMAND $<TARGET_FILE:${app}>
    )
  endif()

  # Functional test environment (same)
  set_tests_properties(${_run_test_name} PROPERTIES ENVIRONMENT "${_env_eval}")

  # If a run regex was stored, attach it as expected output
  get_property(_run_re GLOBAL PROPERTY "APP_${app}_RUN_REGEX")
  if(_run_re)
    set_tests_properties(${_run_test_name} PROPERTIES PASS_REGULAR_EXPRESSION "${_run_re}")
  endif()

endforeach()

# Make verify_rpath custom target for manual runs depend on all apps
add_custom_target(verify_rpath
  COMMENT "Verify executable RPATH / DLL presence for registered apps"
)

# Add PRE_BUILD commands that run the cmake script (keeps previous behavior)
foreach(app IN LISTS REGISTERED_APPS)
  add_custom_command(TARGET verify_rpath PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_SOURCE_DIR}/cmake/check_rpath.cmake
            "$<TARGET_FILE:${app}>" "${EXPECTED_RPATH}"
    COMMENT "Checking RPATH for ${app}"
  )
endforeach()