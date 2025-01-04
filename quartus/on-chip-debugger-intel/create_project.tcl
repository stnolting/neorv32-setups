# Load Quartus II Tcl project package
package require ::quartus::project

# Create project
project_new "neorv32_on_chip_debugger_intel" -overwrite

# Assign family, device, and top-level entity
set_global_assignment -name FAMILY "Cyclone IV E"
set_global_assignment -name DEVICE EP4CE15F23C8
set_global_assignment -name TOP_LEVEL_ENTITY neorv32_on_chip_debugger_intel

# Default settings
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name NUM_PARALLEL_PROCESSORS [expr {[get_environment_info -num_logical_processors] / 2}]

# search for all core VHDL files
set core_src_files [glob ./../../neorv32/rtl/core/*.vhd]

# filter out the default platform agnostic DTM so that we can replace it later
set core_src_files [lsearch -inline -all -not $core_src_files *neorv32_debug_dtm.vhd]

# add all VHDL source file to the neorv32 library
foreach core_src_file $core_src_files {
  set_global_assignment -name VHDL_FILE $core_src_file -library neorv32
}

# add Intel specific DTM implementation, replaces default one
set_global_assignment -name VHDL_FILE ./neorv32_debug_dtm.intel.vhd -library neorv32

# Toplevel
set_global_assignment -name VHDL_FILE ./neorv32_on_chip_debugger_intel_top.vhd

# Pin assignments. (Source: https://gecko-wiki.ti.bfh.ch/gecko4education:start)
set_location_assignment PIN_T1 -to clk_i
set_location_assignment PIN_AB11 -to rstn_i
set_location_assignment PIN_K17 -to gpio_o[7]
set_location_assignment PIN_J18 -to gpio_o[6]
set_location_assignment PIN_K18 -to gpio_o[5]
set_location_assignment PIN_F19 -to gpio_o[4]
set_location_assignment PIN_J15 -to gpio_o[3]
set_location_assignment PIN_K15 -to gpio_o[2]
set_location_assignment PIN_L16 -to gpio_o[1]
set_location_assignment PIN_L15 -to gpio_o[0]

# Close project
export_assignments
project_close
