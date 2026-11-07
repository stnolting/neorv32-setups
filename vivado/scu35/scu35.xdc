set_property PACKAGE_PIN F23 [get_ports clk_p]
set_property PACKAGE_PIN E23 [get_ports clk_n]
set_property PACKAGE_PIN Y22 [get_ports rstn_i]

set_property IOSTANDARD LVDS [get_ports {clk_p clk_n}]
set_property IOSTANDARD LVCMOS33 [get_ports rstn_i]
create_clock -name board_clk -period 10.000 [get_ports clk_p]

set_property PACKAGE_PIN W22     [get_ports {gpio_o[0]}]
set_property PACKAGE_PIN AB18    [get_ports {gpio_o[1]}]
set_property PACKAGE_PIN AA18    [get_ports {gpio_o[2]}]
set_property PACKAGE_PIN V18     [get_ports {gpio_o[3]}]
set_property PACKAGE_PIN V17     [get_ports {gpio_o[4]}]
set_property PACKAGE_PIN Y20     [get_ports {gpio_o[5]}]
set_property PACKAGE_PIN W20     [get_ports {gpio_o[6]}]
set_property PACKAGE_PIN AA22    [get_ports {gpio_o[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_o[*]}]


set_property PACKAGE_PIN AC4      [get_ports uart0_txd_o]
set_property PACKAGE_PIN AD4      [get_ports uart0_rxd_i]
set_property IOSTANDARD LVCMOS33  [get_ports {uart0_txd_o uart0_rxd_i}]