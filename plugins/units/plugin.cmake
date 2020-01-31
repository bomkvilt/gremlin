# ---------------------------| 
GN_option(GN_unit_root ${CMAKE_CURRENT_LIST_DIR})

function(init pluginManager)
    GNP_bind(${pluginManager} "construct" ${GN_unit_root}/events.cmake)
    GN_assignNVal("units")
    endfunction()

function(GN_unit_onConstruct unit)
    GNU_getArgs(units  ${unit} "units" )
    foreach(subUnit ${units})
        GNU_assertUnit(${subUnit})
        endforeach()
    GNU_addSubunits(${unit} on ${units})
    endfunction()
