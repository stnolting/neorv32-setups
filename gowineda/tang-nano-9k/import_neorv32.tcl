# Usage:
# * Use on an existing project where you want to import neorv32. Importing
#   copies all the neorv32 core files into your project. It makes your project
#   self-contained. To update your neorv32 library, first get the up to date
#   files and run the updated import_neorv32.tcl with the -force flag from
#   the Gowin EDA TCL console.
#
# * On the command console (%) type:
#      source /path/to/this/import_neorv32.tcl
#   Or, with the force flag
#      set nrv_force_import true
#      source /path/to/this/import_neorv32.tcl
#      unset nrv_force_import


# Assume we are being called from the project directory
if {![info exists project_dir]} {
    set project_dir [pwd]
    puts "Assumming project directory is $project_dir"
}

# Environment variables (flags_import is declared by create_project)
if {![info exists flags_import]} {
    set flags_import ""
    if {[info exists nrv_force_import] && ($nrv_force_import == true)} {
    lappend flags_import -force }
}

set import_script_dir [file dirname [info script]]
set import_neorv32_dir $import_script_dir/../../neorv32/

# Add all neorv32 core files to the project
set corefiles [glob $import_neorv32_dir/rtl/core/*.vhd]
foreach corefile $corefiles {
    import_files -file $corefile {*}$flags_import
    set_file_prop -lib neorv32 $project_dir/src/[file tail $corefile]
    # TODO: verify set_file_prop call is refering to the files correctly
}

