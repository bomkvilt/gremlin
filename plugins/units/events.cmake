
function(event event unit)
    if ("${event}" STREQUAL "construct")
        GN_unit_onConstruct(${unit})
        endif()
    endfunction()
