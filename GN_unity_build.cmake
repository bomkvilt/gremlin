#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| unity building

macro(GN_init_unity)
    # skip unity build
    if (NOT GN_bUnity)
        GN_debug("unity build skipping...")
        return()
        endif()
    
    # download cotire
    GN_Download_project(root "cotire" "${GN_dir_gremlin}/GN_loader_cotire.cmake")
    include("${root}/src/CMake/cotire.cmake")
    endmacro()

function(GN_unity_build this)
    # skip unity build
    if (NOT GN_bUnity)
        GN_debug("unity build skipping...")
        return()
        endif()
    # use cotire for this
    GN_headers(headers "${${this}_src_public};${${this}_src_private}")
    if (";${headers};" STREQUAL ";;")
        set_target_properties(${this} PROPERTIES COTIRE_ENABLE_PRECOMPILED_HEADER FALSE)
        endif()
    cotire(${this})
    endfunction()

function(GN_headers _result files)
    foreach(file ${files})
        GN_last_extention(ext ${file})
        if (${ext} MATCHES ".h|.hpp")
            list(APPEND out ${file})
            endif()
        endforeach()
    GN_return("${out}")
    endfunction()
