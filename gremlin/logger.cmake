# ---------------------------|
GN_option(GN_logLvl "DEBUG")
GN_option(GN_logKey 25)
GN_option(GN_nDebug on)

# ---------------------------|

function(GN_debug key)
    GN_log("DEBUG" "${key}" "${ARGN}")
    endfunction()

function(GN_info key)
    GN_log("INFO" "${key}" "${ARGN}")
    endfunction()

function(GN_error key)
    GN_log("ERROR" "${key}" "${ARGN}")
    endfunction()

# ---------------------------|

function(GN_log lvl key msg)
    GN_log_lvlToString(minLvl ${GN_logLvl})
    GN_log_lvlToString(curLvl ${lvl})
    if ((curLvl LESS minLvl) OR (lvl STREQUAL "DEBUG" AND GN_nDebug))
        return()
        endif()
    
    if ("${key}" STREQUAL "")
        GN_log_genV(text "${msg}")
    else()
        GN_log_genKV(text ${key} "${msg}")
        endif()
    
    if (NOT "${text}" STREQUAL "")
        if    ("${lvl}" STREQUAL "DEBUG")
            message("${text}")
        elseif("${lvl}" STREQUAL "INFO")
            message("${text}")
        elseif("${lvl}" STREQUAL "ERROR")
            message(FATAL_ERROR "${text}")
            endif()
        endif()
    endfunction()

function(GN_log_lvlToString _result lvl)
    if    ("${lvl}" STREQUAL "DEBUG")
        GN_return(0)
    elseif("${lvl}" STREQUAL "INFO")
        GN_return(1)
    elseif("${lvl}" STREQUAL "ERROR")
        GN_return(2)
        endif()
    message(FATAL_ERROR "incorrect log level '${lvl}'")
    endfunction()

# ---------------------------|

function(GN_log_genV _result msg)
    GN_return(${msg})
    endfunction()

function(GN_log_genKV _result key msg)
    GN_log_identKey(keyf ${key})
    GN_log_identKey(tabs "")
    
    set(text)
    set(bHead on)
    foreach(part ${msg})
        if (bHead)
            set(bHead off)
            string(APPEND text "${keyf} : ${part}")
        else()
            string(APPEND text "\n")
            string(APPEND text "${tabs} : ${part}")
            endif()
        endforeach()
    GN_return(${text})
    endfunction()

function(GN_log_identKey _result key)
    string(LENGTH "${key}" len)
    if (${len} LESS ${GN_logKey})
        math(EXPR delta "${GN_logKey} - ${len}")
        string(REPEAT " " "${delta}" ident)
        string(PREPEND key "${ident}")
    else()
        string(SUBSTRING "${key}" 0 ${GN_logKey} key)
        endif()
    GN_return("${key}")
    endfunction()
