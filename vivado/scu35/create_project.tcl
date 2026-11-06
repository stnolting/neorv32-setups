# -----------------------------------------------------------------------------
# SCU35 NEORV32 test setup - Vivado project creation and implementation
#
# Creates the SCU35 project, adds the NEORV32 design, simulation sources
# and constraints, then runs implementation through bitstream generation.
# Run from Vivado Tcl mode with:
#   vivado -mode batch -source create_project.tcl
# author: Provoost Kris
# date: 2026-11-06
# -----------------------------------------------------------------------------

set board "scu35"

# Create and clear output directory

set loc_script [file normalize [info script]]
set loc_folder [file dirname $loc_script]
puts $loc_folder
cd $loc_folder

proc cleanup_run_files {directory} {
    set generated_files [concat \
        [glob -nocomplain -directory $directory *.txt] \
        [glob -nocomplain -directory $directory *.backup.log] \
        [glob -nocomplain -directory $directory *.backup.jou]]
    foreach generated_file [lsort -unique $generated_files] {
        puts "Removing generated run file: $generated_file"
        file delete -force $generated_file
    }
}

cleanup_run_files $loc_folder

set outputdir work
file mkdir $outputdir

set files [glob -nocomplain "$outputdir/*"]
if {[llength $files] != 0} {
    puts "deleting contents of $outputdir"
    file delete -force {*}[glob -directory $outputdir *]; # clear folder contents
} else {
    puts "$outputdir is empty"
}

# Require the SCU35 FPGA device part to be available in the current Vivado install.
set scu35_part_id xcsu35p-sbvb625-2-e
set scu35_parts [get_parts -quiet $scu35_part_id]
if {[llength $scu35_parts] == 0} {
  error "SCU35 device part $scu35_part_id is unavailable; install the Zynq UltraScale+ device support."
}
set scu35part [lindex $scu35_parts 0]
puts "Found SCU35 device part: $scu35part"

# Create project
create_project -part $scu35part ${board}-test-setup $outputdir

set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]

# Define filesets

## Core: NEORV32
add_files [glob ./../../neorv32/rtl/core/*.vhd]
set_property library neorv32 [get_files [glob ./../../neorv32/rtl/core/*.vhd]]

## Design: processor subsystem template, and (optionally) BoardTop and/or other additional sources
set fileset_design ./../../neorv32/rtl/test_setups/neorv32_test_setup_bootloader.vhd

## Constraints
set fileset_constraints [glob ./*.xdc]

## Simulation-only sources
set fileset_sim [list ./../../neorv32/sim/neorv32_tb.vhd ./../../neorv32/sim/sim_uart_rx.vhd]

# Add source files

## Design
add_files $fileset_design
add_files ./scu35_neorv32_top.vhd
set_property top scu35_neorv32_top [current_fileset]

## Constraints
add_files -fileset constrs_1 $fileset_constraints

## Simulation-only
add_files -fileset sim_1 $fileset_sim

# Run synthesis, implementation and bitstream generation
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
