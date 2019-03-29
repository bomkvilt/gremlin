#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| external projects manager

## Downloads a project and places it into s specified foler in a current build directory.
#   \ resilt    - downloaded project root
#   \ name      - project name
#   \ loader    - cmake file will be executed to download the project | @see gremplin/loaders/[...]
function(GN_Download_project _result name loader)
    # working directories
    set(root "${GN_dir_building}/projects/${name}")
    set(down "${root}/download")
    GN_return(${root})

    # downloading
    if (NOT ${name}_Downloaded)
        # copy the loader into a working directory
        configure_file( "${loader}" "${down}/CMakeLists.txt")

        # execute the loader's cmake
        execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" -j${GN_processor} .
            WORKING_DIRECTORY "${down}"
            RESULT_VARIABLE result)
        if (result)
            message(FATAL_ERROR "CMake step for ${name} failed: ${result}")
            endif()

        # execute the loader
        execute_process(COMMAND ${CMAKE_COMMAND} --build -j${GN_processor} .
            RESULT_VARIABLE result
            WORKING_DIRECTORY "${down}")
        if(result) 
            message(FATAL_ERROR "Build step for ${name} failed: ${result}")
            endif()

        # prevent next updates
        set(${name}_Downloaded on CACHE BOOL "")
        endif()
    endfunction()
