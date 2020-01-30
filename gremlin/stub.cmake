set(GN_stub_cpp  ${CMAKE_CURRENT_LIST_DIR}/stub.cpp)
set(GN_stub_root ${CMAKE_CURRENT_LIST_DIR})

add_library   (GN_stub INTERFACE)
target_sources(GN_stub INTERFACE ${GN_stub_cpp})
