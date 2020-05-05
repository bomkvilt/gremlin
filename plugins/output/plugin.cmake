# ---------------------------| 
GN_option(GN_output_root ${CMAKE_CURRENT_LIST_DIR})
GN_option(GN_cppVersion 17)

macro(init pluginManager)
    GNP_bind(${pluginManager} "postGenerate" ${GN_output_root}/events.cmake)
    GN_assign1Val("outdir")
    GN_assign1Val("copyTo")
    endmacro()

macro(GN_output unit)
    GNU_getArgs(dir ${unit} "outdir")
    if (NOT "${dir}" STREQUAL "")
        # \todo: add generic solution
        set_target_properties(${unit} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE "${dir}")
        set_target_properties(${unit} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${dir}")
        endif()
    
    GNU_getArgs(dir ${unit} "copyTo")
    if (NOT "${dir}" STREQUAL "")
        add_custom_command(TARGET ${unit} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:${unit}>" "${dir}/")
        endif()
    endmacro()
