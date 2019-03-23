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
    cotire(${this})
    endfunction()
