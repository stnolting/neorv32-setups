# make a local copy of original "./../../rtl/test_setups/neorv32_test_setup_bootloader.vhd " file
# and modify the default clock frequency: set to 50MHz
#set shell_script "cp -f ./../../../rtl/test_setups/neorv32_test_setup_bootloader.vhd  . && sed -i 's/100000000/50000000/g' neorv32_test_setup_bootloader.vhd "
#exec sh -c $shell_script


# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
  if {[string compare $quartus(project) "de10-nano-test-setup"]} {
    puts "Project de10-nano-test-setup is not open"
    set make_assignments 0
  }
} else {
  # Only open if not already open
  if {[project_exists de10-nano-test-setup]} {
    project_open -revision de10-nano-test-setup de10-nano-test-setup
  } else {
    project_new -revision de10-nano-test-setup de10-nano-test-setup
  }
  set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {

	set_global_assignment -name FAMILY "Cyclone V"
	set_global_assignment -name DEVICE 5CSEBA6U23I7
	set_global_assignment -name TOP_LEVEL_ENTITY neorv32_test_setup_bootloader
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.1.10
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "17:18:14  OCTOBER 31, 2021"
	set_global_assignment -name LAST_QUARTUS_VERSION "18.1.0 Lite Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1

  # core VHDL files
  set core_src_dir [glob ./../../NEORV32/rtl/core/*.vhd]
  foreach core_src_file $core_src_dir {
    set_global_assignment -name VHDL_FILE $core_src_file -library neorv32
  }
  set_global_assignment -name VHDL_FILE ./../../NEORV32/rtl/core/mem/neorv32_dmem.default.vhd -library neorv32
  set_global_assignment -name VHDL_FILE ./../../NEORV32/rtl/core/mem/neorv32_imem.default.vhd -library neorv32

  # top entity: use local modified copy of the original test setup
  set_global_assignment -name VHDL_FILE "neorv32_test_setup_bootloader.vhd"

  set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
  set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
  set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
  set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
  set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top

  set_location_assignment PIN_V11 -to clk_i
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk_i

  set_location_assignment PIN_AH17 -to rstn_i
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to rstn_i

  set_location_assignment PIN_W15 -to gpio_o[7]
  set_location_assignment PIN_AA24 -to gpio_o[6]
  set_location_assignment PIN_V16 -to gpio_o[5]
  set_location_assignment PIN_V15 -to gpio_o[4]
  set_location_assignment PIN_AF26 -to gpio_o[3]
  set_location_assignment PIN_AE26 -to gpio_o[2]
  set_location_assignment PIN_Y16 -to gpio_o[1]
  set_location_assignment PIN_AA23 -to gpio_o[0]
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio_o[7]
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio_o[6]
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio_o[5]
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio_o[4]
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio_o[3]
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio_o[2]
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio_o[1]
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio_o[0]

  set_location_assignment PIN_AA11 -to uart0_rxd_i
  set_location_assignment PIN_Y15 -to uart0_txd_o
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uart0_rxd_i
  set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uart0_txd_o


  set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

  # Commit assignments
  export_assignments
}
