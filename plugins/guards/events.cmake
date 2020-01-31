
function(event event unit)
    if ("${event}" STREQUAL "preGenerate")
        GN_guards(${unit})
        endif()
    endfunction()
