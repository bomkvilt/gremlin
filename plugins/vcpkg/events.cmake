
macro(event event)
    if ("${event}" STREQUAL "solution_configure")
        GN_vcpkg()
        endif()
    endmacro()
