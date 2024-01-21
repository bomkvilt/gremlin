# ----------------------------
# NOTE: the file must be includded into a root level CMakeLists.txt
# ----------------------------

_gn3_set_option("gn3_target_add_folders_enabled" false)

if (gn3_target_add_folders_enabled)
  # NOTE: makes sense at least for msvc
  set_property(GLOBAL PROPERTY USE_FOLDERS ON)
endif()


function(gn3_target_add_folders TARGET)
  if (NOT gn3_target_add_folders_enabled)
    message(WARNING "the function cannot be used: the feature is disabled")
  endif()

  file(RELATIVE_PATH folder "${GN_solution_root}" "${CMAKE_CURRENT_LIST_DIR}/..")
  message(STATUS "target ${TARGET}: folder='${folder}'")

  set_target_properties(${unit} PROPERTIES FOLDER "${folder}")
endfunction()
