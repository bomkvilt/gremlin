# ---------------------------| 
GN_option(GN_flags_root ${CMAKE_CURRENT_LIST_DIR})
GN_option(GN_cppVersion 17)

macro(init pluginManager)
    GNP_bind(${pluginManager} "postGenerate" ${GN_flags_root}/events.cmake)
    endmacro()

macro(GN_flags unit)
    if(MSVC)
        if (GN_staticRuntime)
            GN_flags_append(${unit} Release "/MT" )
            GN_flags_append(${unit} Debug   "/MTd")
        else()
            GN_flags_append(${unit} Release "/MD" )
            GN_flags_append(${unit} Debug   "/MDd")
            endif()
        GN_flags_append(${unit} Release "/MP" "/Z7")
        GN_flags_append(${unit} Debug   "/MP" "/Ot")
    else()
        # \todo: linux
        GN_error("unsupported compiler")
        endif()
    set_target_properties(${unit} PROPERTIES
        CXX_STANDARD ${GN_cppVersion}
        )
    endmacro()

# ---------------------------|

macro(GN_flags_append unit build_type)
    get_target_property(unit_type ${unit} TYPE)
    if (NOT ${unit_type} STREQUAL "UTILITY")
        foreach(value ${ARGN})
            target_compile_options(${unit} PRIVATE "$<$<CONFIG:${build_type}>:${value}>")
            endforeach()
        endif()
    endmacro()

macro(GN_flags_appendAll unit)
    get_target_property(unit_type ${unit} TYPE)
    if (NOT ${unit_type} STREQUAL "UTILITY")
        foreach(value ${ARGN})
            target_compile_options(${unit} PRIVATE "${value}")
            endforeach()
        endif()
    endmacro()
