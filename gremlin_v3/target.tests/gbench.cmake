# ----------------------------
# NOTE: the file must be includded into a root level CMakeLists.txt
# ----------------------------
# https://github.com/google/benchmark/?tab=readme-ov-file#usage-with-cmake
#

find_package(benchmark REQUIRED)

function(gn3_target_gbench_configure TARGET)
  # NOTE: usually tests are written without explicit `int main()`
  target_link_libraries(${TARGET} PRIVATE benchmark::benchmark benchmark::benchmark_main)
endfunction()
