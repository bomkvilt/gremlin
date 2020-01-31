# ---------------------------| clear cached variables
include(${CMAKE_CURRENT_LIST_DIR}/gremlin/common.cmake)
GN_clearWithPrefix("GN_" "GNU_" "GNP_")

# ---------------------------| include system components

set(GN_root ${CMAKE_CURRENT_LIST_DIR})
set(GN_build_root ${CMAKE_CURRENT_BINARY_DIR})
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

GN_option(GN_staticRuntime off)
GN_option(GN_staticLinkage on )


GN_option(GN_pluginList 
    ${CMAKE_CURRENT_LIST_DIR}/plugins/source/plugin.cmake
    ${CMAKE_CURRENT_LIST_DIR}/plugins/definitions/plugin.cmake
    ${CMAKE_CURRENT_LIST_DIR}/plugins/units/plugin.cmake
    ${CMAKE_CURRENT_LIST_DIR}/plugins/libraries/plugin.cmake
    ${CMAKE_CURRENT_LIST_DIR}/plugins/projectTree/plugin.cmake
    ${CMAKE_CURRENT_LIST_DIR}/plugins/vcpkg/plugin.cmake
    ${CMAKE_CURRENT_LIST_DIR}/plugins/gtest/plugin.cmake
    ${CMAKE_CURRENT_LIST_DIR}/plugins/guards/plugin.cmake
)

## initialises gremlin enviroment
# \note: calls earier any project(...) functions
macro(GN_init)
    GN_counterNew(GN__lvl 0)
    GNP_new(GN_plugins "plugins")
    foreach(plugin ${GN_pluginList})
        GN_initPlugin(${GN_plugins} ${plugin})
        endforeach()
    GNP_onGlobal(${GN_plugins} "solution_init")
    endmacro()

## adds subrojects
# \note: must be used for root-lvl subprojects
# \note: for more deep subprojects - optionaly
macro(GN_subprojects)
    GN_cache(GN__inSubprojects on)
    if (${GN__lvl} EQUAL 0)
        GNP_onGlobal(${GN_plugins} "solution_configure")
        endif()
    GN_counterInc(GN__lvl 1)
    foreach(path ${ARGN})
        add_subdirectory(${path})
        endforeach()
    GN_counterDec(GN__lvl 1)
    if (${GN__lvl} EQUAL 0)
        GNP_onGlobal(${GN_plugins} "solution_configured")
        endif()
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
