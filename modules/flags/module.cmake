macro(GN_flags_append key)
	foreach(value ${ARGN})
		set(${key} "${${key}} ${value}")
		endforeach()
	endmacro()

macro(GN_flags_configure)
    if(MSVC)
        # enable filters
        set_property(GLOBAL PROPERTY USE_FOLDERS ON)
        # Use static/dynamic runtime
        if (GN_cpp_static)
            GN_flags_append(CMAKE_CXX_FLAGS_RELEASE "/MT" )
            GN_flags_append(CMAKE_CXX_FLAGS_DEBUG   "/MTd")
        else()
            GN_flags_append(CMAKE_CXX_FLAGS_RELEASE "/MD" )
            GN_flags_append(CMAKE_CXX_FLAGS_DEBUG   "/MDd")
            endif()
        GN_flags_append(CMAKE_CXX_FLAGS_RELEASE "/Z7")
        GN_flags_append(CMAKE_CXX_FLAGS_DEBUG   "/Ot")
        GN_flags_append(CMAKE_CXX_FLAGS "/MP")
    else()
        # TODO: linux
        endif()

    set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/install)
    endmacro()
