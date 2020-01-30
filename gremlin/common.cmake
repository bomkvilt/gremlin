# ---------------------------| global variables

macro(GN_option name)
    set(${name} "${ARGN}" CACHE STRING "")
    endmacro()

macro(GN_clearWithPref)
    foreach(prefix ${ARGN})
        get_cmake_property(variables VARIABLES)
        foreach (variable ${variables})
            if ("${variable}" MATCHES "^${prefix}")
                unset(${variable})
                unset(${variable} CACHE)
                endif()
            endforeach()
        endforeach()
    endmacro()

# ---------------------------| functions

macro(GN_return)
    set(${_result} "${ARGN}" PARENT_SCOPE)
    return()
    endmacro()

# ---------------------------| variables/lists

function(GN_appendList _result list)
    if ("${list}" EQUAL NULL)
        return(${ARGN})
        endif()
    list(APPEND list ${ARGN})
    GN_return(${list})
    endfunction()

function(GN_appendListUnique _result list)
    GN_appendList(tmp "${list}" ${ARGN})
    list(REMOVE_DUPLICATES tmp)
    GN_return(${tmp})
    endfunction()

function(GN_setDefault _result value)
    if ("${${_result}}" STREQUAL "" OR  
        "${${_result}}" STREQUAL "NULL"
    )
        GN_return("${value}")
        endif()
    endfunction()

function(GN_assertScalar)
    list(LENGTH "${ARGN}" len)
    if (len GREATER 1)
        GN_error("ASSERT" "passed value is not a scalar (${len}): '${ARGN}'")
        endif()
    endfunction()
