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
# project's name and changes into that directory. We don't want to go there yet,
# but let's save it for later.
# project_dir should be equal to $project_path/project_name
set project_dir [pwd]

# changing to #starting_dir guarantees that the paths to script_dir are valid
# even if they are relative.
#cd $starting_dir
#source $script_dir/add_neorv32.tcl

cd $project_dir
source $script_dir/import_neorv32.tcl

# Return to the newly created project directory
cd $project_dir