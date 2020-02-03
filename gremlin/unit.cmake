## class Unit
# def. unit - intermediate representation of assembly units (eg. Lib, Executable, ...)
# 
# \note:
# - unit can be build as only 'application' or 'library' at once
# - in case if library the foolowing types of libraries can be built:
#   - static library (type=eStatic)
#   - dynamic library (type=eDynamic)
#   - dependency library (type=eDependency) // header-only units or units with with connected thrd-party libraries
# - static and dynamic libraries cannot be build simultaneously
# - default code library (static | dynamic) mode could setted up with use of global option
# - 'dependency library' mode enables by default if no code is assigned into the unit (whanted mode independently)
#
# Unit structure: (c++/go like pseudocode)
# class CUnit {
#   EMode       mode; // buid mode (see above)
#   std::string name; // project name
#   
#   std::vector<string> subunits_1;     // list of units are includded the unit inside (public)
#   std::vector<string> subunits_0;     // list of units are includded the unit inside (private)
#   std::vector<string> subobjects_1;   // list of cmake must be linked into the unit (public)
#   std::vector<string> subobjects_0;   // list of cmake must be linked into the unit (private)
#   std::vector<string> definitions_1;  // list of definitions must be applied to the unit (public)
#   std::vector<string> definitions_0;  // list of definitions must be applied to the unit (private)
#
#   std::vector<std::string> srcTypes;      // list of src types must be included into a project
#   std::vector<std::string> publicTypes;   // list of exporting source types
#   std::vector<std::string> privateTypes;  // list of non-exporting source types
#   std::map<std::string, std::vector<std::string>> srcDirectories; // list of sourse directories per src type
#   std::map<std::string, std::vector<std::string>> srcFiles;       // list of source files per src type
# }
# 
# enum EMode {
#     eStatic = 1 << iota
#   , eDynamic
#   , eApp
#   , eDependency
# }
# ---------------------------| public interface
GN_option(GN_unitPrefix "GN_U")
GN_option(GN_codeExts   ".c" ".cpp")


function(GNU_newUnit _result name mode)
    project(${name})
    GNU_assertMode(${mode})
    GNU_registerUnit(${name})
    GNU_set(${name} "name" ${name})
    GNU_set(${name} "mode" ${mode})
    GNU_set(${name} "root" ${CMAKE_CURRENT_SOURCE_DIR})
    GNU_set(${name} "args" ${ARGN})
    GNU_parseArgs(${name} ${ARGN})
    GN_return(${name})
    endfunction()

macro(GNU_constructUnit unit pluginManager)
    GNP_on(${pluginManager} "construct" ${unit})
    GNU_scanDirs(${unit})

    GNP_on(${pluginManager} "preGenerate" ${unit})
    GNU_fixIntegrity  (${unit})
    GNU_generateObject(${unit})

    GNP_on(${pluginManager} "postGenerate" ${unit})
    endmacro()

# ---------------------------| plugin inteface

function(GNU_addSrcType unit type bPublic)
    GN_assertScalar(${type})
    GNU_assertTypeDefined(${unit} ${type} off)
    GNU_appendUnique(${unit} "srcTypes" ${type})
    if (bPublic)
        GNU_appendUnique(${unit} "publicTypes" ${type})
    else()
        GNU_appendUnique(${unit} "privateTypes" ${type})
        endif()
    endfunction()

function(GNU_isTypeDefined _result unit type)
    GN_assertScalar(${type})
    GNU_get(types ${unit} "srcTypes")
    list(FIND types ${type} idx)
    if (idx EQUAL -1)
        GN_return(off)
        endif()
    GN_return(on)
    endfunction()

function(GNU_assertTypeDefined unit type bMust)
    GNU_isTypeDefined(ok ${unit} ${type})
    if (NOT "${ok}" STREQUAL "${bMust}")
        if (bMust)
            set(cond "undefined")
        else()
            set(cond "defined")
            endif()
        GN_error("ASSERT" "type '${type}' is ${cond} in '${unit}'")
        endif()
    endfunction()

function(GNU_addSrcDirs unit type)
    GN_assertScalar(${type})
    if ("${ARGN}" STREQUAL "")
        return()
        endif()
    GNU_assertTypeDefined(${unit} ${type} on)
    GNU_appendUnique(${unit} "srcDirectories.${type}" ${ARGN})
    endfunction()

