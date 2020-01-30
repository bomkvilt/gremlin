# ---------------------------| clear cached variables
include(${CMAKE_CURRENT_LIST_DIR}/gremlin/common.cmake)
GN_clearWithPref("GN_" "GNU_" "GNP_")

# ---------------------------| include system components

set(GN_solution_root ${CMAKE_CURRENT_SOURCE_DIR})

foreach(file
    ${CMAKE_CURRENT_LIST_DIR}/gremlin/common.cmake
    ${CMAKE_CURRENT_LIST_DIR}/gremlin/logger.cmake
    ${CMAKE_CURRENT_LIST_DIR}/gremlin/stub.cmake
    ${CMAKE_CURRENT_LIST_DIR}/gremlin/unit.cmake
    ${CMAKE_CURRENT_LIST_DIR}/gremlin/plugins.cmake
)
    include(${file})
    endforeach()

# ---------------------------| interface

GN_option(GN_pluginList 
    ${CMAKE_CURRENT_LIST_DIR}/plugins/source/plugin.cmake
    ${CMAKE_CURRENT_LIST_DIR}/plugins/definitions/plugin.cmake
    ${CMAKE_CURRENT_LIST_DIR}/plugins/units/plugin.cmake
    ${CMAKE_CURRENT_LIST_DIR}/plugins/libraries/plugin.cmake
    ${CMAKE_CURRENT_LIST_DIR}/plugins/projectTree/plugin.cmake
)

## initialises gremlin enviroment
macro(GN_init)
    GNP_new(GN_plugins "plugins")
    foreach(plugin ${GN_pluginList})
        GN_initPlugin(${GN_plugins} ${plugin})
        endforeach()
    endmacro()

## adds subrojects
macro(GN_subprojects)
    foreach(path ${ARGN})
        add_subdirectory(${path})
        endforeach()
    endmacro()

## creates a unit with the folowing params
macro(GN_unit name)
    cmake_parse_arguments(args "" "mode" "" ${ARGN})
    GN_setDefault(args_mode "eStatic")

    GNU_newUnit(unit ${name} ${args_mode} ${ARGN})
    GNU_constructUnit(${unit} ${GN_plugins})
    endmacro()

# ---------------------------| internal

macro(GN_initPlugin pluginManager callback)
    if (EXISTS ${callback})
        include(${callback})
        init(${pluginManager} ${ARGN})
    else()
        GN_error("" "pluging '${callback}' doesn't exist")
        endif()
    endmacro()

set(GN__flags ""     CACHE STRING "" FORCE)
set(GN__1Val  "mode" CACHE STRING "" FORCE)
set(GN__nVal  ""     CACHE STRING "" FORCE)
function(GN_assignFlags)
    set(GN__flags ${GN__flags} ${ARGN} CACHE STRING "" FORCE)
    endfunction()
function(GN_assign1Val)
    set(GN__1Val ${GN__1Val} ${ARGN} CACHE STRING "" FORCE)
    endfunction()
function(GN_assignNVal)
    set(GN__nVal ${GN__nVal} ${ARGN} CACHE STRING "" FORCE)
    endfunction()
