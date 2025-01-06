# NEORV32 Test Setup for the Microphase Z7 Nano FPGA Board

This setup provides a very simple script-based "demo setup" that allows to check out the NEORV32 processor on the Microphase Z7 Nano board.
It uses the simplified
[`neorv32_test_setup_bootloader.vhd`](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_bootloader.vhd) top entity, which is a wrapper for the actual processor
top entity that provides a minimalistic interface (clock, reset, UART and 8 IO's).

* FPGA Board: :books: [Microphase Z7 Nano FPGA Board](https://github.com/MicroPhase/fpga-docs/blob/master/schematic/Z7-NANO_R21.pdf)
* FPGA: Xilinx ZynQ 7000 `c7z020clg400-2`
* Toolchain: Xilinx Vivado (tested with Vivado 2023.1)

### FPGA Utilization

```
Total LUT's	2034 / 53,200 ( 3.82 % )
Total registers	1400 / 106400 ( 1.32 % )
Total Block RAM s	8 / 140 ( 5.71 % )
```

## NEORV32 Configuration

:information_source:
See the top entity
[`rtl/test_setups/neorv32_test_setup_bootloader.vhd` ](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_bootloader.vhd) for
configuration and entity details and oin_constraints.xdc for the according FPGA pin mapping.

* CPU: `rv32imc_Zicsr`
* Memory:
 * 16kB instruction memory (internal IMEM)
 * 8kB data memory (internal DMEM)
 * bootloader ROM
* Peripherals: `GPIO`, `MTIME`, `UART0`, `WDT`
* Tested with version [`1.10.8.8`](https://github.com/stnolting/neorv32/blob/master/CHANGELOG.md)
* Clock: 50 MHz from on-board oscillator
* Reset: Via dedicated on-board "RESET" button
* GPIO output port `gpio_o`
  * bits 0..7 are connected to the expansion header
* UART0 signals `uart0_txd_o` and `uart0_rxd_i` are connected to the expansion header