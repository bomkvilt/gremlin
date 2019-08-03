# gremlin
A set of CMake scripts that makes c ++ development a bit easier: Modules, Unit tests and Unity builds.

## Features
- [units](#Units)
- [unit tests](#Unit-tests)
- [unity build](#Unity-build)
- [external projects downloading](#External-projects)
- [include guards](#Include-guards)

## Downloading
```
    git submodule add https://github.com/bomkvilt/gremlin cmake/gremlin
```
## Examples
- [project uses the module](https://github.com/bomkvilt/Yager)

### Units
def. Unit - group of source files subdivided [optionally] on public, private, test etc. subgroups (the list depends from activated modules).

#### Properties

| property | description | [Inheritance](#Inheritance) |
| ----     | ----        | ---- |
| Private  | list of private include directories | No |
| Public   | list of public include directories | Yes |
| Libs     | list of libraries (or cmake targets) should be linked to the projects | Yes |
| Definitions | list of compiler definitoins | Yes |
| Units    | list of already defined [units](#Units) | Yes |
| Mode     | [lib, app]whether the units is a library or an executable | No |
| bFlat    | (flag) defines a unit's folder structure and avaliable features | No |

Units can be easily defined with this way:
```
GB_Unit(<name>
    Units
    Libs
    Private
    Public
    Definitions
    Mode            [app|lib = default]
    bFlat           (flag) [on|off = default]
)
```

#### Inheritance

To simplify resource management units (like cmake modules) have assigned public and private properties must (or not) 
be injected to units it connect to ('Units' property).

#### Directory structure

<table>
    <tr>
        <th> bFlat = off (default) </th>
        <th> bFlat = on </th>
    </tr>
    <tr style="vertical-align: top;">
        <td><pre>
|--- unit_name
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
    ...
        </pre></td>
        <td><pre>
|--- unit_name
    |--- CMakeLists.txt
    |--- public_header.hpp
    |--- any_source.cpp
    ...
        </pre></td>
    </tr>
</table>

### Unit tests
    To realise tests I currently use a GTest X-Unit framework without any modification. It gets loaded with 
    use of vcpgk package manager and connects to specific test executables.
    
    To enable testing it's required a add a directory called 'Test' to the unit's root (the unit must be none-flat library) 
    and place at least a source file into the one. 
    In this case gremlin will create a new unit with executable and connect the library to the executable.
    After that it will be accessible to a RUN_TESTS target and VS' GTest adaptor.

### Unity build
    Right now I use a none-tuned cotire unity build.
    **NOTE:** precompiled headers are not supported yet.

### External projects
    As I told I use a vcpk package manager. By default it loads all packages to a building directory but the behavior
    could be changed with use of the wollowing command: <code> GN_option(GN_vcpkg_vcpkgRoot "place") </code>.
    If a new root is empty a $ENV{VCPK_ROOT} will be used.
    
    To download a package just use <code>GN_vcpkg_install(Boost)</code>
    And do the same as the packages installed to your system:
    
```
find_package(Boost REQUIRED 
    filesystem 
    date_time 
    thread
    system
    regex)

GN_Unit(boost
    Libs            ${Boost_LIBRARIES}
    Public          ${Boost_INCLUDE_DIR}
    bFlat
)
```

### Include guards
Automatically generate top (e.g. file - test_file.hpp):
```
#ifndef UNITNAME_TESTFILE_HPP
#define UNITNAME_TESTFILE_HPP
```
and bottom:
```
#endif //!UNITNAME_TESTFILE_HPP
```
guards.
