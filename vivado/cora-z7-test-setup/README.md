# NEORV32 Test Setup for the Digilent Cora Z7

This setup provides a very simple script-based "demo setup" that allows to check out the NEORV32 processor on the Digilent Cora Z7 board.
It uses the simplified
[`neorv32_test_setup_bootloader.vhd`](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_bootloader.vhd) top entity, which is a wrapper for the actual processor
top entity that provides a minimalistic interface (clock, reset, UART, LED and 7 IO's).

* FPGA Board: :books: [Digilent Cora Z7](https://digilent.com/reference/programmable-logic/cora-z7/start)
* FPGA: Xilinx ZynQ 7000 `xc7z007sclg400-1`
* Toolchain: Xilinx Vivado (tested with Vivado 2023.1)

### FPGA Utilization

```
Total LUT's	1966 / 14,400 ( 13.65 % )
Total registers	1445 / 28,800 ( 5.02 % )
Total Block RAM	8 / 50 ( 16.00 % )
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
* Tested with version [`1.12.6`](https://github.com/stnolting/neorv32/blob/master/CHANGELOG.md)
* Clock: 125 MHz from on-board oscillator
* Reset: Via dedicated on-board "BTN0" button
* GPIO output port `gpio_o`
  * bit 0 is connected to blue LED on LD0
  * bits 1..7 are connected to the expansion header CK_IO1-7
* UART0 signals `uart0_txd_o` and `uart0_rxd_i` are connected to CK_IO9 and CK_IO10
