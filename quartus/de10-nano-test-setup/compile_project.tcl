package require ::quartus::project
load_package flow

set script_dir [file dirname [file normalize [info script]]]
set project_name "de10-nano-test-setup"

cd $script_dir
project_open -revision $project_name $project_name
execute_flow -compile
project_close
