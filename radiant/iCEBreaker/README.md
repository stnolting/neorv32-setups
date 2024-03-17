# NEORV32 Example Setup for the iCEBreaker FPGA Board

> [!WARNING]
> This setup **requires** Lattice Radiant version **2022.1**!

### General

* FPGA board: https://github.com/icebreaker-fpga/icebreaker
* FPGA: Lattice iCE40 UltraPlus 5k `iCE40UP5K-SG48I`
* Toolchain: Lattice Radiant (version 2022.1) using **Synplify Pro** as synthesis engine
* Top entity: `icebreaker_top.vhd`
* Radiant project file: `iCEBreaker.rdf`
* Radiant programmer configuration: `source/impl_1.xcf`
* Implementation strategy file: `iCEBreaker1.sty` (just to enable VHDL08 support)
* Pre-compiled bitstream: `impl_1/iCEBreaker_impl_1.bin`

### NEORV32

* CPU: `rv32imau_Zicsr_Zicntr_Zifencei`
* Memory: 64kB instruction memory (internal IMEM, instantiating 2x SRAM primitives), 64kB data memory (internal DMEM, instantiating 2x SRAM primitives), 4kB bootloader ROM (inferring blockRAM)
  * make sure to update/override the linker script configurations accordingly to utilizes the full memory capacity
* Peripherals: `GPIO`, `MTIME`, `UART0` + FIFOs, `SPI`
* Clock: 24 MHz from PLL, driven by 12 MHz on-chip HF oscillator
* Reset: from PLL's "lock" signal, PLL is reset by the on-board user-button
* Tested with processor version [`1.9.4.10`](https://github.com/stnolting/neorv32/blob/master/CHANGELOG.md)

### IO

* On-board LEDs (2x, low-active)
* On-board reset button
* On board UART-USB serial bridge
* On-board  SPIFPGA bitstream flash storage can also be used to store/load NEORV32 application software (using the processor's default bootloader)

See pin-mapping constraints file `icebreaker.pdc`.
