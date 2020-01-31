
function(event event unit)
    if ("${event}" STREQUAL "construct")
        GN_source_onConstruct(${unit})
        endif()
    endfunction()
