## --------------------------| unit |-------------------------- ##
# unit is a c++ asembly unit
# can be represented like the structure
#
# unit* GetUnit(string name) {
#   static auto units = map<string, unit*> units;
#   return units[name]
# };
#
# class unit {
#   string name;                        // name of the unit
#   string mode;                        // mode of the unit = [lib, app, heads]
#   vector<string> units;               // list of depended units
#   vector<string> libs;                // list of assigned libraries
#   vector<string> defs;                // list of assigned definitions
#   map<string, vector<string>> dirs;   // map of assigned directories
#   map<string, vector<string>> srcs;   // map of project's source files
# };
#
## -----------| constructor

GN_cache(GN_unitPrefix "GN_U")

## newUnit creates a new unit
macro(GN_newUnit _result name bFlat)
    set(unit "${GN_unitPrefix}${name}")
    GN_project(${name})
    
    GN_cache(${unit}_name  ${name} )
    GN_cache(${unit}_bFlat ${bFlat})

    GNU_addDir(${unit} "root" "${PROJECT_SOURCE_DIR}")
    GNU_addLocalDir(${unit} "local.public"  "${GN_dir_public}")
    GNU_addLocalDir(${unit} "local.private" "${GN_dir_private}")
    GNU_addDir(${unit} "project" "local.public"  "local.private")       # will be used as target's srcs
    GNU_addDir(${unit} "public"  "local.public"  "external.public")     # will be used as include [ide and units]
    GNU_addDir(${unit} "private" "local.private" "external.private")    # will be used as include [ide]

    GNU_getDir(root ${unit} "root")
    file(RELATIVE_PATH category "${GN_dir_solution}" "${root}/..")
    GN_cache(${unit}_category ${category})

    set(${_result} ${unit})
    endmacro()

## -----------| free functions

function(GN_getUnit _result name)
    set(unit ${GN_unitPrefix}${name})
    if ("${${unit}_name}" STREQUAL "")
        GN_error("unit '${name}' doesn't exist")
        endif()
    GN_return(${unit})
    endfunction()

## -----------| interface

## addSubunits add the units as dependet
function(GNU_addSubunits unit)
    set(subunits ${ARGN})

    GN_append(${unit}_units ${subunits})

    foreach(subunitName ${subunits})
        GN_getUnit(subunit ${subunitName})
        GN_append(${unit}_units ${${subunit}_units})
        GN_append(${unit}_libs  ${${subunit}_Libs} )
        GN_append(${unit}_defs  ${${subunit}_Defs} )
        # TODO:: public directories
        endforeach()
    GN_unique(${unit}_units)
    GN_unique(${unit}_defs )
    endfunction()

## addProperties adds the following properties
#   - MODE  -   target type [app, lib]
#   - PUBL  -   list of public  include directories
#   - PRIV  -   list of private include directories
#   - LIBS  -   list of libraries
#   - DEFS  -   list of definitions
function(GNU_addProperties unit)
    set(ARRAYS "PUBL" "PRIV" "LIBS" "DEFS")
    cmake_parse_arguments(args "" "MODE" "${ARRAYS}" ${ARGN})
    
    if (NOT args_MODE MATCHES "^app$|^lib$")
        GN_error("unsupported unit mode '${args_MODE}'")
        endif()
    GN_cache(${unit}_Mode ${args_MODE})

    GNU_addDir(${unit} "external.public"  ${args_PUBL})
    GNU_addDir(${unit} "external.private" ${args_PRIV})
    GN_append (${unit}_Libs ${args_LIBS}) # self
    GN_append (${unit}_libs ${args_LIBS}) # all
    GN_append (${unit}_Defs ${args_DEFS}) # self 
    GN_append (${unit}_defs ${args_DEFS}) # all
    GN_unique (${unit}_Defs)
    GN_unique (${unit}_defs)
    endfunction()

## parseSrc generate lists of assigned sources:
#   - project   - srcs will be compiled
function(GNU_parseSrc unit)
    GNU_setSrc(${unit} "project")
    GNU_getDir(dirs ${unit} "project")
    foreach(dir ${dirs})
        GNU_getSrcFrom(files ${unit} ${dir})
        GNU_addSrc(${unit} "project" ${files})
        endforeach()
    endfunction()

