
function(event event unit)
    if ("${event}" STREQUAL "postGenerate")
        GN_tree(${unit})
        endif()
    endfunction()
