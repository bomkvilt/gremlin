add_library(testLib INTERFACE)
target_compile_definitions(testLib INTERFACE TESTLIB=16)

GN_unit(exec bFlat
    mode eApp
    libs testLib
)
