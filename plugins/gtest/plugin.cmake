# ---------------------------| 
GN_option(GN_gtest_root ${CMAKE_CURRENT_LIST_DIR})
GN_option(GN_gtest_proj ${CMAKE_CURRENT_BINARY_DIR}/gtest)
GN_option(GN_gtest_extentions ".h" ".hpp")
GN_option(GN_gtest_filter "utiles/tests")
GN_option(GN_gtest_prefix "test.")
GN_option(GN_gtestDir "tests")


macro(init pluginManager)
    GNP_bind(${pluginManager} "unit_modifyArguments"   ${GN_gtest_root}/events.cmake)
    GNP_bind(${pluginManager} "unit_constructMetadata" ${GN_gtest_root}/events.cmake)
    GNP_bind(${pluginManager} "unit_processSources"    ${GN_gtest_root}/events.cmake)
    GNP_bind(${pluginManager} "solution_configure"  ${GN_gtest_root}/events.cmake)
    GNP_bind(${pluginManager} "solution_configured" ${GN_gtest_root}/events.cmake)
    # \todo why do we need to copy the test project???
    file(COPY "${GN_gtest_root}/project/" DESTINATION ${GN_gtest_proj})
    endmacro()

macro(GN_gtest_configure)
    # install gtest if it's required
    GN_vcpkg_install("gtest")
    # enable test environment
    enable_testing()
    find_package(GTest REQUIRED)
    endmacro()

function(GN_gtest_modifyArgs unit)
    GNU_get(mode ${unit} "mode")
    if (${mode} STREQUAL "eTests")
        # convert to an 'eApp' mode
        GNU_set(${unit} "mode" "eApp")
        GNU_set(${unit} "gtest.pureTest" on)
        GNU_setArgs(${unit} "bFlat" on)

        # add GTest libraries
        GNU_getArgs(libs ${unit} "libs")
        GN_appendListUnique(libs "${libs}" 
            GTest::GTest 
            GTest::Main
        )
        GNU_setArgs(${unit} "libs" "${libs}")
        endif()
    endfunction()

function(GN_gtest_detectTests unit)
    GNU_get(mode ${unit} "mode")
    GNU_get(root ${unit} "root")
    GNU_getArgs(bFlat ${unit} "bFlat")
    # create a test target if the unit is a library
    if (NOT ${unit} MATCHES "^${GN_gtest_prefix}"
        AND (
                ${mode} STREQUAL "eStatic" 
            OR  ${mode} STREQUAL "eDynamic" 
        )
        AND NOT ${bFlat}
    )
        # create a private source type and mark the unit as test-supporting
        GNU_addSrcType(${unit} "gtest" off)
        GNU_addSrcDirs(${unit} "gtest" "${root}/${GN_gtestDir}")
        GNU_set(${unit} "gtest.toTests" on)
        GN_return()
        endif()
    endfunction()

function(GN_gtest_addToTests unit)
    # check if the target must be connected to a testing system
    GNU_get(ok ${unit} "gtest.toTests")
    if (NOT ok)
        return()
        endif()
    # get test source files. The list must be not empty
    GNU_get(tests ${unit} "srcFiles.gtest")
    if ("${tests}" STREQUAL "")
        return()
        endif()
    # add the unit to a list of units must be linked with test entrypoints
    GN_appendListUnique(newList ${GN_gtest_units} ${unit})
    GN_cachef(GN_gtest_units "${newList}")
    endfunction()
    