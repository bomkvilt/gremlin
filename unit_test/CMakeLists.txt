include(GoogleTest)

# get all linkable units
GN_get(modules "GN_tests_units")


foreach(module ${modules})
    set(target "${GN_tests_target}_${module}")
    set(test   "${GN_tests_test}_${module}")

    # create a testing target
    GB_Module( ${target}
        Modules         ${modules}
        Libs            gtest gtest_main
        Definitions     "-Dall_load"
        Mode            "app"
        bFlat           off)

    # create a ctest
    add_test(NAME ${test} COMMAND ${target})
    gtest_discover_tests(${target})

    # move to specified filter
    foreach(target gtest gtest_main ${target})
        set_target_properties(${target} PROPERTIES FOLDER ${GN_tests_filter})
        endforeach()

    # enable initialisation of static variable inside static libraries...
    SET_TARGET_PROPERTIES(${target} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE:${module}")
    endforeach()
