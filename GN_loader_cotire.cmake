cmake_minimum_required(VERSION 2.8.2)

project(cotire-download NONE)

include(ExternalProject)
ExternalProject_Add( cotire
    GIT_REPOSITORY    https://github.com/sakra/cotire.git
    GIT_TAG           master
    SOURCE_DIR        "${root}/src"
    BINARY_DIR        "${root}/build"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND     ""
    INSTALL_COMMAND   ""
    TEST_COMMAND      ""
    )
