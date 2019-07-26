## --------------------------| variables |-------------------------- ##
## -----------| settings
GN_cache(GN_test_bEnabled   on)
GN_cache(GN_tests_filter    "utiles/tests")
GN_cache(GN_tests_prefix    "test.")
GN_cache(GN_dir_tests       "Test")

## --------------------------| initialisation |-------------------------- ##

function(GN_test_init)
    # download gtest
    GN_vcpkg_install("gtest")
    # presetup tests
    enable_testing()
    find_path   (incs "gtest/gtest.h")
    find_library(libs NAMES "gtest" "gtest_main")
    GN_cache(GN_test_include ${incs})
    GN_cache(GN_test_libs    ${libs})
    find_package(GTest MODULE REQUIRED)
    endfunction()


## --------------------------| internal |-------------------------- ##

function(GN_test_Add unit)
    if (
        NOT ${unit} MATCHES "^${GN_tests_prefix}"
        AND (
                "${${unit}_mode}" STREQUAL "lib"
            OR  "${${unit}_mode}" STREQUAL "dll"
        )
        AND NOT ${unit}_bFlat
    )
        # GN_addDir(${unit} "test" "${GN_dir_tests}")
        # GN_scanSources(${unit}_src_test  ${${unit}_dir_test}  ${${unit}_dir_root})
        # GN_debug("test directory" "${${unit}_dir_test}")
        # GN_debug("test files"     "${${unit}_src_test}")
        # if ("${${unit}_src_test}" STREQUAL "")
        #     return()
        #     endif()
        # list(APPEND ${unit}_dirs_private "${${unit}_dir_test}")

        # set(target "${GN_tests_prefix}${unit}")
        # set(test   "${GN_tests_prefix}${unit}")
        # GN_Unit(${target}
        #     Units       ${unit}
        #     Libs        GTest::GTest GTest::Main
        #     Definitions "-Dall_load"
        #     Mode        "app" )
        # set_target_properties(${target} PROPERTIES FOLDER ${GN_tests_filter})
        endif()
    endfunction()
