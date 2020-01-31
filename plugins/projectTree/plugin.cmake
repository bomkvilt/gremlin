# ---------------------------| 
GN_option(GN_tree_root ${CMAKE_CURRENT_LIST_DIR})


function(init pluginManager)
    GNP_bind(${pluginManager} "postGenerate" ${GN_tree_root}/events.cmake)
    GNP_bind(${pluginManager} "solution_configure" ${GN_tree_root}/events.cmake)
    endfunction()

macro(GN_tree_configure)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set_property(GLOBAL PROPERTY USE_FOLDERS ON)
        endif()
    endmacro()

function(GN_tree unit)
    GNU_get(root ${unit} "root")
    file(RELATIVE_PATH category "${GN_solution_root}" "${root}/..")
    set_target_properties(${unit} PROPERTIES FOLDER "${category}")
    endfunction()
