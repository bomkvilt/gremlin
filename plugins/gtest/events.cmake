macro(event event)
    if  ("${event}" STREQUAL "construct")
        GN_gtest(${ARGN})
    elseif("${event}" STREQUAL "solution_configure")
        GN_gtest_configure()
    elseif("${event}" STREQUAL "solution_configured")
        add_subdirectory(${GN_gtest_proj})
        endif()
    endmacro()
