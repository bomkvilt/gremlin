# ---------------------------| 
GN_option(GN_tree_root ${CMAKE_CURRENT_LIST_DIR})

if(MSVC)
    set_property(GLOBAL PROPERTY USE_FOLDERS ON)
    endif()

function(init pluginManager)
    GNP_bind(${pluginManager} "postGenerate" ${GN_tree_root}/events.cmake)
    endfunction()

function(GN_tree unit)
    GNU_get(root ${unit} "root")
    file(RELATIVE_PATH category "${GN_solution_root}" "${root}/..")
    set_target_properties(${unit} PROPERTIES FOLDER "${category}")
    endfunction()
