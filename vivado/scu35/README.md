# NEORV32 Test Setup for the SCU35

This Vivado project builds the NEORV32 bootloader test setup for the SCU35
evaluation board.

## Design and board connections

The project top is `scu35_neorv32_top`, which wraps
`neorv32_test_setup_bootloader` and converts the board's differential clock
input to the single-ended clock using an `IBUFDS`.
It uses the simplified
[`neorv32_test_setup_bootloader.vhd`](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_bootloader.vhd) entity for the CPU, which is a wrapper for the actual processor

## Board
* FPGA Board: :books: [SCU35]
(https://www.amd.com/en/products/adaptive-socs-and-fpgas/evaluation-boards/scu35.html)
* FPGA: AMD Spartan UltraScale + `xcsu35p-sbvb625-2-e`
* Toolchain: Xilinx Vivado (Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025)

### FPGA Utilization

```
Total LUTs       : 2144 / 16320
Total registers  : 1497 / 32640
Total Block RAMs :    7 /    48
```
## NEORV32 Configuration

:information_source:
See the top entity
[`rtl/test_setups/neorv32_test_setup_bootloader.vhd` ](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_bootloader.vhd) for
configuration and entity details and 'scu35.xdc' for the according FPGA pin mapping.

* CPU: `rv32imc_Zicsr`
* Memory:
  * 16kB instruction memory (internal IMEM)
  * 8kB data memory (internal DMEM)
  * bootloader ROM
* Peripherals: `GPIO`, `MTIME`, `UART0`, `WDT`
* Tested with version [`1.13.7.2`](https://github.com/stnolting/neorv32/blob/master/CHANGELOG.md)
* Clock: 100 MHz from on-board oscillator
* Reset: Via dedicated on-board "CENTER" button
* GPIO output port `gpio_o`
  * bits 0..7 are connected to the LEDs
* UART0 uses the SCU35 UART-D pins: `uart0_txd_o` on AC4 and `uart0_rxd_i` on AD4, both LVCMOS33.

## Build

Run Vivado in batch mode from this directory:

```powershell
vivado -mode batch -source create_project.tcl
```

The script checks that the `xcsu35p-sbvb625-2-e` device part is installed,
creates the `scu35-test-setup` project under `work`, adds the NEORV32 core,
bootloader top, SCU35 wrapper, constraints, and simulation sources, then runs
implementation through `write_bitstream`.
