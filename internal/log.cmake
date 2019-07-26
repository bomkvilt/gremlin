## --------------------------| log |-------------------------- ##
## -----------| settings
set(GN_log_lvl  "DEBUG")
set(GN_log_key  25     )


## -----------| interface

# print a dubug message
# NOTE: if ARGN is presented mesage: msg=key, ARGN[0]=value
# NOTE: if it's required to print values as in n columns: ARGN[1]=n
function(GN_debug msg)
    GN_log_lvlBorder("DEBUG")
    math(EXPR num "${ARGC} - 1")
    GN_log_process(msg ${num} "${msg}" ${ARGN})
    if (NOT "${msg}" STREQUAL "")
        message(${msg})
        endif()
    endfunction()

# print an info message
# NOTE: if ARGN is presented mesage: msg=key, ARGN[0]=value
# NOTE: if it's required to print values as in n columns: ARGN[1]=n
function(GN_info msg)
    GN_log_lvlBorder("INFO")
    math(EXPR num "${ARGC} - 1")
    GN_log_process(msg ${num} "${msg}" ${ARGN})
    if (NOT "${msg}" STREQUAL "")
        message(${msg})
        endif()
    endfunction()

# print an error message
# NOTE: if ARGN is presented mesage: msg=key, ARGN[0]=value
# NOTE: if it's required to print values as in n columns: ARGN[1]=n
# NOTE: the function terminates cmake execution
function(GN_error msg)
    GN_log_lvlBorder("ERROR")
    math(EXPR num "${ARGC} - 1")
    GN_log_process(msg ${num} "${msg}" ${ARGN})
    if (NOT "${msg}" STREQUAL "")
        message(FATAL_ERROR ${msg})
        endif()
    endfunction()


function(GN_debugLine)
    string(REPEAT "-" 80 line)
    GN_debug(${line})
    endfunction()

function(GN_infoLine)
    string(REPEAT "-" 80 line)
    GN_info(${line})
    endfunction()


function(GN_debugHeader name)
    GN_debugLine()
    GN_debug("" "${name}")
    GN_debugLine()
    endfunction()

function(GN_infoHeader name)
    GN_infoLine()
    GN_info("" "${name}")
    GN_infoLine()
    endfunction()

## -----------| internal

macro(GN_log_lvlBorder lvl)
    GN_log_lvlToInt(min ${GN_log_lvl})
    GN_log_lvlToInt(cur ${lvl})
    if (cur LESS min)
        return()
        endif()
    
    if (NOT GN_bDebug)
        GN_log_lvlToInt(min "DEBUG")
        if (NOT (cur GREATER min))
            return()
            endif()
        endif()
    endmacro()

function(GN_log_lvlToInt _result lvl)
    if    (${lvl} STREQUAL "DEBUG")
        GN_return(0)
    elseif(${lvl} STREQUAL "INFO")
        GN_return(1)
    elseif(${lvl} STREQUAL "ERROR")
        GN_return(2)
        endif()
    # wtf???
    message(FATAL_ERROR "incorrect log level '${lvl}'")
    endfunction()


function(GN_log_process _result num msg)
    # just message
    if (${num} EQUAL 0)
        GN_return("${msg}")
        endif()
    
    # key-value with a backet size
    set(key ${msg})
    set(value ${ARGN})
    set(backet 1)
    if (${num} GREATER 1)
        list(LENGTH ARGN len)
        math(EXPR end "${len} - 1")
        list(GET ARGN ${end} member)
        
        if ("${member}" MATCHES "^[0-9]+$")
            set(backet ${member})
            list(REMOVE_AT value ${end})
            endif()
        endif()
    GN_log_kv(msg "${key}" "${value}" "${backet}")
    GN_return("${msg}")
    endfunction()

# kv format key and value to a string
function(GN_log_kv _result key msg backet)
    # how many values we have
    list(LENGTH msg len)
    math(EXPR end "${len} - 1")
    if (${end} LESS 0)
        GN_return("")
        endif()

    set(bKeyUsed off)
    set(message "")
    GN_log_getKey(key "${key}")
    GN_log_getIdent(ident)
    # generate a message string
    foreach(i RANGE 0 ${end} ${backet})
        # get a sublist and ident it's elements
        list(SUBLIST msg ${i} ${backet} elements)
        list(JOIN elements "\t" row)
        if (NOT bKeyUsed)
            set(bKeyUsed true)
            string(APPEND message "${key} : ${row}")
        else()
            string(APPEND message "\n")
            string(APPEND message "${ident} : ${row}")
            endif()
        endforeach()
    GN_return(${message})
    endfunction()


# getKey returns an idented key string
function(GN_log_getKey _result key)
    # append ' ' to key to ident
    string(LENGTH "${key}" len)
    if (len LESS ${GN_log_key})
        # how many ' ' we need to insert
        math(EXPR delta "${GN_log_key} - ${len}")
        # generate the string
        string(REPEAT " " ${delta} ident)
        string(APPEND key ${ident})
        GN_return(${key})
        endif()
    # trim input string
    string(SUBSTRING "${key}" 0 ${GN_log_key} key)
    GN_return(${key})
    endfunction()

# getIdent returns an ident string 
function(GN_log_getIdent _result)
    string(REPEAT " " ${GN_log_key} ident)
    GN_return(${ident})
    endfunction()
