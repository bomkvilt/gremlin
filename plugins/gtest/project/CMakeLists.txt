include(GoogleTest)

macro(GN_gtest_addTest unit)
    set(test "${GN_gtest_prefix}${unit}")
    GN_unit(${test} bFlat
        mode  "eApp"
        units ${unit}
        libs  GTest::GTest GTest::Main
        defs_public "all_load"
    )
    add_test(NAME ${test} COMMAND ${test})
    gtest_discover_tests (${test})
    set_target_properties(${test} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE:${unit}")
    set_target_properties(${test} PROPERTIES FOLDER ${GN_gtest_filter})
    endmacro()

foreach(unit ${GN_gtest_units})
    GN_gtest_addTest(${unit})
    endforeach()
