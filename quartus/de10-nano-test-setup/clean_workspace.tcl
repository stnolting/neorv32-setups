set cleanup_dir [file dirname [file normalize [info script]]]
set project_name "de10-nano-test-setup"
set generated_artifacts [list \
  db \
  incremental_db \
  output_files \
  ${project_name}.qpf \
  ${project_name}.qsf \
  ${project_name}.qws \
  ${project_name}_assignment_defaults.qdf]

foreach artifact $generated_artifacts {
  set artifact_path [file join $cleanup_dir $artifact]
  if {[file exists $artifact_path]} {
    puts "Removing generated Quartus artifact: $artifact_path"
    file delete -force $artifact_path
  }
}
