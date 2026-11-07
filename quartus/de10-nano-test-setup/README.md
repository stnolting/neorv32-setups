# NEORV32 Test Setup for the Terasic DE10-Nano FPGA Board

This setup provides a very simple script-based "demo setup" that allows to check out the
NEORV32 processor on the Terasic DE10-Nano board.
It uses the simplified [`neorv32_test_setup_bootloader.vhd`](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_bootloader.vhd)
top entity, which is a wrapper for the actual processor
top entity that provides a minimalistic interface (clock, reset, UART and 8 LEDs).

* FPGA Board: :books: [Terasic DE10-Nano FPGA Board]
(https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=167&No=1046)
* FPGA: Intel Cyclone-V `5CSEBA6U23I7`
* Toolchain: Intel Quartus Lite (Version 25.1std.0 Build 1129 10/21/2025 SC Lite Edition)


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
* Tested with version '1.13.7.2'
* Clock: 50MHz from on-board oscillator
* Reset: via on-board button "KEY0"
* GPIO output port `gpio_o` (8-bit) connected to the 8 green user LEDs ("LED7" - "LED0")
* UART0 signals `uart0_txd_o` and `uart0_rxd_i` are connected to the 40-pin **GPIO_0** header
  * `uart0_txd_o:` output, connected to FPGA pin `Y15` - header pin `GPIO 0` (pin number "40")
  * `uart0_rxd_i:` input, connected to FPGA pin `AA11`   - header pin `GPIO 1` (pin number "1")


### FPGA Utilization

```
Logic utilization (in ALMs) : 1,418 / 41,910 ( 3 % )
Total registers : 1726
Total pins : 12 / 314 ( 4 % )
Total virtual pins : 0
Total block memory bits : 231,424 / 5,662,720 ( 4 % )
Total RAM Blocks : 30 / 553 ( 5 % )
```
### FPGA CLK report
| Fmax      | Restricted Fmax | Clock Name | Note |
|-----------|-----------------|------------|------|
| 88.38 MHz | 88.38 MHz       | clk_i      |      |

## How To Run

The `create_project.tcl` TCL script in this directory can be used to create a complete Quartus project. The 'clean_project' helper script is called to make a clean workspace.

1. Run `quartus_sh -t create_project.tcl` from this directory to create the project.
2. Run `quartus_sh -t compile_project.tcl` to synthesize, fit, assemble, and generate the FPGA programming file (`output_files/de10-nano-test-setup.sof`).
3. Program the FPGA with the generated `.sof` file.
4. Use a serial terminal (like :earth_asia: [Tera Term](https://ttssh2.osdn.jp/index.html.en)) to connect to the USB-UART interface using the following configuration:
    19200 Baud, 8 data bits, 1 stop bit, no parity bits, no transmission / flow control protocol (raw bytes only), newline on `\r\n` (carriage return & newline)
5. Now you can communicate with the bootloader console and upload a new program.
Check out the [example programs](https://github.com/stnolting/neorv32/tree/master/sw/example)
and see section "Let's Get It Started" of the :page_facing_up: [NEORV32 data sheet](https://raw.githubusercontent.com/stnolting/neorv32/master/docs/NEORV32.pdf) for further resources.
