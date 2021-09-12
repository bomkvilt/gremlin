# ---------------------------|

GN_option(GN_vcpkg_root ${CMAKE_CURRENT_LIST_DIR})

## path to vcpkg directory
# \note: relative path - ${CMAKE_BINARY_DIR} relative
# \note: absolute path - the path will be used
# \note: ""            - $ENV{VCPKG_ROOT}
GN_option(GN_vcpkg_vcpkgRoot "vcpkg") 

# ---------------------------|

macro(init pluginManager)
    GNP_bind(${pluginManager} "solution_configure" ${GN_vcpkg_root}/events.cmake)
    GN_vcpkg_normaliseVariables()
    GN_vcpkg_download()
    GN_vcpkg_setVariables()
    endmacro()

macro(GN_vcpkg)
    # >> finish vcpkg configuration
    if (NOT GNZ_vcpkg_secondLaunch)
        if ("${VCPKG_TARGET_TRIPLET}" STREQUAL "")
            GN_error("" "vcpkg isn't installed!")
            endif()
        # \todo why we need to abort execution????
        GN_cachef(GNZ_vcpkg_basicTrplet ${VCPKG_TARGET_TRIPLET})
        # abort execution 
        GN_infoLine()
        GN_infoHeader("VCPKG is configured;To configure the project re-run cmake build")
        GN_cachef(GNZ_vcpkg_secondLaunch on)
        GN_infoLine()
        GN_error("" " ")
        endif()
    GN_info("vcpkg triplet" "${VCPKG_TARGET_TRIPLET}")
    if (CMAKE_SYSTEM_NAME STREQUAL "Android")
        GN_vcpkg_installRawName("boost-build:x86-windows")
        endif()
    endmacro()

function(GN_vcpkg_install name)
    if (NOT GN__inSubprojects)
        GN_error(" " "Cannot install a package into uninitialised project")
        endif()

    set(triplet "${VCPKG_TARGET_TRIPLET}")
    if ("${name}" STREQUAL "")
        GN_error("package name cannot be empty!")
        endif()
    
    GN_vcpkg_installRawName("${name}:${triplet}")
    endfunction()

function(GN_vcpkg_installRawName name)
    if (NOT GNZ_vcpkg_installed_${name})
        GN_infoLine()
        GN_infoHeader("VCPKG package instalations")
        GN_info("installing package..." ${name})
        if (CMAKE_SYSTEM_NAME STREQUAL "Android")
            set(ENV{ANDROID_NDK_HOME} ${ANDROID_NDK_HOME})
            endif()
        execute_process(
            COMMAND ${GNZ_vcpkg_vcpkgExec} install ${name} --vcpkg-root ${GN_vcpkg_vcpkgRoot}
            WORKING_DIRECTORY   ${GN_vcpkg_vcpkgRoot}
            RESULTS_VARIABLE    result
        )
        if (result)
            GN_error("" "vcpkg result: ${result}")
            endif()
        GN_info("" "package installed: ${name}")
        GN_cachef(GNZ_vcpkg_installed_${name} on)
        endif()
    endfunction()

# ---------------------------| internal

function(GN_vcpkg_normaliseVariables)
    if("${GN_vcpkg_vcpkgRoot}" STREQUAL "")
        string(REPLACE "\\" "/" tmp "$ENV{VCPKG_ROOT}")
        GN_cachef(GN_vcpkg_vcpkgRoot ${tmp})
        endif()
    if("${GN_vcpkg_vcpkgRoot}" STREQUAL "")
        GN_error("" "ENV:VCPKG_ROOT is not set")
        endif()
    if (NOT IS_ABSOLUTE ${GN_vcpkg_vcpkgRoot})
        GN_cachef(GN_vcpkg_vcpkgRoot "${GN_build_root}/${GN_vcpkg_vcpkgRoot}")
        endif()
    endfunction()

