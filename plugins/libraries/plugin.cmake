# ---------------------------| 
GN_option(GN_libraries_root ${CMAKE_CURRENT_LIST_DIR})

function(init pluginManager)
    GNP_bind(${pluginManager} "unit_constructMetadata" ${GN_libraries_root}/events.cmake)
    GN_assignNVal("libs")
    endfunction()

function(GN_libraries unit)
    GNU_getArgs(libs ${unit} "libs" )
    GNU_addSubobjects(${unit} on ${libs})
    endfunction()
