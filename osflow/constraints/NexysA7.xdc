## This file is a general .xdc for the Nexys A7 and Nexys 4 DDR
## For default neorv32_test_setup.vhd top entity

## Clock signal
set_property IOSTANDARD 	LVCMOS33  	[get_ports clk_i]
set_property PACKAGE_PIN 	E3   		[get_ports clk_i]

## LEDs
set_property IOSTANDARD 	LVCMOS33    [get_ports {gpio_o[0]}]
set_property IOSTANDARD 	LVCMOS33    [get_ports {gpio_o[1]}]
set_property IOSTANDARD 	LVCMOS33    [get_ports {gpio_o[2]}]
set_property IOSTANDARD 	LVCMOS33    [get_ports {gpio_o[3]}]
set_property IOSTANDARD 	LVCMOS33    [get_ports {gpio_o[4]}]
set_property IOSTANDARD 	LVCMOS33    [get_ports {gpio_o[5]}]
set_property IOSTANDARD 	LVCMOS33    [get_ports {gpio_o[6]}]
set_property IOSTANDARD 	LVCMOS33    [get_ports {gpio_o[7]}]
set_property PACKAGE_PIN 	H17  		[get_ports {gpio_o[0]}]
set_property PACKAGE_PIN 	K15  		[get_ports {gpio_o[1]}]
set_property PACKAGE_PIN 	J13  		[get_ports {gpio_o[2]}]
set_property PACKAGE_PIN 	N14  		[get_ports {gpio_o[3]}]
set_property PACKAGE_PIN 	R18  		[get_ports {gpio_o[4]}]
set_property PACKAGE_PIN 	V17  		[get_ports {gpio_o[5]}]
set_property PACKAGE_PIN 	U17  		[get_ports {gpio_o[6]}]
set_property PACKAGE_PIN 	U16  		[get_ports {gpio_o[7]}]

## USB-UART Interface
set_property IOSTANDARD 	LVCMOS33 	[get_ports uart_txd_o]
set_property IOSTANDARD 	LVCMOS33	[get_ports uart_rxd_i]
set_property PACKAGE_PIN 	D4  		[get_ports uart_txd_o]
set_property PACKAGE_PIN 	C4  		[get_ports uart_rxd_i]

## Misc.
set_property IOSTANDARD 	LVCMOS33	[get_ports rstn_i]
set_property PACKAGE_PIN 	C12 		[get_ports rstn_i]
