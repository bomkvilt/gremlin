#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~| header workers

function(GN_process_headers files)
    # if disables
    if (NOT GN_bheaders)
        return()
        endif()
    foreach(file ${files})
        GN_last_extention(_extention ${file})
        if (${_extention} MATCHES ".h|.hpp")
            GN_process_header(${file})
            endif()
        endforeach()
    endfunction()

function(GN_process_header file)
    # generate guards
    GN_guard_name(guard ${file})
    GN_top_guard(top ${guard})
    GN_bot_guard(bot ${guard})

    # check guards
    file(READ ${file} data)
    GN_check_guards(ok "${data}")

    # insert guards
    set(out "")
    if (ok)
        string(APPEND re1 "^")
        string(APPEND re1 "#ifndef [A-Za-z0-9_]*\r?\n")
        string(APPEND re1 "#define [A-Za-z0-9_]*\r?\n")
        string(REGEX REPLACE "${re1}" "${top}" out "${data}")

        string(APPEND re2 "#endif *(//)?[!/ ]*[A-Za-z0-9_]*[\r\n ]*")
        string(REGEX REPLACE "${re2}" "${bot}" out "${out}")
    else()
        string(APPEND out "${top}")
        string(APPEND out "${data}")
        string(APPEND out "${bot}")
        endif()
    file(WRITE ${file} "${out}")
    endfunction()

function(GN_guard_name _result file)
    get_filename_component(name ${file} NAME)
    string(REPLACE "." "_" _d ${name})
    string(TOUPPER ${_d} _upper)
    GN_return(${_upper})
    endfunction()

function(GN_top_guard _result name)
    set(_gt "")
    string(APPEND _gt "#ifndef ${name}\n")
    string(APPEND _gt "#define ${name}\n")
    GN_return(${_gt})
    endfunction()

function(GN_bot_guard _result name)
    GN_return("#endif //!${name}\n")
    endfunction()

function(GN_check_guards _result data)
    set(re "")
    string(APPEND re "^")
    string(APPEND re "#ifndef [A-Za-z0-9_]*\r?\n")
    string(APPEND re "#define [A-Za-z0-9_]*\r?\n")
    string(REGEX MATCH "${re}" _matched "${data}")
    GN_return("${_matched}" STREQUAL "")
    endfunction()
