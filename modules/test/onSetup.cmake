
## this handler adds the unit to test enviroment
macro(event unit)
    GN_test_add(${unit})
    endmacro()
