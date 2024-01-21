# ----------------------------
# NOTE: the file must be includded into a root level CMakeLists.txt
# ----------------------------

_gn3_set_option(gn3_target_link_binary_to_src_suffix ".built.link")

function(gn3_target_link_binary_to_src TARGET)
  add_custom_command(
    TARGET ${TARGET} POST_BUILD
    COMMAND
      "${CMAKE_COMMAND}" -E create_symlink
      "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}"
      "${CMAKE_CURRENT_LIST_DIR}/${TARGET}${gn3_target_link_binary_to_src_suffix}"
    VERBATIM
  )
endfunction()
