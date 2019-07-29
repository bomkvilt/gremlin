
## this handler updates include guards or add them if they not exsts
macro(event unit)
    GNU_getSrc(files ${unit} "project")
    GN_guards_processHeaders(${unit} "${files}")
    endmacro()
