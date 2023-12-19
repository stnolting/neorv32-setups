#!/usr/bin/env gw_sh
# Must be run on Gowin EDA version 1.9.9 or later (no 1.9.9 betas)
# TODO: add top level project files
# TODO: add console arguments
# * to specify project path
# * to specify project name
# * to specify whether to add or import the files
# * to override neorv32 path
# * to specify force
#    --force-project
#    --force-import

set starting_dir [pwd]
set script_dir [file dirname [info script]]

# Force script_dir to be an absolute path
if { ![string match {/*} $script_dir] } {
    cd $script_dir
    set script_dir [pwd]
    cd $starting_dir
}

set neorv32_dir $script_dir/../../neorv32

# If you want to customize the values below, the full list is available on 
# [Gowin EDA path]/IDE/data/device/device_info.csv
# column B (2nd)
set part_number GW1NR-LV9QN88PC6/I5
 # column D (4th)
set device GW1NR-9C 
# column F (6th)
set version C 
# column G (7th)
set package QFN88P

set project_name tang-nano-9k
set project_creation_path [pwd]

puts "Creating project"
create_project \
  -name $project_name \
  -dir $project_creation_path \
  -pn $part_number \
  -device_version $version

# Creating the project creates a new directory in project_path with the 
# project's name and changes into that directory. Let's save it for later.
# project_dir should be equal to $project_path/project_name
set project_dir [pwd]

# --- Importing neorv32 library files ---
source $script_dir/import_neorv32.tcl

# --- Importing bootloader template file and constraint file ---
import_files \
  -file $neorv32_dir/rtl/test_setups/neorv32_test_setup_bootloader.vhd
import_files \
  -file $script_dir/tang-nano-9k_test_setup_bootloader.cst

# --- Modify bootloader template file ---
set fd [open $project_dir/src/neorv32_test_setup_bootloader.vhd r]
set fc [read $fd]
close $fd
# CLOCK_FREQUENCY   : natural := 100000000;  -- clock frequency of clk_i in Hz
regsub -all {100000000;} $fc {27000000; } fc
# gpio_o      : out std_ulogic_vector(7 downto 0); -- parallel output
regsub -all \
  {gpio_o\s*?:\s*?out\s+std_ulogic_vector\s*?\(\s*?[0-9]+\s+downto\s+0\s*?\)} \
  $fc {gpio_o : out std_ulogic_vector(5 downto 0)} fc
# gpio_o <= con_gpio_o(7 downto 0);
regsub -all \
  {gpio_o\s*?<=\s*?con_gpio_o\s*?\(\s*?[0-9]+\s+downto\s+0\s*?\)} \
  $fc {gpio_o <= con_gpio_o(5 downto 0)} fc
set fd [open $project_dir/src/neorv32_test_setup_bootloader.vhd w]
puts -nonewline $fd $fc
close $fd

# --- Setting top level file ---
set_option -top_module neorv32_test_setup_bootloader

# --- Setting dual-purpose pin configuration ---
set_option -use_done_as_gpio 1

# --- Other set_options ---
set_option -synthesis_tool gowinsynthesis
set_option -output_base_name tang-nano-9k

# --- Return to the newly created project directory ---
cd $project_dir