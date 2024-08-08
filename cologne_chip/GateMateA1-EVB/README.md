## Olimex GateMateA1-EVB

A simple NEORV32 SoC on the _low-cost_ and _open-source_ GateMateA1-EVB(-2M) development board
based on a Cologne Chip GateMate `CCGM1A1` FPGA.

* Board: [olimex.com/Products/FPGA/GateMate/GateMateA1-EVB](https://www.olimex.com/Products/FPGA/GateMate/GateMateA1-EVB)
* Board sources: [github.com/OLIMEX/GateMateA1-EVB](https://github.com/OLIMEX/GateMateA1-EVB)

#### Processor Configuration

* CPU: `rv32imc_zicntr_zicsr_zifencei`
* Peripherals: BOOTROM, GPIO, MTIME, UART0
* Memory: 16kB IMEM, 8kB DMEM
* Clock: on-board oscillator, 10MHz
* Reset: on-board button ("FPGA_BUT1")

Pin 0 of the processor's GPIO output port is inverted and connected to the on-board user LED ("FPGA_LED").

#### How-To

A [Makefile](Makefile) is provided to automate bitstream generation (i.e. synthesis, technology mapping, placement and routing)
via Yosys + GHDL and (CC's) place&route.

Download and unpack the [Cologne Chip toolchain](https://www.colognechip.com/programmable-logic/gatemate/gatemate-download)
to some system folder. Adjust the Makefile's `CCTOOLS` variable to point to the `bin` folder inside the installation folder.

To generate the bitstream just run the `all` target. In case you need some help, run the `help` target.
This will also show the current Makefile configuration.

```bash
neorv32-setups/cologne_chip/GateMateA1-EVB$ make all
```

This will generate the bitstream file (`neorv32_gatemate_00.cfg`) that can be uploaded to the FPGA using OpenFPGALoader
(part of the Cologne Chip toolchain):

```bash
neorv32-setups/cologne_chip/GateMateA1-EVB$ make jtag
```

> [!IMPORTANT]
> In order to program the Olimex Board via JTAG, openFPGAloader's "DirtyJTAG" (implemented by the on-board RP2040)
cable driver has to be used (`-c dirtyJtag`).

Connect a USB-UART connector to the board's PMOD port:

```schematic
PMOD front-view
     ________________________
    /                       /|
   +---+---+---+---+---+---+ |
   |3.3|GND| 4 | 3 | 2 | 1 | |
   +---+---+---+---+---+---+ |
   |3.3|GND|10 | 9 | 8 | 7 |/
---+---+---+---+---+---+---+---
```

| PMOD pin | Signal  | FPGA pin | Description    |
|:--------:|:-------:|:--------:|:--------------:|
| 1        | `txd_o` | IO_EA_A4 | UART TX output |
| 7        | `rxd_i` | IO_EA_B4 | UART RX input  |
| GND      | -       | -        | ground         |
| 3.3      | -       | -        | 3.3V output    |

Open a serial terminal using the following configuration: `19200-8-N-1`; linebreak on `/r/n` (carriage return + newline).
When you press the reset button ("FPGA_BUT1") the on-board LED should start flashing and the bootloader prompt
should show up in the terminal.

If nothing happens, press the "FPGA_RST1" button and upload the bitstream again.
