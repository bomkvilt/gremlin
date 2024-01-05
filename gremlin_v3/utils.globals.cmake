# ---------------------------| cache located variables

macro(_gn3_set_cache name)
    set(${name} "${ARGN}" CACHE STRING "")
endmacro()

macro(_gn3_set_cache_force name)
    set(${name} "${ARGN}" CACHE STRING "" FORCE)
endmacro()

macro(_gn3_get_cache result name)
    get(${result} ${name} CACHE STRING "")
endmacro()

macro(_gn3_uncache_by_prefixes)
    foreach (prefix ${ARGN})
        get_cmake_property(variables VARIABLES)
        foreach (variable ${variables})
            if ("${variable}" MATCHES "^${prefix}")
                unset(${variable})
                unset(${variable} CACHE)
            endif()
        endforeach()
    endforeach()
endmacro()

# ---------------------------| cache located counters

macro(_gn3_set_option name)
    # NOTE: set cache by default does not override previous value
    _gn3_set_cache(${name} ${ARGN})
endmacro()

# ---------------------------| cache located counters
# TODO: are the counters required?

function(_gn3_cached_counter_new name value)
    _gn3_set_cache_force(${name} "${value}")
endfunction()

function(_gn3_cached_counter_inc name value)
    math(EXPR new "${${name}} + ${value}")
    _gn3_set_cache_force(${name} "${new}")
endfunction()

function(_gn3_cached_counter_dec name value)
    math(EXPR new "${${name}} - ${value}")
    _gn3_set_cache_force(${name} "${new}")
endfunction()
