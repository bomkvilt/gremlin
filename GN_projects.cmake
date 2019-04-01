#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| external projects manager
include(ExternalProject)

macro(GN_loader params)
    set(args ${params})
    # parse input
    list(GET args 0 name)
    list(GET args 1 root)
    list(REMOVE_AT args 0 1)
    message(STATUS "Adding external project '${name}'...")

    # load the project
    ExternalProject_Add("${name}"
        BUILD_COMMAND   "${CMAKE_COMMAND}" --build . --target install -j ${GN_cores} --config Release
              COMMAND   "${CMAKE_COMMAND}" --build . --target install -j ${GN_cores} --config Debug
        INSTALL_COMMAND ""
        CMAKE_ARGS      "${args}"
        ${ARGN}
        )
    # source directory path
    ExternalProject_Get_Property("${name}" SOURCE_DIR)
    message(STATUS "Source directory of ${name} ${SOURCE_DIR}")
    endmacro()


## Downloads a project and places it into s specified foler in a current build directory.
#   \ resilt    - downloaded project root
#   \ name      - project name
#   \ loader    - cmake file will be executed to download the project | @see gremplin/loaders/[...]
function(GN_Download_project _result name loader)
    # working directories
    set(root "${GN_dir_building}/projects/${name}")
    set(down "${root}/download")
    set(done "${root}/__done__")
    GN_return(${root})

    # setting up
    if (NOT EXISTS "${done}")
        # arguments for an internal project
        set(args "${name}" "${root}" 
            -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
            -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
            -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
        # copy the loader into a working directory
        configure_file( "${loader}" "${down}/CMakeLists.txt")
        
        # execute the loader's cmake
        execute_process(COMMAND "${CMAKE_COMMAND}" -G "${CMAKE_GENERATOR}" -j ${GN_cores} .
            WORKING_DIRECTORY "${down}"
            RESULT_VARIABLE result)
        if (result)
            message(FATAL_ERROR "CMake step for ${name} failed: ${result}")
            endif()
        
        # execute the loader
        execute_process(COMMAND "${CMAKE_COMMAND}" --build . -j ${GN_cores}
            WORKING_DIRECTORY "${down}"
            RESULT_VARIABLE result)
        if(result) 
            message(FATAL_ERROR "Build step for ${name} failed: ${result}")
            endif()
        
        # prevent next updates
        file(MAKE_DIRECTORY "${done}")
        endif()
    endfunction()
