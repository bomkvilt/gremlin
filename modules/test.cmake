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

function(GN_test_add unit)
    if (
        NOT ${${unit}_name} MATCHES "^${GN_tests_prefix}"
        AND NOT "${${unit}_Mode}" STREQUAL "app"
        AND NOT ${unit}_bFlat
    )
        GNU_addDir(${unit} "internal.test" "${GN_dir_tests}")
        GNU_getSrcFrom(files ${unit} "internal.test")
        if ("${files}" STREQUAL "")
            return()
            endif()

        GNU_addDir(${unit} "private" "internal.test")
        GNU_addDir(${unit} "project" "internal.test")
        GNU_parseSrc(${unit})

        GN_cache(${unit}_extra_test on)
        endif()
    endfunction()

function(GN_test_gen unit)
    if (${unit}_extra_test)
        set(name   "${${unit}_name}")
        set(target "${GN_tests_prefix}${name}")
        set(test   "${GN_tests_prefix}${name}")
        GN_Unit(${target}
            Units       ${name}
            Private     ${GN_test_include}
            Libs        ${GN_test_libs}
            Definitions "-Dall_load"
            Mode        "app" 
        )
        set_target_properties(${target} PROPERTIES FOLDER ${GN_tests_filter})
        endif()
    endfunction()
