
## this handler updates include guards or add them if they not exsts
function(event unit)
    GN_guards_processHeaders(${unit}
        "${${unit}_src_public};${${unit}_src_private}"
        )
    endfunction()
