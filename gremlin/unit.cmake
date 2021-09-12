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
#   EMode       mode; // buid mode (see below)
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
#   , eTests
# }
# ---------------------------| public interface
GN_option(GN_unitPrefix "GN_U")
GN_option(GN_sourceCodeExtentions ".c" ".cpp")

# >> create a new empty unit
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

# >> parse passed unit's settings and create CMake targets
# \note number of targets might be not equal to 1
macro(GNU_constructUnit unit pluginManager)
    # scan configured directories and fill in file lists for all source types
    # \sa unit."srcTypes", unit."srcFiles.${type}"
    GNP_on(${pluginManager} "unit_modifyArguments"   ${unit})
    GNP_on(${pluginManager} "unit_constructMetadata" ${unit})
    GNU_scanDirs(${unit})

    # create CMake targets
    GNP_on(${pluginManager} "unit_processSources" ${unit})
    GNU_fixIntegrity  (${unit})
    GNU_generateObject(${unit})
    GNP_on(${pluginManager} "unit_processTarget" ${unit})
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
    # remove all variables with the prefix
    GN_clearWithPrefix("__args_")
    # parse variable
    # \note parsed variable start with '__args_'
    cmake_parse_arguments(__args
        "${GN__flags}"
        "${GN__1Val}"
        "${GN__nVal}"
        ${ARGN})
    # iterate throw all the variables
    # \note the variables are taken from list of CMake variables
    get_cmake_property(variables VARIABLES)
    foreach (variable ${variables})
        if ("${variable}" MATCHES "^__args_")
            #   ${variable}  is a name a parsed key with the prefix
            # ${${variable}} is a value the key
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

function(GNU_setArgs unit name)
    GNU_set(${unit} "args.${name}" ${ARGN})
    endfunction()

function(GNU_scanDirs unit)
    GNU_get(typeList ${unit} "srcTypes")
    foreach(type ${typeList})
        set(files)
        GNU_get(dirs ${unit} "srcDirectories.${type}")
        foreach (dir ${dirs})
            if (EXISTS "${dir}" AND IS_DIRECTORY ${dir})
                file(GLOB_RECURSE tmp "${dir}/*")
            elseif(EXISTS "${dir}")
                set(tmp "${dir}")
                endif()
            GN_appendList(files "${files}" ${tmp})
            endforeach()
        GNU_set(${unit} "srcFiles.${type}" ${files})
        endforeach()
    endfunction()

function(GNU_assertMode mode)
    if (("${mode}" STREQUAL "eStatic")
    OR  ("${mode}" STREQUAL "eDynamic")
    OR  ("${mode}" STREQUAL "eApp")
    OR  ("${mode}" STREQUAL "eDependency")
    OR  ("${mode}" STREQUAL "eTests"))
        return()
        endif()
    GN_error("ASSERT" "passed mode '${mode}' is not in list of: ;- eApp;- eStatic;- eDynamic;- eDependency;- eTests")
    endfunction()

function(GNU_genSorceExtsRegex _result)
    # \todo what symbol '$' means?
    list(TRANSFORM GN_sourceCodeExtentions APPEND "$" OUTPUT_VARIABLE exts)
    list(JOIN exts "|" exts)
    string(REPLACE "." "\\." exts ${exts})
    GN_return(${exts})
    endfunction()

function(GNU_isCompilableUnit _result unit)
    GNU_genSorceExtsRegex(re)

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
    ##  we need to cosider a case when a 'library' entity still has no
    #   .c | .cpp source code to be compiled. This case produces compiler's error
    #   that can be avoided with changing of the entity's target type on 'eDependency'
    # \note application types line 'eApp' and 'eTests' must
    #   contain at least one cpp file, so, it's not necessary
    #   to be consider the cases.
    GNU_get(mode ${unit} "mode")
    if ("${mode}" STREQUAL "eStatic"
    OR  "${mode}" STREQUAL "eDynamic")
        GNU_isCompilableUnit(ok ${unit})
        if (NOT ok)
            GNU_set(${unit} "mode" "eDependency")
            endif()
        endif()
    endfunction()

function(GNU_generateObject unit)
    GNU_get(mode ${unit} "mode")
    if     ("${mode}" STREQUAL "eStatic")
        GNU_generate_static_target(${unit})
    elseif ("${mode}" STREQUAL "eDynamic")
        GNU_generate_dynamic_target(${unit})
    elseif ("${mode}" STREQUAL "eApp")
        GNU_generate_app(${unit})
    elseif ("${mode}" STREQUAL "eDependency")
        GNU_generate_dependency_target(${unit})
    elseif ("${mode}" STREQUAL "eTests")
        GNU_generate_test_target(${unit})
        endif()
    GNU_addSourcesToTarget(${unit})
    GNU_addSourcesToProject(${unit})
    GNU_addIncludesToTarget(${unit})
    GNU_addDefinitionsToTarget(${unit})
    GNU_linkLibrariesToTarget(${unit})
    endfunction()

function(GNU_generate_static_target unit)
    add_library(${unit} STATIC)
    endfunction()

function(GNU_generate_dynamic_target unit)
    add_library(${unit} SHARED)
    endfunction()

function(GNU_generate_app unit)
    add_executable(${unit})
    endfunction()

function(GNU_generate_dependency_target unit)
    add_library(${unit} STATIC)
    target_link_libraries(${unit} PRIVATE GN_stub)
    source_group(TREE ${GN_stub_root} FILES ${GN_stub_cpp})
    endfunction()

function(GNU_generate_test_target unit)
    # the function must be overriden with a test module
    # by default we will throw an error
    GN_error("" "GNU_generate_test_target must be overriden with a unit test gremline module to support 'eTests' mode")
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
        set(outdirs "${files}")
        list(FILTER outdirs EXCLUDE REGEX "^${root}")
        list(FILTER files   INCLUDE REGEX "^${root}")
        if (NOT "${outdirs}" STREQUAL "")
            message(" -- ${outdirs}")
            source_group("" FILES "${outdirs}")
            endif()
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
