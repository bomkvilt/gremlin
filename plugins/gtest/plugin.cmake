# ---------------------------| 
GN_option(GN_gtest_root ${CMAKE_CURRENT_LIST_DIR})
GN_option(GN_gtest_proj ${CMAKE_CURRENT_BINARY_DIR}/gtest)
GN_option(GN_gtest_extentions ".h" ".hpp")
GN_option(GN_gtest_filter "utiles/tests")
GN_option(GN_gtest_prefix "test.")
GN_option(GN_gtestDir "tests")


macro(init pluginManager)
    GNP_bind(${pluginManager} "construct" ${GN_gtest_root}/events.cmake)
    GNP_bind(${pluginManager} "solution_configure" ${GN_gtest_root}/events.cmake)
    GNP_bind(${pluginManager} "solution_configured" ${GN_gtest_root}/events.cmake)
    file(COPY "${GN_gtest_root}/project/" DESTINATION ${GN_gtest_proj})
    endmacro()

macro(GN_gtest_configure)
    GN_vcpkg_install("gtest")
    enable_testing()
    find_package(GTest REQUIRED)
    endmacro()

function(GN_gtest unit)
    GNU_get(mode ${unit} "mode")
    GNU_get(root ${unit} "root")
    GNU_getArgs(bFlat ${unit} "bFlat")
    if (NOT ${unit} MATCHES "^${GN_gtest_prefix}"
    AND NOT ${mode} STREQUAL "eApp"
    AND NOT ${bFlat})
        GNU_addSrcType(${unit} "gtest" off)
        GNU_addSrcDirs(${unit} "gtest" "${root}/${GN_gtestDir}")
        GN_appendListUnique(tmp ${GN_gtest_units} ${unit})
        GN_cachef(GN_gtest_units "${tmp}")
        endif()
    endfunction()
