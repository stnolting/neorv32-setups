# Load Quartus II Tcl project package
package require ::quartus::project

project_open "neorv32_on_chip_debugger_intel"

# Run compile design flow
load_package flow
execute_flow -compile

project_close
