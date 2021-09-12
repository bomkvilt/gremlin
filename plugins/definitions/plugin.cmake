# ---------------------------| 
GN_option(GN_definitions_root ${CMAKE_CURRENT_LIST_DIR})


function(init pluginManager)
    GNP_bind(${pluginManager} "unit_constructMetadata" ${GN_definitions_root}/events.cmake)
    GN_assignNVal("defs_public" "defs_private")
    endfunction()

function(GN_definitions_onConstruct unit)
    GNU_getArgs(defs_public  ${unit} "defs_public" )
    GNU_getArgs(defs_private ${unit} "defs_private")
    GNU_addDefinitions(${unit} on  ${defs_public} )
    GNU_addDefinitions(${unit} off ${defs_private})
    endfunction()
