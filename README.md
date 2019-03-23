# gremlin
A set of CMake scripts that makes c ++ development a bit easier: Modules, Unit tests, Unity builds and Precompiled headers.

## Features
- [units](#Units) (static libraries or executables)
- [unit tests](#Unit-tests) (for libraries with use of google test framework)
- [unity build](#Unity-build) (with use of cotire script)
- [precompiled headers](#Precompiled-headers) (default cotire behaviour)
- [external projects downloading](#External-projects) (allows not to use third-party folders 
but load the library one at first configure time at specified place in building directory)

### Units
def. Unit - entity that contains any private and public states and can be connected to another unit. Their public states will be inherited.
Units can be defined with this way:
```
GB_Module( <name>
    Modules         <modules will be connected to. Will be inherited> ...
    Libs            <third-pary libraries. Will be inherited> ...
    Private         <third-party incudes will not be inherited> ...
    Public          <third-party incudes WILL be inherited> ...
    Definitions     <otherwise flags. Any flags will be passed into compiler. Will be inherited> ...
    Mode            <[app|lib|headers] type of the module (executable|library|header-only library)>
    bFlat           <[on|off] whether the module have Public|Private.. directories or place code in the module root>
    )
```
Each module can have the following directories (bFlat=on):
```
|--- <Unit root>
    |--- CMakeLists.txt
    |--- Public \
        |--- public_header.hpp
    |--- Private \
        |--- private_header.cpp
        |--- any_source.cpp
    |--- Test \
        |--- private_test_header.hpp
        |--- any_test.cpp
        |--- another_test.cpp
    |--- Data \
        |--- any_file.txt
```
Or (bFlat=off):
```
|--- <Unit root>
    |--- CMakeLists.txt
    |--- public_header.hpp
    |--- any_source.cpp
```

### Unit tests
    Common google tests. Must be placed in a Test folder.
    The test discowers with a Visual Studio built in google test adaptor.

### Unity build
    Applies cotire to the module.

### Precompiled-headers
    Default cotire behaviour.

### External projects
Allows to replace a third-party directory with a folder in a build directory. 
This function takes a @loader file and calls a cmake to configure and buuld it.
The invocation will be performed once and, in case of succes, will be done no more.
To download project:
```
    GN_Download_project( 
        root    <out. root of downloaded project> 
        example <name of the project> 
        loader  <any cmake file>)
```

Loader file cold looks like this:
```
cmake_minimum_required(VERSION 2.8.2)

project(cotire-download NONE)

# ${root} = the downloading project's root directory. The save as a GN_Download_project's output parameter
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
```
