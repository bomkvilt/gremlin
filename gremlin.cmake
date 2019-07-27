cmake_minimum_required(VERSION 3.15)

## --------------------------| variables |-------------------------- ##
## -----------| common settings
set(GN_bDebug       off             CACHE BOOL "print debug information")
set(GN_cpp_version  17              CACHE BOOL "c++ standart")
set(GN_cpp_static   on              CACHE BOOL "use static c runtime")
## -----------| directories
set(GN_dir_private  "private"       CACHE STRING "private code directory")
set(GN_dir_public   "public"        CACHE STRING "public code directory")
## -----------| enabled modules
set(GN_modules_avaliable "vcpkg" "test" "guards")
set(GN_modules_enabled   "vcpkg" "test" "guards")


# include internal functions
set(GN_dir_gremlin "${CMAKE_CURRENT_LIST_DIR}" CACHE STRING "" FORCE)
include("${GN_dir_gremlin}/internal/log.cmake")
include("${GN_dir_gremlin}/internal/enviroment.cmake")
include("${GN_dir_gremlin}/internal/helpers.cmake")
include("${GN_dir_gremlin}/internal/modules.cmake")
include("${GN_dir_gremlin}/internal/unit.cmake")

# include enabled modules
foreach(module ${GN_modules_enabled})
    include("${GN_dir_gremlin}/modules/${module}/module.cmake")
    endforeach()


## --------------------------| interface |-------------------------- ##
macro(GN_Init)
    GN_initEnviroment()
    GN_callEvent("onInit")
    GN_cache(GN_lvl 0)
    endmacro()

macro(GN_Subprojects)
    if (${GN_lvl} EQUAL 0)
        GN_setupEnviroment()
        GN_callEvent("onConf")
        endif()

    math(EXPR lvl "${GN_lvl} + 1")
    GN_cache(GN_lvl ${lvl})
    foreach(path ${ARGN})
        add_subdirectory(${path})
        endforeach()
    math(EXPR lvl "${GN_lvl} - 1")
    GN_cache(GN_lvl ${lvl})

    if (${GN_lvl} EQUAL 0)
        GN_callEvent("onDone")
        endif()
    endmacro()

## creates a unit with the folowing params:
#   \ Name                  - unit name
#   \ Units         = {}    - list of depending units               | inherits
#   \ Private       = {}    - list of private external include dirs | 
#   \ Public        = {}    - list of public  external include dirs | inherits
#   \ Libs          = {}    - list of depending external libs       | inherits
#   \ Definitions   = {}    - list of preprocessor defenitions      | inherits
#   \ bFlat         = off   - [on|off] whether the unit uses separated public/private/test directories
#   \ Mode          = lib   - [...] type of unit will be built
#       \ lib       - create a static library
#       \ app       - create an executable
function(GN_Unit Name)
    set(OPTIONS "bFlat")
    set(VALUES  "Mode" )
    set(ARRAYS  "Units;Private;Public;Libs;Definitions")
    cmake_parse_arguments(args
        "${OPTIONS}" 
        "${VALUES}"
        "${ARRAYS}" ${ARGN})
    GN_default(args_Mode  "lib")

    GN_newUnit(unit ${Name} ${args_bFlat})
    GNU_setProperties(${unit}
        MODE ${args_Mode}
        PUBL ${args_Public}
        PRIV ${args_Private}
        LIBS ${args_Libs}
        DEFS ${args_Definitions}
    )
    GNU_setSubunits(${unit} ${args_Units})
    GNU_parseSrc(${unit})
    
    GN_callEvent("onSetup" ${unit})
    GNU_parseSrc (${unit})
    GNU_configure(${unit})

    GN_debugHeader("${Name}")
    GN_debug("mode"             "${${unit}_mode}")
    GN_debug("root"             "${${unit}_dirs_root}")
    GN_debug("units"            "${${unit}_units}")
    GN_debug("dirs.public"      "${${unit}_dirs_public}")
    GN_debug("dirs.private"     "${${unit}_dirs_private}")
    GN_debug("files.public"     "${${unit}_srcs_public}")
    GN_debug("files.private"    "${${unit}_srcs_private}")
    GN_debug("libs"             "${${unit}_libs}" 2)
    GN_debug("defs"             "${${unit}_defs}")

    GNU_generateTarget(${unit})
    GN_callEvent("onGen" ${unit})
    GNU_done(${unit})
    endfunction()
