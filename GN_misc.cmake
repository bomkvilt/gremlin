#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| common

include(ProcessorCount)


macro(GN_project name)
    project(${name})
    set(CMAKE_CXX_STANDARD ${GN_cpp_version})
    endmacro()

macro(GN_return value)
    set(${_result} "${value}" PARENT_SCOPE)
    endmacro()

macro(GN_processor)
    ProcessorCount(GN_cores)
    if(GN_cores EQUAL 0)
        set(GN_cores 1)
        endif()
    endmacro()

function(GN_get _result name)
    get_property(out GLOBAL PROPERTY ${name})
    GN_return("${out}")
    endfunction()

function(GN_set name value)
    set_property(GLOBAL PROPERTY ${name} ${value})
    endfunction()

function(GN_debug msg)
    if (GN_bDebug)
        message("${msg}")
        endif()
    endfunction()

function(GN_last_extention _result file)
    string(REGEX MATCH ".[^.]*$" _matched "${file}")
    GN_return("${_matched}")
    endfunction()
