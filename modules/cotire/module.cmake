## --------------------------| cotire |-------------------------- ##
## -----------| setting
GN_option(GN_cotire_root "cotire")
GN_option(GN_cotire_filter "utiles/cotire")

## -----------| events

macro(GN_cotire_init)
    GN_cotire_fixVariables()
    if (NOT GN_cotire_downloaded)
        GN_cotire_download()
        GN_cache(GN_cotire_downloaded on)
        endif()
    
    include(${GN_cotire_root}/CMake/cotire.cmake)    
    endmacro()

function(GN_cotire_add unit)
    GNU_getSrc(probe ${unit} "project")
    list(FILTER probe INCLUDE REGEX "\.cpp$|\.c$")
    list(LENGTH probe lenc)
    
    GNU_getSrc(probe ${unit} "project")
    list(FILTER probe INCLUDE REGEX "\.hpp$|\.h$")
    list(LENGTH probe lenh)
    if (
            ${lenc} GREATER 0
        AND ${lenh} GREATER 0
        AND ${unit}_mode STREQUAL "lib"
    )
        # TODO: determinate why precompiled headers doesn't works
        # NOTE: with MVSC
        # TODO: test cotiire with linux
        set(target ${${unit}_target})
        set_target_properties(${target} PROPERTIES COTIRE_ENABLE_PRECOMPILED_HEADER off)
        
        cotire(${target})
        
        set_target_properties(${target}_unity PROPERTIES FOLDER ${GN_cotire_filter})
        set_target_properties(all_unity       PROPERTIES FOLDER ${GN_cotire_filter})
        set_target_properties(clean_cotire    PROPERTIES FOLDER ${GN_cotire_filter})
        endif()
    endfunction()

## -----------| internal

function(GN_cotire_fixVariables)
    if (NOT IS_ABSOLUTE ${GN_cotire_root})
        GN_cache(GN_cotire_root "${GN_dir_building}/${GN_cotire_root}")
        endif()
    endfunction()

function(GN_cotire_download)
    GN_infoHeader("downloading cotire...")
    GN_info("cotireroot" "${GN_cotire_root}")

    if(NOT EXISTS ${GN_cotire_root}/README.md)
        GN_info("status..." "cloning cotire to ${GN_cotire_root}")
        execute_process(COMMAND git clone https://github.com/sakra/cotire.git ${GN_cotire_root})
        endif()

    if(NOT EXISTS ${GN_cotire_root}/README.md)
        GN_error("cannot clone cotire to ${GN_cotire_root}")
        endif()
    endfunction()
