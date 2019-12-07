macro(GN_flags_append target build_type)
    get_target_property(target_type ${target} TYPE)
    if (NOT ${target_type} STREQUAL "UTILITY")
        foreach(value ${ARGN})
            target_compile_options(${target} PRIVATE "$<$<CONFIG:${build_type}>:${value}>")
            endforeach()
        endif()
	endmacro()

macro(GN_flags_configure unit)
    set(target ${${unit}_target})

    if(MSVC)
        # enable filters
        set_property(GLOBAL PROPERTY USE_FOLDERS ON)
        # Use static/dynamic runtime
        if (GN_cpp_static)
            GN_flags_append(${target} Release "/MT" )
            GN_flags_append(${target} Debug   "/MTd")
        else()
            GN_flags_append(${target} Release "/MD" )
            GN_flags_append(${target} Debug   "/MDd")
            endif()
        GN_flags_append(${target} Release "/MP" "/Z7")
        GN_flags_append(${target} Debug   "/MP" "/Ot")
    else()
        # TODO: linux
        GN_error("unsupported compiler")
        endif()

    set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/install)
    endmacro()
