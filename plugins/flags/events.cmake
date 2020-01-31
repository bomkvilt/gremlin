
macro(event event unit)
    if ("${event}" STREQUAL "postGenerate")
        GN_flags(${unit})
        endif()
    endmacro()
