# -----------------------------------------------------------------------------
# Z7-Nano NEORV32 test setup - Vivado project creation and implementation
#
# Creates the Zynq-7020 project, adds the NEORV32 design, simulation sources
# and constraints, then runs implementation through bitstream generation.
# Run from Vivado Tcl mode with:
#   vivado -mode batch -source create_project.tcl
# author: Provoost Kris
# date: 2026-11-06
# -----------------------------------------------------------------------------

set board "z7-nano"

# Create and clear output directory

set loc_script [file normalize [info script]]
set loc_folder [file dirname $loc_script]
puts $loc_folder
cd $loc_folder

set outputdir work
file mkdir $outputdir

set files [glob -nocomplain "$outputdir/*"]
if {[llength $files] != 0} {
    puts "deleting contents of $outputdir"
    file delete -force {*}[glob -directory $outputdir *]; # clear folder contents
} else {
    puts "$outputdir is empty"
}

switch $board {
  "z7-nano" {
    set z7part "xc7z020clg400-2"
    set z7prj ${board}-test-setup
  }
}

# Create project
create_project -part $z7part $z7prj $outputdir

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

## Constraints
add_files -fileset constrs_1 $fileset_constraints

## Simulation-only
add_files -fileset sim_1 $fileset_sim

# Run synthesis, implementation and bitstream generation
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
