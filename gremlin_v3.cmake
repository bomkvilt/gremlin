# ---------------------------
# include main code

include(${CMAKE_CURRENT_LIST_DIR}/gremlin_v3/utils.globals.cmake)

# NOTE: options are realised using cmake cache mechaism
_gn3_uncache_by_prefixes("gn3_" "_gn3_" "__gn3_")

_gn3_set_cache_force(_gn3_src_root "${CMAKE_CURRENT_LIST_DIR}")

# NOTE: macro is used to avoid new contexts generation
# NOTE: muste be called after all `gn3_option(<name> <value> ...)`
macro(gn3_init)
    foreach(file
        ${_gn3_src_root}/gremlin_v3/target.link_binary.cmake
        ${_gn3_src_root}/gremlin_v3/target.tests.cmake
        ${_gn3_src_root}/gremlin_v3/target.project_tree.cmake
    )
        include(${file})
    endforeach()
endmacro()


# ---------------------------
# re-export public methods

macro(gn3_option name)
    _gn3_set_option(${name} ${ARGN})
endmacro()
