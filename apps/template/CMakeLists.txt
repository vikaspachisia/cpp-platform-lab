# apps/template/CMakeLists.txt
cmake_minimum_required(VERSION 3.18)

# Simple template app that shows how to register an app with extra properties.
add_executable(template_app main.cpp)

# Link to platformlib if present (non-fatal)
if(TARGET platformlib)
  target_link_libraries(template_app PRIVATE platformlib)
endif()

# Register app with:
# - RUN_REGEX to validate functional output
# - ARGS to demonstrate passing arguments into test execution
# - DEPENDS so build ordering can be enforced
# - TEST_NAME to override the CTest test name
register_app(template_app
  RUN_REGEX "template_app: done"
  TEST_NAME "run_template_app"
  ARGS "--example" "42"
  DEPENDS platformlib
)