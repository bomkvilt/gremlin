#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| external projects manager

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
        execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
            WORKING_DIRECTORY "${down}"
            RESULT_VARIABLE result)
        if (result)
            message(FATAL_ERROR "CMake step for ${name} failed: ${result}")
            endif()

        # execute the loader
        execute_process(COMMAND ${CMAKE_COMMAND} --build .
            RESULT_VARIABLE result
            WORKING_DIRECTORY "${down}")
        if(result) 
            message(FATAL_ERROR "Build step for ${name} failed: ${result}")
            endif()

        # prevent next updates
        set(${name}_Downloaded on CACHE BOOL "")
        endif()
    endfunction()
