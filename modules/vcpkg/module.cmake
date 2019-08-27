## --------------------------| variables |-------------------------- ##
## -----------| settings
## whether the module uses -static triplets
GN_option(GN_vcpkg_bStatic  on)

## cvpkgRoot is a path to vcpkg directory
# NOTE: if it's relative - ${CMAKE_BINARY_DIR} relative
# NOTE: if it's absolute - the path will be used
# NOTE: if it's "" - VCPKG_ROOT env will be used instead
GN_option(GN_vcpkg_vcpkgRoot "vcpkg") 

## --------------------------| initialisation |-------------------------- ##

function(GN_vcpkg_init)
    GN_vcpkg_fixVariables()
    if (NOT GN_vcpkg_downloaded)
        GN_vcpkg_download()
        GN_cache(GN_vcpkg_downloaded on)
        endif()
    GN_vcpkg_deduceTriplet(triplet)
    GN_cache(VCPKG_TARGET_TRIPLET "${triplet}")
    GN_cache(CMAKE_TOOLCHAIN_FILE "${GN_vcpkg_vcpkgRoot}/scripts/buildsystems/vcpkg.cmake")
    endfunction()

function(GN_vcpkg_configure)
    set(triplet "${VCPKG_TARGET_TRIPLET}")
    if ("${triplet}" STREQUAL "")
        GN_error("vcpkg isn't installed!")
        endif()
    GN_debug("vcpkg_triplet" "${triplet}")
    endfunction()

## --------------------------| interface |-------------------------- ##

function(GN_vcpkg_install name)
    set(triplet "${VCPKG_TARGET_TRIPLET}")
    if ("${name}" STREQUAL "")
        GN_error("name cannot be empty!")
        endif()
    set(name ${name}:${triplet})

    if (NOT ${GN_vcpkg_installed_${name}})
        # install the package
        GN_info("installing package..." "${name}")
        execute_process(COMMAND "${GN_vcpkg_vcpkgExec}" install "${name}"
            WORKING_DIRECTORY   "${GN_vcpkg_vcpkgRoot}"
            RESULTS_VARIABLE    result
        )
        if (result)
            GN_error("vcpkg result: ${result}")
            endif()
        GN_info("package installed: ${name}")
        GN_cache(${flag} on)
        endif()
    endfunction()

## --------------------------| internal |-------------------------- ##

function(GN_vcpkg_fixVariables)
    if("${GN_vcpkg_vcpkgRoot}" STREQUAL "")
        string(REPLACE "\\" "/" tmp $ENV{VCPKG_ROOT})
        GN_cache(GN_vcpkg_vcpkgRoot ${tmp})
        endif()
    if("${GN_vcpkg_vcpkgRoot}" STREQUAL "")
        GN_error("VCPKG_ROOT is not set")
        endif()
    if (NOT IS_ABSOLUTE ${GN_vcpkg_vcpkgRoot})
        GN_cache(GN_vcpkg_vcpkgRoot "${GN_dir_building}/${GN_vcpkg_vcpkgRoot}")
        endif()
    endfunction()


