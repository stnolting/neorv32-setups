#!/usr/bin/env gw_sh
# Must be run on Gowin EDA version 1.9.9 or later (no 1.9.9 betas)

# TODO: implement flag to immediately synthesise using run all (implement 
# "batch mode")

# Available flags
# Example usage:
#  `gw_sh create_project.tcl --skip-creation`
#
# --skip-creation skips the creation of the project. Useful inside the Gowin IDE
#     when you already created a project but haven't imported the NEORV32 files.
# --force-project overwrites the project file if it already exists
# --force-import overwrites any NEORV32 files that already exist in your 
#     project's src directory. Use with caution.
# --project-name [NAME] lets you specify a name for the project instead of the
#     default name of "work".
# --project-path [PATH] lets you specify a path for the project instead of the
#     default path of the current working directory.

# Available environment variables
# The flags take precedence over the environment variables. Example usage:
#  `set nrv_project_name myproject`
#  `set nrv_project_creation_path ~/Sources`
#  `source create_project.tcl`
#  `unset nrv_project_name`
#  `unset nrv_project_creation_path`
# Unsetting the variables is not absolutely necessary, but they will keep their
# values if you don't, and they will affect this and other scripts every time
# you source them.
#
# nrv_skip_creation equivalent to `--skip-creation` if set to `true`.
# nrv_force_project equivalent to `--force-project` if set to `true`.
# nrv_force_import equivalent to `--force-import` if set to `true`.
# nrv_project_name equivalent to `--project-name`. Set to the project name.
# nrv_project_creation_path equivalent to `--project-path`. Set to project path.

# Record some basic directories
set starting_dir [pwd]
set script_dir [file dirname [info script]]

# Force script_dir to be an absolute path
if { ![string match {/*} $script_dir] } {
    cd $script_dir
    set script_dir [pwd]
    cd $starting_dir
}

set neorv32_dir $script_dir/../../neorv32

# Declare flags, use environment variable values if they exist, else defaults
set flags_project ""
set flags_import ""
set flag_skip_creation false
set project_name work
set project_creation_path [pwd]

if {[info exists nrv_skip_creation]} { 
  set flag_skip_creation $nrv_skip_creation }

if {[info exists nrv_force_project] && ($nrv_force_project == true)} {
  lappend flags_project -force }

if {[info exists nrv_force_import] && ($nrv_force_import == true)} {
  lappend flags_import -force }

if {[info exists nrv_project_name]} {
  set project_name $nrv_project_name }

if {[info exists nrv_project_creation_path]} {
  set project_creation_path $nrv_project_creation_path }

# Parse arguments passed.
if {[info exists argc] && ($argc>0)} {
  for {set i 0} {$i < $argc} {incr i} {
    set current_arg [lindex $argv $i]
    switch $current_arg {
      "--skip-creation" { set flag_skip_creation true }
      "--force-project" { lappend flags_project -force }
      "--force-import"  { lappend flags_import -force }
      "--project-name" { incr i; set project_name [lindex $argv $i] }
      "--project-path" { incr i; set project_creation_path [lindex $argv $i] }
    }
  }
}

# Force project_creation_path to be an absolute path
if { ![string match {/*} $project_creation_path] } {
    cd $project_creation_path
    set project_creation_path [pwd]
    cd $starting_dir
}

puts "create_project flags: $flags_project"
puts "import_files flags: $flags_import"


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

if {!$flag_skip_creation} {
  puts "Creating project"
  create_project \
    -name $project_name \
    -dir $project_creation_path \
    -pn $part_number \
    -device_version $version \
    {*}$flags_project
}

# Creating the project creates a new directory in project_path with the 
# project's name and changes into that directory. Let's save it for later.
# project_dir should be equal to $project_path/project_name
set project_dir [pwd]

# --- Importing neorv32 library files ---
source $script_dir/import_neorv32.tcl

# --- Importing bootloader template file and constraint file ---
import_files \
  -file $neorv32_dir/rtl/test_setups/neorv32_test_setup_bootloader.vhd \
  {*}$flags_import
import_files \
  -file $script_dir/tang-nano-9k_test_setup_bootloader.cst \
  {*}$flags_import

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

# "gpio_o <= con_gpio_out(7 downto 0)" to "gpio_o <= con_gpio_out(5 downto 0)"
regsub -all {gpio_o\s*?<=\s*?con_gpio_out\s*?\(\s*?[0-9]+\s+downto\s+0\s*?\)} $fc {gpio_o <= con_gpio_out(5 downto 0)} fc

# IO_GPIO_NUM from 8 to 6
regsub -all {IO_GPIO_NUM\s*=>\s*8,} $fc {IO_GPIO_NUM       => 6,} fc

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

# --- Unset variables ---
unset flags_project
unset flags_import
unset flag_skip_creation
unset starting_dir
unset script_dir
unset neorv32_dir
unset part_number
unset device
unset version
unset package


# --- Return to the newly created project directory ---
cd $project_dir
