include(GoogleTest)

macro(GN_test_gen unit)
    set(name   "${${unit}_name}")
    set(target "${GN_tests_prefix}${name}")
    set(test   "${GN_tests_prefix}${name}-test")
    GN_Unit(${target}
        Units       ${name}
        Libs        GTest::GTest GTest::Main
        Definitions "-Dall_load"
        Mode        "app" 
        bFlat
    )
    add_test(NAME ${test} COMMAND ${target})
    gtest_discover_tests(${target})
    
    set_target_properties(${target} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE:${name}")
    set_target_properties(${target} PROPERTIES FOLDER ${GN_tests_filter})
    endmacro()


foreach(unitName ${GN_units})
    GN_getUnit(unit ${unitName})
    if (${unit}_extra_test)
        GN_test_gen(${unit})
        endif()
    endforeach()
