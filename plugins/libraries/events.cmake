
function(event event unit)
    if ("${event}" STREQUAL "unit_constructMetadata")
        GN_libraries(${unit})
        endif()
    endfunction()
