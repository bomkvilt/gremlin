
function(event event unit)
    if ("${event}" STREQUAL "unit_processSources")
        GN_guards(${unit})
        endif()
    endfunction()
