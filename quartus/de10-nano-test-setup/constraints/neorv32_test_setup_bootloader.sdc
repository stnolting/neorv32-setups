#------------------------------------------------------------------------------
#--  Quartus timing constraint file for uart_spw <> Terrasic DE10 nano Cyclone 5 design
#--  rev. 1.0 : 2021 Provoost Kris
#------------------------------------------------------------------------------

# clock definitions
create_clock -name clk_i  -period 20    [get_ports clk_i]

# set false paths from user I/O
set_false_path -from [get_ports { rstn_i } ]           -to [get_registers *]
set_false_path                                         -to [get_ports { gpio_o[*] } ]

# general directives for PLL usage
derive_pll_clocks
derive_clock_uncertainty
