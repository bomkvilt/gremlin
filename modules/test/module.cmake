## --------------------------| variables |-------------------------- ##
## -----------| settings
GN_option(GN_test_bEnabled  on)
GN_option(GN_tests_filter   "utiles/tests")
GN_option(GN_tests_prefix   "test.")
GN_option(GN_dir_tests      "Test")

## --------------------------| initialisation |-------------------------- ##

macro(GN_test_init)
    # download gtest
    GN_vcpkg_install("gtest")
    # presetup tests
    enable_testing()
    find_package(GTest MODULE REQUIRED)
    endmacro()


## --------------------------| internal |-------------------------- ##

function(GN_test_add unit)
    if (
            NOT ${${unit}_name} MATCHES "^${GN_tests_prefix}"
        AND NOT ${${unit}_Mode} STREQUAL "app"
        AND NOT ${unit}_bFlat
    )
        GNU_addDir(${unit} "internal.test" "${GN_dir_tests}")
        GNU_getSrcFrom(files ${unit} "internal.test")
        if ("${files}" STREQUAL "")
            return()
            endif()
        GN_append(${unit}_libs ${args_LIBS} GTest::GTest)

        GNU_addDir(${unit} "private" "internal.test")
        GNU_addDir(${unit} "project" "internal.test")
        GNU_parseSrc(${unit})

        GN_cache(${unit}_extra_test on)
        endif()
    endfunction()