function(GNU_addSubunits unit bPublic)
    if (bPublic)
        GNU_appendUnique(${unit} "subunits_1" ${ARGN})
    else()
        GNU_appendUnique(${unit} "subunits_0" ${ARGN})
        endif()
    endfunction()

function(GNU_addSubobjects unit bPublic)
    if (bPublic)
        GNU_appendUnique(${unit} "subobjects_1" ${ARGN})
    else()
        GNU_appendUnique(${unit} "subobjects_0" ${ARGN})
        endif()
    endfunction()

function(GNU_addDefinitions unit bPublic)
    if (bPublic)
        GNU_appendUnique(${unit} "definitions_1" ${ARGN})
    else()
        GNU_appendUnique(${unit} "definitions_0" ${ARGN})
        endif()
    endfunction()

# ---------------------------| getters and setters

function(GNU_get _result unit name)
    get_property(tmp GLOBAL PROPERTY "_GNU_${unit}.${name}")
    if ("${tmp}" STREQUAL "NOTFOUND")
        set (tmp NULL)
        endif()
    GN_return(${tmp})
    endfunction()

function(GNU_set unit name)
    set_property(GLOBAL PROPERTY "_GNU_${unit}.${name}" "${ARGN}")
    endfunction()

function(GNU_append unit name)
    GNU_get(tmp ${unit} ${name})
    GN_appendList(tmp "${tmp}" ${ARGN})
    GNU_set(${unit} ${name} ${tmp})
    endfunction()

function(GNU_appendUnique unit name)
    GNU_get(tmp ${unit} ${name})
    GN_appendListUnique(tmp "${tmp}" ${ARGN})
    GNU_set(${unit} ${name} ${tmp})
    endfunction()

# ---------------------------| entery

function(GNU_registerUnit unit)
    set_property(GLOBAL PROPERTY "_GNU_${unit}" on)
    endfunction()

function(GNU_assertUnit unit)
    get_property(tmp GLOBAL PROPERTY "_GNU_${unit}")
    if ("${tmp}" MATCHES "^NOTFOUND$|^$")
        GN_error("" "unit '${unit}' doesn't exist")
        endif()
    endfunction()

function(GNU_parseArgs unit)
    GN_clearWithPrefix("__args_")
    cmake_parse_arguments(__args
        "${GN__flags}"
        "${GN__1Val}"
        "${GN__nVal}"
        ${ARGN})
    get_cmake_property(variables VARIABLES)
    foreach (variable ${variables})
        if ("${variable}" MATCHES "^__args_")
            string(REGEX REPLACE "^__args_" "" key ${variable})
            set(value ${${variable}})
            GNU_set(${unit} "args.${key}" ${value})
            endif()
        endforeach()
    endfunction()

function(GNU_getArgs _result unit name)
    GNU_get(tmp ${unit} "args.${name}")
    GN_return(${tmp})
    endfunction()

function(GNU_scanDirs unit)
    GNU_get(typeList ${unit} "srcTypes")
    foreach(type ${typeList})
        set(files)
        GNU_get(dirs ${unit} "srcDirectories.${type}")
        foreach (dir ${dirs})
            file(GLOB_RECURSE tmp "${dir}/*")
            GN_appendList(files "${files}" ${tmp})
            endforeach()
        GNU_set(${unit} "srcFiles.${type}" ${files})
        endforeach()
    endfunction()

function(GNU_assertMode mode)
    if (("${mode}" STREQUAL "eStatic")
    OR  ("${mode}" STREQUAL "eDynamic")
    OR  ("${mode}" STREQUAL "eApp")
    OR  ("${mode}" STREQUAL "eDependency"))
        return()
        endif()
    GN_error("ASSERT" "passed mode '${mode}' is not in list of: ;- eApp;- eStatic;- eDynamic;- eDependency")
    endfunction()

function(GNU_genCodeExtRE _result)
    list(TRANSFORM GN_codeExts APPEND "$" OUTPUT_VARIABLE exts)
    list(JOIN exts "|" exts)
    string(REPLACE "." "\\." exts ${exts})
    GN_return(${exts})
    endfunction()

function(GNU_isCodeUnit _result unit)
    GNU_genCodeExtRE(re)
    GNU_get(types ${unit} "srcTypes")
    foreach(type  ${types})
        GNU_get(files ${unit} "srcFiles.${type}")
        foreach(file ${files})
            if (file MATCHES "${re}")
                GN_return(on)
                endif()
            endforeach()
        endforeach()
    GN_return(off)
    endfunction()

