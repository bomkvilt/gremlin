
## this handler generates a test target for the unit
function(event unit)
    GN_test_gen(${unit})
    endfunction()
