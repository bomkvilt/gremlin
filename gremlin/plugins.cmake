# class pluginManager {
#   std::map<std::string/*event*/, std::vector<std::path>> callbacks;
# }
#
# \note: callback path must point to a cmake files with function named 'callback'.
# The function's signature: std::function<std::string /*unit*/, std::string/*event*/>
# ---------------------------| public interface

function(GNP_new _result name)
    GN_return(${name})
    endfunction()

macro(GNP_on pluginManager event)
    GNP_get(callbacks ${pluginManager} "events.${event}")
    foreach(callback  ${callbacks})
        GNP_callEvent(${callback} ${event} ${ARGN})
        endforeach()
    endmacro()

function(GNP_bind pluginManager event callback)
    GNP_appendUnique(${pluginManager} "events.${event}" ${callback})
    endfunction()

# ---------------------------| internal

function(GNP_get _result pluginManager name)
    get_property(tmp GLOBAL PROPERTY "_GNP_${pluginManager}.${name}")
    if ("${tmp}" STREQUAL "NOTFOUND")
        set (tmp NULL)
        endif()
    GN_return(${tmp})
    endfunction()

function(GNP_set pluginManager name)
    set_property(GLOBAL PROPERTY "_GNP_${pluginManager}.${name}" "${ARGN}")
    endfunction()

function(GNP_appendUnique pluginManager name)
    GNP_get(tmp ${pluginManager} ${name})
    GN_appendListUnique(tmp "${tmp}" ${ARGN})
    GNP_set(${pluginManager} ${name} ${tmp})
    endfunction()

macro(GNP_callEvent callback)
    # message("call: ${callback}::event(${ARGN})")
    if (EXISTS ${callback})
        include(${callback})
        event(${ARGN})
    else()
        GN_error("" "pluging '${callback}' doesn't exist")
        endif()
    endmacro()
