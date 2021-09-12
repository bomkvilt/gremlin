
function(event event unit)
    if ("${event}" STREQUAL "unit_constructMetadata")
        GN_source_onConstruct(${unit})
        endif()
    endfunction()