function(GN_vcpkg_download)
    if (GNZ_vcpkg_downloaded)
        return()
        endif()
    
    GN_infoLine()
    GN_infoHeader("downloading vcpkg...")
    GN_info("vcpkgroot" "${GN_vcpkg_vcpkgRoot}")

    # clone vcpkg from github. stay on master
    if(NOT EXISTS ${GN_vcpkg_vcpkgRoot}/README.md)
        GN_info("status..." "cloning vcpkg to ${GN_vcpkg_vcpkgRoot}")
        execute_process(COMMAND git clone https://github.com/Microsoft/vcpkg.git ${GN_vcpkg_vcpkgRoot})
        endif()
    if(NOT EXISTS ${GN_vcpkg_vcpkgRoot}/README.md)
        GN_error("cannot clone vcpkg to ${GN_vcpkg_vcpkgRoot}")
        endif()

    # init vcpkg variables
    if(WIN32)
        set(VCPKG_EXEC ${GN_vcpkg_vcpkgRoot}/vcpkg.exe)
        set(VCPKG_BOOTSTRAP ${GN_vcpkg_vcpkgRoot}/bootstrap-vcpkg.bat)
    else()
        set(VCPKG_EXEC ${GN_vcpkg_vcpkgRoot}/vcpkg)
        set(VCPKG_BOOTSTRAP ${GN_vcpkg_vcpkgRoot}/bootstrap-vcpkg.sh)
        endif()

    # boostrap vcpkg
    if(NOT EXISTS ${VCPKG_EXEC})
        GN_info("status..." "bootstrapping vcpkg in ${GN_vcpkg_vcpkgRoot}")
        execute_process(COMMAND ${VCPKG_BOOTSTRAP} WORKING_DIRECTORY ${GN_vcpkg_vcpkgRoot})
        endif()
    if(NOT EXISTS ${VCPKG_EXEC})
        GN_error("cannot bootstrap vcpkg in ${GN_vcpkg_vcpkgRoot}")
        endif()

    # copy triplets
    file(GLOB triplets "${GN_vcpkg_root}/triplets/*.cmake")
    file(COPY ${triplets} DESTINATION "${GN_vcpkg_vcpkgRoot}/triplets/")
    GN_info("status..." "triplets copied:;${triplets}")

    GN_info("status..." "vcpkg installed in ${GN_vcpkg_vcpkgRoot}")
    GN_cachef(GNZ_vcpkg_vcpkgExec "${VCPKG_EXEC}")
    GN_cachef(GNZ_vcpkg_downloaded on)
    GN_infoLine()
    endfunction()

macro(GN_vcpkg_setVariables)
    # try to determinate NDK's location
    if (CMAKE_SYSTEM_NAME STREQUAL "Android")
        if (NOT "${ANDROID_NDK_HOME}" STREQUAL "")
        else()
            if    (NOT "$ENV{ANDROID_NDK_HOME}" STREQUAL "")
                set(tmp $ENV{ANDROID_NDK_HOME})
            elseif(NOT "${ANDROID_NDK_ROOT}" STREQUAL "")
                set(tmp ${ANDROID_NDK_ROOT})
            elseif(NOT "$ENV{ANDROID_NDK_ROOT}" STREQUAL "")
                set(tmp $ENV{ANDROID_NDK_ROOT})
            else()
                GN_error("" "Cannot determinate Android NDK's root (ANDROID_NDK_HOME or ANDROID_NDK_ROOT)")
                endif()
            string(REPLACE "\\" "/" tmp ${tmp})
            GN_cachef(ANDROID_NDK_HOME ${tmp})
            endif()
        GN_info("android NDK" "${ANDROID_NDK_HOME}")
    # set triplet
    elseif(GNZ_vcpkg_secondLaunch)
        GN_vcpkg_getTriplet(newTriplet ${GNZ_vcpkg_basicTrplet})
        GN_cachef(VCPKG_TARGET_TRIPLET ${newTriplet})
        endif()
    # set vcpkg's toolset
    GN_cachef(CMAKE_TOOLCHAIN_FILE "${GN_vcpkg_vcpkgRoot}/scripts/buildsystems/vcpkg.cmake")
    endmacro()

function(GN_vcpkg_getTriplet _result triplet)
    set(w "[(A-Z)|(a-z)|(0-9)]")
    if (NOT "${triplet}" MATCHES "^${w}+-${w}+-${w}-${w}")
        GN_vcpkg_getTripletFlag(flagRuntime ${GN_staticRuntime})
        GN_vcpkg_getTripletFlag(flagLinkage ${GN_staticLinkage})
        set(triplet "${triplet}-${flagRuntime}-${flagLinkage}")
        endif()
    GN_return(${triplet})
    endfunction()

function(GN_vcpkg_getTripletFlag _result bStatic)
    if (bStatic)
        GN_return("s")
        endif()
    GN_return("d")
    endfunction()
