# NEORV32 Example Setup for the tinyVision.ai Inc. "UPduino v3.0" FPGA Board

> [!WARNING]
> This setup **requires** Lattice Radiant version **2022.1**!

This example setup turns the UPduino v3.0 board, which features a Lattice iCE40 UltraPlus FPGA, into a tiny-scale NEORV32 microcontroller.
The processor setup provides 64kB of data and instruction memory, an RTOS-capable CPU (privileged architecture)
and a set of standard peripherals like UART, TWI and SPI.

* FPGA Board: :books: [tinyVision.ai Inc. UPduino v3 FPGA Board (GitHub)](https://github.com/tinyvision-ai-inc/UPduino-v3.0/),
:credit_card: buy on [Tindie](https://www.tindie.com/products/tinyvision_ai/upduino-v30-low-cost-lattice-ice40-fpga-board/)
* FPGA: Lattice iCE40 UltraPlus 5k `iCE40UP5K-SG48I`
* Toolchain: Lattice Radiant (tested with version 2022.1), using **Synplify Pro** synthesis engine
* Top entity: `neorv32_upduino_v3_top.vhd`


### Processor Configuration

* CPU: `rv32imcu_Zicsr_Zicntr`
* Memory: 64kB instruction memory (internal IMEM), 64kB data memory (internal DMEM), 4kB bootloader ROM
* Peripherals: `GPIO`, `MTIME`, `UART0`, `SPI`, `TWI`, `PWM`, `WDT`
* Clock: 24 MHz from on-chip HF oscillator
* Reset: indirect reset via FPGA re-reconfiguration pin (`creset_n`)
* Tested with processor version [`1.9.4.10`](https://github.com/stnolting/neorv32/blob/master/CHANGELOG.md)
* On-board FPGA bitstream flash storage can also be used to store/load NEORV32 application software (via the bootloader)


### Interface Signals

:information_source: See [`neorv32_upduino_v3.pdc`](https://github.com/stnolting/neorv32/blob/master/boards/UPduino_v3/neorv32_upduino_v3.pdc)
for the FPGA pin mapping.

| Top Entity Signal             | FPGA Pin   | Package Pin  | Board Header Pin |
|:------------------------------|:----------:|:------------:|:-----------------|
| `flash_csn_o` (spi_cs[0])     | IOB_35B    | 16           | J3-1             |
| `flash_sck_o`                 | IOB_34A    | 15           | J3-2             |
| `flash_sdo_o`                 | IOB_32A    | 14           | J3-3             |
| `flash_sdi_i`                 | IOB_33B    | 17           | J3-4             |
| `gpio_i(0)`                   | IOB_3B_G6  | 44           | J3-9             |
| `gpio_i(1)`                   | IOB_8A     | 4            | J3-10            |
| `gpio_i(2)`                   | IOB_9B     | 3            | J3-11            |
| `gpio_i(3)`                   | IOB_4A     | 48           | J3-12            |
| `gpio_o(0)` (status LED)      | IOB_5B     | 45           | J3-13            |
| `gpio_o(1)`                   | IOB_2A     | 47           | J3-14            |
| `gpio_o(2)`                   | IOB_0A     | 46           | J3-15            |
| `gpio_o(3)`                   | IOB_6A     | 2            | J3-16            |
| -                             | -          | -            | -                |
| **reconfigure FPGA** ("_reset_") | CRESET  | 8            | J2-3             |
| `pwm_o(0)` | `gpio_i(0)` (red)| RGB2       | 41           | J2-5             |
| `pwm_o(1)` (green)            | RGB0       | 39           | J2-6             |
| `pwm_o(2)` (blue)             | RGB1       | 40           | J2-7             |
| `twi_sda_io`                  | IOT_42B    | 31           | J2-9             |
| `twi_scl_io`                  | IOT_45A_G1 | 37           | J2-10            |
| `spi_sdo_o`                   | IOT_44B    | 34           | J2-11            |
| `spi_sck_o`                   | IOT_49A    | 43           | J2-12            |
| `spi_csn_o` (spi_cs[1])       | IOT_48B    | 36           | J2-13            |
| `spi_sdi_i`                   | IOT_51A    | 42           | J2-14            |
| `uart_txd_o` (UART0)          | IOT_50B    | 38           | J2-15            |
| `uart_rxd_i` (UART0)          | IOT_41A    | 28           | J2-16            |

:information_source: The TWI signals (`twi_sda_io` and `twi_scl_io`) and the reset input (`rstn_i`) require an external pull-up resistor.
GPIO output 0 (`gpio_o(0)`, also connected to the RGB drive) is used as output for a high-active **status LED** driven by the bootloader.


### FPGA Setup

1. start Lattice Radiant (in GUI mode)
2. click on "open project" and select `neorv32_upduino_v3.rdf` from this folder
3. click the :arrow_forward: button to synthesize, map, place and route the design and to generate a programming file
4. when done open the programmer (for example via "Tools" -> "Programmer"); you will need a programmer configuration, which will be created in the next steps; alternatively,
you can use the pre-build configuration `source/impl_1.xcf`
5. in the programmer double click on the field under "Operation" (_fast configuration_ should be the default) and select "External SPI Memory" as "Target Memory"
6. select "SPI Serial Flash" under "SPI Flash Options / Family"
7. select "WinBond" under "SPI Flash Options / Vendor"
8. select "W25Q32" under "SPI Flash Options / Device"
9. close the dialog by clicking "ok"
10. click on "Program Device"
