
function(event event unit)
    if ("${event}" STREQUAL "construct")
        GN_definitions_onConstruct(${unit})
        endif()
    endfunction()
