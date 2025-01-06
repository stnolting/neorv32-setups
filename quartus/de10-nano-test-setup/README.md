# NEORV32 Test Setup for the Terasic DE10-Nano FPGA Board

This setup provides a very simple script-based "demo setup" that allows to check out the
NEORV32 processor on the Terasic DE10-Nano board.
It uses the simplified [`neorv32_test_setup_bootloader.vhd`](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_bootloader.vhd)
top entity, which is a wrapper for the actual processor
top entity that provides a minimalistic interface (clock, reset, UART and 8 LEDs).

* FPGA Board: :books: [Terasic DE10-Nano FPGA Board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=167&No=1046)
* FPGA: Intel Cyclone-V `5CSEBA6U23I7`
* Toolchain: Intel Quartus Lite (tested with Quartus Prime Lite 22.1.2)


### NEORV32 Configuration

:information_source: See the top entity
[`\neorv32-setups\quartus\de10-nano-test-setup\neorv32_test_setup_bootloader.vhd`](/neorv32-setups/quartus/de10-nano-test-setup/neorv32_test_setup_bootloader.vhd)
for configuration and entity details and `create_project.tcl` for the according FPGA pin mapping.

* CPU: `rv32imc_Zicsr`
* Memory:
  * 16kB instruction memory (internal IMEM)
  *  8kB data memory (internal DMEM)
  * bootloader ROM
* Peripherals:
  * `GPIO`
  * `CLINT`
  * `UART0`
* Tested with version `1.10.8.8`
* Clock: 50MHz from on-board oscillator
* Reset: via on-board button "KEY0"
* GPIO output port `gpio_o` (8-bit) connected to the 8 green user LEDs ("LED7" - "LED0")
* UART0 signals `uart0_txd_o` and `uart0_rxd_i` are connected to the 40-pin **GPIO_0** header
  * `uart0_txd_o:` output, connected to FPGA pin `Y15` - header pin `GPIO 0` (pin number "40")
  * `uart0_rxd_i:` input, connected to FPGA pin `AA11`   - header pin `GPIO 1` (pin number "1")


### FPGA Utilization

```
Logic utilization (in ALMs)	1,335 / 41,910 ( 3 % )
Total registers	1694
Total pins	12 / 314 ( 4 % )
Total virtual pins	0
Total block memory bits	231,424 / 5,662,720 ( 4 % )
Total DSP Blocks	0 / 112 ( 0 % )
```

## How To Run

The `create_project.tcl` TCL script in this directory can be used to create a complete Quartus project.
If not already available, this script will create a `work` folder in this directory.

1. start Quartus (in GUI mode)
2. in the menu line click "View/Utility Windows/Tcl console" to open the Tcl console
3. use the console to naviagte to **this** folder: `cd ..\neorv32-setups\quartus\de10-nano-test-setup`
4. execute `source create_project.tcl` - this will create and open the actual Quartus project in this folder
5. copy paste the neorv32_test_setup_bootloader.vhd in this folder and change the frequency to 50 MHz
6. double click on "Compile Design" in the "Tasks" window. This will synthesize, map and place & route your design and will also generate the actual FPGA bitstream
7. When the process is done open the programmer (for example via "Tools/Programmer") and click "Start" in the programmer window to upload the bitstream to your FPGA
8. Use a serial terminal (like :earth_asia: [Tera Term](https://ttssh2.osdn.jp/index.html.en)) to connect to the USB-UART interface using the following configuration:
    19200 Baud, 8 data bits, 1 stop bit, no parity bits, no transmission / flow control protocol (raw bytes only), newline on `\r\n` (carriage return & newline)
9. now you can communicate with the bootloader console and upload a new program.
Check out the [example programs](https://github.com/stnolting/neorv32/tree/master/sw/example)
and see section "Let's Get It Started" of the :page_facing_up: [NEORV32 data sheet](https://raw.githubusercontent.com/stnolting/neorv32/master/docs/NEORV32.pdf) for further resources.

