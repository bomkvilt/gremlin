
macro(event event unit)
    if ("${event}" STREQUAL "unit_processTarget")
        GN_flags(${unit})
        endif()
    endmacro()
