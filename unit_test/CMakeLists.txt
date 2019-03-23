include(GoogleTest)

# get all linkable units
GN_get(modules "GN_tests_units")

# create a testing target
GB_Module( ${GN_tests_target}
    Modules         ${modules}
    Libs            gtest gtest_main
    Definitions     "-Dall_load"
    Mode            "app"
    bFlat           off)

# create a ctest
add_test(
    NAME    ${GN_tests_test} 
    COMMAND ${GN_tests_target})
gtest_discover_tests(${GN_tests_target})

# move to specified filter
foreach(target gtest gtest_main ${GN_tests_target})
    set_target_properties(${target} PROPERTIES FOLDER ${GN_tests_filter})
    endforeach()

# enable initialisation of static variable inside static libraries...
foreach(module ${modules})
    SET_TARGET_PROPERTIES(${GN_tests_target} PROPERTIES LINK_FLAGS_DEBUG "/WHOLEARCHIVE:${module}")
    endforeach()
