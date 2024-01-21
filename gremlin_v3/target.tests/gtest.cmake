# ----------------------------
# NOTE: the file must be includded into a root level CMakeLists.txt
# ----------------------------

find_package(GTest REQUIRED)

# NOTE: import gtest_discover_tests
include(GoogleTest)


function(gn3_target_gtest_configure TARGET)
  # NOTE: usually tests are written without explicit `int main()`
  target_link_libraries(${TARGET} PRIVATE GTest::GTest GTest::Main)

  # NOTE: expand the target's tests to individual ctests
  gtest_discover_tests(
    ${TARGET}
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    PROPERTIES
      VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
  )
endfunction()
