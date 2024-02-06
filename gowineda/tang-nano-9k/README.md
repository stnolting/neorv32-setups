# NEORV32 Test Setup for the Sipeed Tang Nano 9K FPGA development board

This setup provides a simple script that you can run using the Gowin shell and creates a project with the NEORV32 processor already imported and ready to synthesize in the Gowin FPGA Designer IDE.
It uses the simplified [`neorv32_test_setup_bootloader.vhd`](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_bootloader.vhd) top entity, which is a wrapper for the actual processor top entity that provides a minimalistic interface (clock, reset, UART and 6 LEDs).

* FPGA Board:
  * :books: [Sipeed Tang Nano 9K](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html)
* FPGA:
  * Gowin LittleBee GW1NR `GW1NR-LV9QN88PC6/I5`
* Toolchain: Gowin EDA (tested with Gowin EDA 1.9.9 on Linux —not a 1.9.9 beta)

## NEORV32 Configuration

:information_source: See the top entity [`rtl/test_setups/neorv32_test_setup_bootloader.vhd` ](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_bootloader.vhd) for
configuration and entity details and [`tang-nano-9k_test_setup_bootloader.cst`](https://github.com/IvanVeloz/neorv32-setups/blob/master/gowineda/tang-nano-9k/tang-nano-9k_test_setup_bootloader.cst)
for the according FPGA pin mapping.

* CPU: `rv32imcu_Zicsr` + 4 `HPM` (hardware performance monitors)
* Memory: 16kB instruction memory (internal IMEM), 8kB data memory (internal DMEM), bootloader ROM
* Peripherals: `GPIO`, `MTIME`, `UART0`, `WDT`
* Tested with version [`1.9.2.5`](https://github.com/stnolting/neorv32/blob/master/CHANGELOG.md)
* Clock: 27MHz from on-board oscillator
* Reset: Via dedicated on-board "RESET" button
* GPIO output port `gpio_o` bits 0..5 are connected to the orange on-board LEDs (LED1 - LED6); LED6 is the bootloader status LED
* UART0 signals `uart0_txd_o` and `uart0_rxd_i` are connected to the on-board USB-UART chip
  * Under Linux, run `sudo modprobe ftdi_sio` for the on-board UART to appear under `/dev/ttyUSB*` (the higher of the two ports that will appear). Run `sudo modprobe -r ftdi_sio` to be able to program the device on the Gowin Programmer. There is no need to unplug the device from the USB port.
