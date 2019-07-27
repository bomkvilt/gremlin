## --------------------------| variables |-------------------------- ##
## -----------| settings
GN_option(GN_vcpkg_bEnabled on)

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

    set(toolchain "${GN_vcpkg_vcpkgRoot}/scripts/buildsystems/vcpkg-gremlin.cmake")
    configure_file("${GN_dir_gremlin}/modules/vcpkg/toolchain.cmake" ${toolchain} COPYONLY)
    GN_cache(CMAKE_TOOLCHAIN_FILE ${toolchain})
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

    set(flag GN_vcpkg_installed_${name})
    if (NOT ${flag})
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