# getSrcFrom returns list of files from assigned directory
# NOTE: group is a name of set of paths
function(GNU_getSrcFrom _result unit group)
    GNU_getDir(paths ${unit} "${group}")
    foreach(path ${paths})
        file(GLOB_RECURSE files "${path}/*")
        GN_return("${files}")
        endforeach()
    endfunction()

## configure configure the unit to be used as a target
function(GNU_configure unit)
    set(mode ${${unit}_Mode})
    if (mode STREQUAL "lib")
        GNU_getSrc(probe ${unit} "project")
        list(FILTER probe INCLUDE REGEX "\.cpp$|\.c$")
        list(LENGTH probe len)
        if (${unit}_bFlat OR ${len} EQUAL 0)
            set(mode "head")
            endif()
        endif()
    GN_cache(${unit}_mode ${mode})
    endfunction()

# generateTarget generates a cmake target
function(GNU_generateTarget unit)
    set(mode ${${unit}_mode})

    set(target ${${unit}_name})
    if     (${mode} STREQUAL "lib")
        GNU_generateLib(${unit} ${target})
    elseif (${mode} STREQUAL "app")
        GNU_generateApp(${unit} ${target})
    elseif (${mode} STREQUAL "head")
        GNU_generateHead(${unit} ${target})
    else()
        GN_error("unsupported unit mode '${args_MODE}'")
        endif()
    
    set_target_properties(${target} PROPERTIES FOLDER ${${unit}_category})

    GN_cache(${unit}_target ${target})
    endfunction()

# done configure the unit
function(GNU_done unit)
    set(target ${${unit}_target})
    if ("${target}" STREQUAL "")
        GN_error("no target is set")
        endif()

    GNU_getDir(public  ${unit} "public" )
    GNU_getDir(private ${unit} "private")
    foreach(dir ${public} ${private})
        GNU_getDir(paths ${unit} ${dir})
        include_directories(${paths})
        endforeach()

    GNU_getDir(root  ${unit} "root"   )
    GNU_getSrc(files ${unit} "project")
    source_group(TREE ${root} FILES ${files})

    if (${unit}_bLink)
        GN_append(${unit}_Libs ${target})
        endif()
    endfunction()

## -----------| internal

function(GNU_generateApp unit target)
    GNU_getSrc(files ${unit} "project")
    add_executable(${target} ${files})

    GN_cache(${unit}_bLink off)

    target_link_libraries(${target} ${${unit}_libs})
    set_target_properties(${target} PROPERTIES FOLDER ${${unit}_category})

    foreach(subunitName ${${unit}_units})
        GN_getUnit(subunit ${subunitName})
        add_dependencies(${target} ${${subunit}_target})
        endforeach()
    endfunction()

function(GNU_generateLib unit target)
    GNU_getSrc(files ${unit} "project")
    add_library(${target} ${files})
    
    GN_cache(${unit}_bLink on)
    endfunction()

function(GNU_generateHead unit target)
    GNU_getSrc(files ${unit} "project")
    add_custom_target(${target} SOURCES ${files})

    GN_cache(${unit}_bLink off)
    endfunction()

## -----------| properties

function(GNU_getDir _result unit name)
    GN_return("${${unit}_dirs_${name}}")
    endfunction()

function(GNU_addDir unit name)
    GN_append(${unit}_dirs_${name} ${ARGN})
    endfunction()

function(GNU_setDir unit name)
    GN_cache(${unit}_dirs_${name} ${ARGN})
    endfunction()

function(GNU_addLocalDir unit name path)
    if (${unit}_bFlat)
        set(path "")
        endif()
    GNU_getDir(root ${unit} "root")
    GNU_addDir(${unit} ${name} "${root}/${path}")
    endfunction()

function(GNU_getSrc _result unit name)
    GN_return("${${unit}_srcs_${name}}")
    endfunction()

function(GNU_addSrc unit name)
    GN_append(${unit}_srcs_${name} ${ARGN})
    endfunction()

function(GNU_setSrc unit name)
    GN_cache(${unit}_srcs_${name} ${ARGN})
    endfunction()