function(GNU_fixIntegrity unit)
    GNU_get(mode ${unit} "mode")
    if ("${mode}" STREQUAL "eDependency"
    OR  "${mode}" STREQUAL "eApp")
        return()
        endif()
    GNU_isCodeUnit(ok ${unit})
    if (NOT ok)
        GNU_set(${unit} "mode" "eDependency")
        endif()
    endfunction()

function(GNU_generateObject unit)
    GNU_get(mode ${unit} "mode")
    if     ("${mode}" STREQUAL "eStatic")
        GNU_generate_stat(${unit})
    elseif ("${mode}" STREQUAL "eDynamic")
        GNU_generate_dyn(${unit})
    elseif ("${mode}" STREQUAL "eApp")
        GNU_generate_app(${unit})
    elseif ("${mode}" STREQUAL "eDependency")
        GNU_generate_dep(${unit})
        endif()
    GNU_addSourcesToTarget(${unit})
    GNU_addSourcesToProject(${unit})
    GNU_addIncludesToTarget(${unit})
    GNU_addDefinitionsToTarget(${unit})
    GNU_linkLibrariesToTarget(${unit})
    endfunction()

function(GNU_generate_stat unit)
    add_library(${unit} STATIC)
    endfunction()

function(GNU_generate_dyn unit)
    add_library(${unit} SHARED)
    endfunction()

function(GNU_generate_app unit)
    add_executable(${unit})
    endfunction()

function(GNU_generate_dep unit)
    add_library(${unit} STATIC)
    target_link_libraries(${unit} PRIVATE GN_stub)
    source_group(TREE ${GN_stub_root} FILES ${GN_stub_cpp})
    endfunction()

function(GNU_addSourcesToTarget unit)
    GNU_get(mode ${unit} "mode")
    if ("${mode}" STREQUAL "eDependency")
        GNU_get(types ${unit} "publicTypes")
        foreach(type ${types})
            GNU_get(files ${unit} "srcFiles.${type}")
            target_sources(${unit} PRIVATE ${files})
            endforeach()
    else()
        GNU_get(types ${unit} "srcTypes")
        foreach(type  ${types})
            GNU_get(files ${unit} "srcFiles.${type}")
            target_sources(${unit} PRIVATE ${files})
            endforeach()
        endif()
    endfunction()

function(GNU_addSourcesToProject unit)
    GNU_get(root  ${unit} "root")
    GNU_get(types ${unit} "srcTypes")
    foreach(type  ${types})
        GNU_get(files ${unit} "srcFiles.${type}")
        source_group(TREE ${root} FILES ${files})
        endforeach()
    endfunction()

function(GNU_addIncludesToTarget unit)
    if ("${mode}" STREQUAL "eDependency")
        GNU_get(types ${unit} "publicTypes")
        foreach(type ${types})
            GNU_get(paths ${unit} "srcDirectories.${type}")
            target_include_directories(${unit} PUBLIC "${paths}")
            endforeach()
    else()
        GNU_get(types ${unit} "privateTypes")
        foreach(type  ${types})
            GNU_get(paths ${unit} "srcDirectories.${type}")
            target_include_directories(${unit} PRIVATE "${paths}")
            endforeach()
        GNU_get(types ${unit} "publicTypes")
        foreach(type ${types})
            GNU_get(paths ${unit} "srcDirectories.${type}")
            target_include_directories(${unit} PUBLIC "${paths}")
            endforeach()
        endif()
    endfunction()

function(GNU_addDefinitionsToTarget unit)
    GNU_get(defs_pub ${unit} "definitions_1")
    GNU_get(defs_prv ${unit} "definitions_0")
    target_compile_definitions(${unit} 
        PUBLIC  ${defs_pub}
        PRIVATE ${defs_prv}
    )
    endfunction()

function(GNU_linkLibrariesToTarget unit)
    GNU_get(units   ${unit} "subunits_1")
    GNU_get(objects ${unit} "subobjects_1")
    target_link_libraries(${unit} PUBLIC ${units} ${objects})

    GNU_get(units   ${unit} "subunits_0")
    GNU_get(objects ${unit} "subobjects_0")
    target_link_libraries(${unit} PRIVATE ${units} ${objects})
    endfunction()