function(GN_vcpkg_download)
    GN_infoHeader("downloading vcpkg...")
    GN_info("vcpkgroot" "${GN_vcpkg_vcpkgRoot}")

    # clone vcpkg from github. stay on master
    if(NOT EXISTS ${GN_vcpkg_vcpkgRoot}/README.md)
        GN_info("status..." "cloning vcpkg to ${GN_vcpkg_vcpkgRoot}")
        execute_process(COMMAND git clone https://github.com/Microsoft/vcpkg.git ${GN_vcpkg_vcpkgRoot})
        endif()

    # check if success
    if(NOT EXISTS ${GN_vcpkg_vcpkgRoot}/README.md)
        GN_error("cannot clone vcpkg to ${GN_vcpkg_vcpkgRoot}")
        endif()

    # init vcpkg
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

    # check if success
    if(NOT EXISTS ${VCPKG_EXEC})
        GN_error("cannot bootstrap vcpkg in ${GN_vcpkg_vcpkgRoot}")
        endif()

    GN_info("status..." "vcpkg installed in ${GN_vcpkg_vcpkgRoot}")
    GN_cache(GN_vcpkg_vcpkgExec "${VCPKG_EXEC}")
    GN_infoLine()
    endfunction()

function(GN_vcpkg_deduceTriplet _result)
    set(triplet "$CACHE{VCPKG_TARGET_TRIPLET}")
    
    # deduce an arch
    if (CMAKE_GENERATOR_PLATFORM MATCHES "^[Ww][Ii][Nn]32$")
        set(_VCPKG_TARGET_TRIPLET_ARCH x86)
    elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Xx]64$")
        set(_VCPKG_TARGET_TRIPLET_ARCH x64)
    elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]$")
        set(_VCPKG_TARGET_TRIPLET_ARCH arm)
    elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]64$")
        set(_VCPKG_TARGET_TRIPLET_ARCH arm64)
    else()
        if(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 Win64$")
            set(_VCPKG_TARGET_TRIPLET_ARCH x64)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 ARM$")
            set(_VCPKG_TARGET_TRIPLET_ARCH arm)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015$")
            set(_VCPKG_TARGET_TRIPLET_ARCH x86)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017 Win64$")
            set(_VCPKG_TARGET_TRIPLET_ARCH x64)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017 ARM$")
            set(_VCPKG_TARGET_TRIPLET_ARCH arm)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017$")
            set(_VCPKG_TARGET_TRIPLET_ARCH x86)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 16 2019$")
            if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^[Xx]86$")
                set(_VCPKG_TARGET_TRIPLET_ARCH x86)
            elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^[Aa][Mm][Dd]64$")
                set(_VCPKG_TARGET_TRIPLET_ARCH x64)
            elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^[Aa][Rr][Mm]$")
                set(_VCPKG_TARGET_TRIPLET_ARCH arm)
            elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^[Aa][Rr][Mm]64$")
                set(_VCPKG_TARGET_TRIPLET_ARCH arm64)
            else()
                GN_info("using default arch 'x64' instead if '${CMAKE_HOST_SYSTEM_PROCESSOR}'")
                set(_VCPKG_TARGET_TRIPLET_ARCH x64)
            endif()
        else()
            find_program(_VCPKG_CL cl)
            if(_VCPKG_CL MATCHES "amd64/cl.exe$" OR _VCPKG_CL MATCHES "x64/cl.exe$")
                set(_VCPKG_TARGET_TRIPLET_ARCH x64)
            elseif(_VCPKG_CL MATCHES "arm/cl.exe$")
                set(_VCPKG_TARGET_TRIPLET_ARCH arm)
            elseif(_VCPKG_CL MATCHES "arm64/cl.exe$")
                set(_VCPKG_TARGET_TRIPLET_ARCH arm64)
            elseif(_VCPKG_CL MATCHES "bin/cl.exe$" OR _VCPKG_CL MATCHES "x86/cl.exe$")
                set(_VCPKG_TARGET_TRIPLET_ARCH x86)
            elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64")
                set(_VCPKG_TARGET_TRIPLET_ARCH x64)
            else()
                GN_error("Unable to determine target architecture")
            endif()
        endif()
    endif()

    # deduce an os
    if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsPhone")
        set(_VCPKG_TARGET_TRIPLET_PLAT uwp)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"))
        set(_VCPKG_TARGET_TRIPLET_PLAT linux)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"))
        set(_VCPKG_TARGET_TRIPLET_PLAT osx)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows"))
        set(_VCPKG_TARGET_TRIPLET_PLAT windows)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD"))
        set(_VCPKG_TARGET_TRIPLET_PLAT freebsd)
    endif()

    set(triplet "${_VCPKG_TARGET_TRIPLET_ARCH}-${_VCPKG_TARGET_TRIPLET_PLAT}")
    if (GN_vcpkg_bStatic AND NOT "${triplet}" MATCHES "\-static$")
        set(triplet "${triplet}-static")
        endif()
    GN_return("${triplet}")
    endfunction()
