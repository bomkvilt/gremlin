## --------------------------| helpers |-------------------------- ##
## -----------| common

# project creates a new cmake project
macro(GN_project name)
    project(${name})
    set(CMAKE_CXX_STANDARD ${GN_cpp_version})
    endmacro()

# return returns the value from a function to a '_result'
# NOTE: '_result' containse a name of a parent scope's variable
macro(GN_return value)
    set(${_result} "${value}" PARENT_SCOPE)
    return()
    endmacro()

# default sets a 'value' to _result if it's not presented
function(GN_default _result value)
    if ("${${_result}}" STREQUAL "")
        GN_return("${value}")
        endif()
    endfunction()

## -----------| cache

## option defines a cached optoin variable
function(GN_option name)
    GN_cache_internal(${name} ${ARGN})
    endfunction()

# cache stores the value to a cache
function(GN_cache name)
    if (${ARGC} EQUAL 1)
        set(ARGN ${${name}})
        endif()
    GN_cache_internal(${name} ${ARGN})
    endfunction()

function(GN_cache_internal name)
    set(type "STRING")
    if (${ARGC} EQUAL 2)
        list(GET ARGN 0 value)
        if (${value} MATCHES "on|off|true|false")
            set(type "BOOL")
            endif()
        endif()

    set(${name} ${ARGN} CACHE ${type} "" FORCE)
    endfunction()

# uncache removes the value from a cache
function(GN_uncache name)
    unset(${name} CACHE)
    endfunction()

# append appends a ARGN to the cached variable
function(GN_append name)
    set(group $CACHE{${name}})
    list(APPEND group ${ARGN})
    GN_cache(${name} ${group})
    endfunction()

# unique makes the cached list unique
function(GN_unique name)
    list(LENGTH ${name} len)
    if (${len} LESS 2)
        return()
        endif()
        
    set(group $CACHE{${name}})
    list(REMOVE_DUPLICATES group)
    GN_cache(${name} ${group})
    endfunction()
