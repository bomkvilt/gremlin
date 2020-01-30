
function(event event unit)
    if ("${event}" STREQUAL "construct")
        GN_libraries(${unit})
        endif()
    endfunction()
