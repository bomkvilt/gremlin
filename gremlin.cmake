#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| Gremlin's settings
# common settings
set(GN_bDebug 	        off		        CACHE BOOL "Print unit debug information")
set(GN_bheaders         on              CACHE BOOL "Enable header processing")
set(GN_bProduction      off             CACHE BOOL "Enable productoin build mode")
set(GN_cpp_version 		17		        CACHE STRING "C++ standart")
# directory settings
set(GN_dir_private	    "Private"       CACHE STRING "Unit private directory")
set(GN_dir_public	    "Public"        CACHE STRING "Unit public directory")
set(GN_dir_data		    "Data"	        CACHE STRING "Unit data directory")
set(GN_dir_test		    "Test"	        CACHE STRING "Unit test directory")
set(GN_dir_gremlin      "cmake/gremlin" CACHE STRING "gremlin directory path")
# test settings
set(GN_bTests 	        on		        CACHE BOOL "Enable tests")
set(GN_tests_filter	    "_tests_"       CACHE STRING "Filter name for all test projects")
set(GN_tests_target     "tests_exe"     CACHE STRING "test target")
set(GN_tests_test       "tests_test"    CACHE STRING "test name")
# unity building
set(GN_bUnity           off		        CACHE BOOL "Enable unity building")

include("${GN_dir_gremlin}/GN_misc.cmake")
include("${GN_dir_gremlin}/GN_private.cmake")
include("${GN_dir_gremlin}/GN_headers.cmake")
include("${GN_dir_gremlin}/GN_projects.cmake")
include("${GN_dir_gremlin}/GN_unity_build.cmake")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| Gremlin's API
# solution initialisation
macro(GN_Solutoin name)
    GN_project(${name})
    GN_setup_enviroment()
    endmacro()

macro(GN_Configure)
    GN_setup_tests()
    endmacro()

# submodules
macro(GN_Subprojects)
    foreach(path ${ARGN})
        ADD_SUBDIRECTORY(${path})
        endforeach()
    endmacro()

## creates a unit with the folowing params:
#   \ Name                  - unit name
#   \ Modules       = {}    - list of depending modules             | inherits
#   \ Private       = {}    - list of private external include dirs | 
#   \ Public        = {}    - list of public  external include dirs | inherits
#   \ Libs          = {}    - list of depending external libs       | inherits
#   \ Definitions   = {}    - list of preprocessor defenitions      | inherits
#   \ bFlat         = off   - [on|off] whether the unit uses separated public/private/test directories
#   \ Mode          = lib   - [...] type of unit will be built
#       \ lib       - create a static library
#       \ app       - create an executable
#       \ headers   - create a target with no binary output
function(GB_Module Name)
    # create module
    GN_make_module(this ${Name} ${ARGN})
    GN_debug("\n----------------------------------------------------")
    GN_debug("|${this}::${${this}_Mode}::${${this}_dir_root}|")
    
    # read sources
    GN_read_modules(${this}_modules ${this})
    GN_read_libs   (${this}_libs    ${this})
    GN_read_sources(${this}_src_private ${${this}_dir_private} ${${this}_dir_root} off)
    GN_read_sources(${this}_src_public  ${${this}_dir_public}  ${${this}_dir_root} off)
    GN_read_sources(${this}_src_test    ${${this}_dir_test}    ${${this}_dir_root} on )
    GN_read_sources(${this}_src_data    ${${this}_dir_data}    ${${this}_dir_root} off)
    GN_debug("| public|: \t${${this}_src_public}")
    GN_debug("|private|: \t${${this}_src_private}")
    GN_debug("|  tests|: \t${${this}_src_test}")

    # create targets
    if (${${this}_Mode} STREQUAL "lib")
        add_library(${this}
            ${${this}_src_private} 
            ${${this}_src_public}
            ${${this}_src_test})
        set(${this}_bLink on)
        # link target
        target_link_libraries(${this} ${${this}_libs})
        endif()
    if (${${this}_Mode} STREQUAL "app")
        add_executable(${this} 
            ${${this}_src_private}
            ${${this}_src_public})
        set(${this}_bLink off)
        # link target
        target_link_libraries(${this} ${${this}_libs})
        # set debug directory
        set_target_properties(${Name} PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY ${GN_dir_solution})
        # add dependencies
        foreach(module ${${this}_modules})
            add_dependencies(${this} ${module})
            endforeach()
        endif()
    if (${${this}_Mode} STREQUAL "headers")
        add_custom_target(${this} SOURCES ${${this}_src_public})
        set(${this}_bLink off)
        endif()
    
    # setup unit
    GN_setup_includes(${this})
    GN_setup_defines(${this}_defines ${this})
    GN_setup_filters(${this})
    GN_unity_build(${this})
    GN_define(${this})

    # update include guards
    GN_process_headers("${${this}_src_private};${${this}_src_public};${${this}_src_test}")
    endfunction()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| policies
if (POLICY CMP0074)
    cmake_policy(SET CMP0074 NEW)
    endif()
if (POLICY CMP0079)
    cmake_policy(SET CMP0079 NEW)
    endif()
