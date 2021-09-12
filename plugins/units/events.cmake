
function(event event unit)
    if ("${event}" STREQUAL "unit_constructMetadata")
        GN_unit_onConstruct(${unit})
        endif()
    endfunction()
