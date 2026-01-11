# CLOCKS external

  create_clock -period 8.0 -waveform {0 4} [get_ports clk_i]

# False paths

  set_false_path -from              [get_ports rstn_i]
