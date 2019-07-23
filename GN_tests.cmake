#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| tests

function(GN_init_tests)
    # if disabled
    if (NOT GN_bTests)
        return()
        endif()
    
    # ctest
    set(CTEST_BUILD_FLAGS -j${GN_cores})
    set(ctest_test_args ${ctest_test_args} PARALLEL_LEVEL ${GN_cores})

    # download gtest
    GN_Download_project(root "gtest" "${GN_dir_gremlin}/loaders/GN_loader_gtest.cmake")
    
	# setup gtest enviroment
	include(GoogleTest)
	enable_testing()
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