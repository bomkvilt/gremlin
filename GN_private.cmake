#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

macro(GN_setup_enviroment)
    if (GN_bProduction)
        message(" << prduction mode << on")
        set(GN_bDebug   off	CACHE BOOL "" FORCE)
        set(GN_bTests 	off	CACHE BOOL "" FORCE)
        set(GN_bheaders off CACHE BOOL "" FORCE)
        endif()
    set(GN_dir_building ${CMAKE_CURRENT_BINARY_DIR} CACHE STRING "")
    set(GN_dir_solution ${PROJECT_SOURCE_DIR}       CACHE STRING "")
    GN_init_tests()
    GN_init_unity()
    endmacro()

#~~~~~~~~~~~~~~~~~~~~~~~| constructor

macro(GN_make_module _result name)
    GN_project(${name})
    GN_parse_args(${name} ${ARGN})
    GN_setup_directories(${name})
    set(${_result}       ${name})
    endmacro()

macro(GN_parse_args this)
    cmake_parse_arguments( ${this}
        "" 
        "bFlat;Mode" 
        "Modules;Private;Public;Libs;Definitions"
        ${ARGN})
    if (NOT ${this}_bFlat)
        set(${this}_bFlat off)
        endif()
    if (NOT ${this}_Mode)
        set(${this}_Mode "lib")
        endif()
    endmacro()

macro(GN_setup_directories this)
    set(${this}_dir_root ${PROJECT_SOURCE_DIR})
    if (${this}_bFlat)
        set(${this}_dir_private ".")
        set(${this}_dir_public  ".")
        set(${this}_dir_data    ".")
        set(${this}_dir_test    ".")
    else()
        set(${this}_dir_private ${GN_dir_private})
        set(${this}_dir_public  ${GN_dir_public})
        set(${this}_dir_data    ${GN_dir_data})
        set(${this}_dir_test    ${GN_dir_test})
        endif()
    file(RELATIVE_PATH ${this}_category "${GN_dir_solution}" "${${this}_dir_root}/..")
    endmacro()

#~~~~~~~~~~~~~~~~~~~~~~~| source files

function(GN_read_modules _result this)
    # get all submodules
    set(modules ${${this}_Modules} "")
    foreach(module ${${this}_Modules})
        GN_get(submodules ${module}_modules) # << _modules
        list(APPEND modules ${submodules})
        endforeach()
    list(REMOVE_DUPLICATES modules)
    list(REMOVE_ITEM modules "")
    # print submodules
    GN_debug("|modules|: \t ${modules}")
    # return list of submodules
    GN_return("${modules}")
    endfunction()

function(GN_read_libs _result this)
    # git all libs
    set(libs ${${this}_Libs} "")
    foreach(module ${${this}_modules})
        GN_get(sublibs ${module}_libs) # << _libs
        list(APPEND libs ${sublibs})
        endforeach()
    list(REMOVE_DUPLICATES libs)
    list(REMOVE_ITEM libs "")
    # print sublibs
    GN_debug("|libraries|: \t ${libs}")
    # return list of sublibraries
    GN_return("${libs}")
    endfunction()

function(GN_read_sources _result dir root bTest)
    # if test are disabled
    if ((NOT GN_bTests) AND bTest)
        return()
        endif()

    # add all files from ${dir}
    file(GLOB_RECURSE files "${dir}/*")
    source_group(TREE ${root} FILES ${files})
    # return all found files
    GN_return("${files}")
    endfunction()

#~~~~~~~~~~~~~~~~~~~~~~~| project setup

function(GN_setup_includes this)
    GN_get(test_includes "GN_tests_includes")
    # local unit's includes
    foreach(dir ${${this}_dir_private} ${${this}_dir_public} ${${this}_dir_test} ${${this}_Private} ${${this}_Public} ${GN_tests_includes})
        include_directories(${dir})
        endforeach()
    # includes from submodules
    foreach(module ${${this}_modules})
        GN_get(dirs ${module}_pub) # << _pub
        include_directories(${dirs})
        endforeach()
    endfunction()

function(GN_setup_defines _result this)
    # get all defintitions
    set(defs ${${this}_Definitions} "")
    foreach(module ${${this}_modules})
        GN_get(subdefs ${module}_defines) # << _defines
        list(APPEND defs ${subdefs})
        endforeach()
    list(REMOVE_DUPLICATES defs)
    list(REMOVE_ITEM defs "")
    GN_return("${defs}")

    # add a data directory path
    list(APPEND defs "-DDATA_DIR=${${this}_category}/${${this}_dir_data}")
    # print all unit defs
    GN_debug("|defines|: \t ${defs}")
    # apply defenitions
    add_definitions(${defs})
    endfunction()

function(GN_setup_filters this)
    set_target_properties(${this} PROPERTIES FOLDER "${${this}_category}")
    endfunction()

function(GN_define this)
    # get absolute paths
    get_filename_component(dir_public "${${this}_dir_public}" ABSOLUTE)
    get_filename_component(dir_Public "${${this}_Public}"     ABSOLUTE)

    # define libraly
    if (${this}_bLink)
        # include self to @_libs
        list(APPEND ${this}_libs ${this})
        # register to tests
        GN_get(tests "GN_tests_units")
        list(APPEND tests ${this})
        GN_set("GN_tests_units" "${tests}")
        endif()

    # set global properties
    GN_set(${this}_modules "${${this}_modules}")
    GN_set(${this}_defines "${${this}_defines}")
    GN_set(${this}_libs    "${${this}_libs}")
    GN_set(${this}_pub     "${dir_public};${dir_Public}")
    endfunction()
