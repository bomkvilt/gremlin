#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| common

macro(GN_project name)
    project(${name})
    set(CMAKE_CXX_STANDARD ${GN_cpp_version})
    endmacro()

macro(GN_return value)
    set(${_result} "${value}" PARENT_SCOPE)
    endmacro()

function(GN_get _result name)
    get_property(out GLOBAL PROPERTY ${name})
    GN_return("${out}")
    endfunction()

function(GN_set name value)
    set_property(GLOBAL PROPERTY ${name} ${value})
    endfunction()

function(GN_debug msg)
    if (GN_bDebug)
        message("${msg}")
        endif()
    endfunction()

function(GN_last_extention _result file)
    string(REGEX MATCH ".[^.]*$" _matched "${file}")
    GN_return("${_matched}")
    endfunction()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| tests

function(GN_init_tests)
    # if disabled
    if (NOT GN_bTests)
        return()
        endif()
        
    # download gtest
    GN_Download_project(root "gtest" "${GN_dir_gremlin}/GN_loader_gtest.cmake")
    
	# setup gtest enviroment
	enable_testing()
	include(GoogleTest)
	set(gtest_force_shared_crt off CACHE BOOL "" FORCE)
	add_subdirectory(
		"${root}/src"
		"${root}/build"
        EXCLUDE_FROM_ALL)
    
    # add gtest includes
    set(GN_tests_includes "${gtest_SOURCE_DIR}/include" CACHE STRING "" FORCE)
    endfunction()

function(GN_setup_tests)
    # if disabled
    if (NOT GN_bTests)
        return()
        endif()
    # add test agregator
    GN_Subprojects("${GN_dir_gremlin}/unit_test")
    endfunction()
