# CLOCKS external

  create_clock -period 20.000 [get_ports clk_i]

# False paths

  set_false_path -from              [get_ports rstn_i]