
macro(event event)
    if    ("${event}" STREQUAL "unit_processTarget")
        GN_tree(${ARGN})
    elseif("${event}" STREQUAL "solution_configure")
        GN_tree_configure()
        endif()
    endmacro()
