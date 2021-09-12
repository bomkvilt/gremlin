
function(event event unit)
    if ("${event}" STREQUAL "unit_constructMetadata")
        GN_definitions_onConstruct(${unit})
        endif()
    endfunction()
