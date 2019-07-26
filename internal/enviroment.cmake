## --------------------------| enviroment |-------------------------- ##
## -----------| common

macro(GN_initEnviroment)
    foreach(prefix ${GN_unitPrefix})
        get_cmake_property(variables VARIABLES)
        foreach (variable ${variables})
            if ("${variable}" MATCHES "^${prefix}")
                GN_uncache(${variable})
                endif()
            endforeach()
        endforeach()

    GN_cache(GN_dir_building "${CMAKE_BINARY_DIR}")
    endmacro()

macro(GN_setupEnviroment)
    GN_cache(GN_dir_solution "${PROJECT_SOURCE_DIR}")

    get_filename_component(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${GN_dir_building}/bin" ABSOLUTE CACHE)
    get_filename_component(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${GN_dir_building}/bin" ABSOLUTE CACHE)
    get_filename_component(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${GN_dir_building}/bin" ABSOLUTE CACHE)
    link_directories("${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    endmacro()
