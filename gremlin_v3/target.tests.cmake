# ----------------------------
# NOTE: the file must be includded into a root level CMakeLists.txt
# ----------------------------

enable_testing()
include(CTest)

# if (<use_gtest>)
include("${CMAKE_CURRENT_LIST_DIR}/target.tests/gtest.cmake")
