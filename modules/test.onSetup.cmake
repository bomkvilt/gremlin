
## this handler adds the unit to test enviroment
function(event unit)
    GN_test_add(${unit})
    endfunction()
