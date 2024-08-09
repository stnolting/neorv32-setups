## Olimex GateMateA1-EVB

A simple NEORV32 SoC on the _low-cost_ and _open-source_ GateMateA1-EVB(-2M) development board
based on a Cologne Chip GateMate `CCGM1A1` FPGA.

* Board: [olimex.com/Products/FPGA/GateMate/GateMateA1-EVB](https://www.olimex.com/Products/FPGA/GateMate/GateMateA1-EVB)
* Board sources: [github.com/OLIMEX/GateMateA1-EVB](https://github.com/OLIMEX/GateMateA1-EVB)

#### Processor Configuration

* CPU: `rv32imc_zicntr_zicsr_zifencei`
* Tuning options: `FAST_MUL`, `FAST_SHIFT`
* Peripherals: BOOTROM, IMEM, DMEM, GPIO, MTIME, UART0, PWM, DMA
* Memory: 16kB IMEM, 8kB DMEM, 4kB bootloader ROM
* Clock: on-board oscillator, 10MHz
* Reset: on-board button ("FPGA_BUT1")

Pin 0 of the processor's GPIO output port and pin 0 of the processor's PWM port are logically OR-ed,
inverted and connected to the on-board user LED ("FPGA_LED").

#### How-To

A [Makefile](Makefile) is provided to automate bitstream generation (i.e. synthesis, technology mapping, placement and routing)
via Yosys + GHDL and (CC's) place&route.

Download and unpack the [Cologne Chip toolchain](https://www.colognechip.com/programmable-logic/gatemate/gatemate-download)
to some system folder. Adjust the Makefile's `CCTOOLS` variable to point to the `bin` folder inside the installation folder.

> [!WARNING]
> The GHDL-Yosys plugin of the toolchain seems to have some _hardcoded_ relative paths. I had to copy the toolchain's `bin`
folder right into the root directory of `neorv32-setups`. Otherwise, (Yosys+)GHDL cannot find the built-in
IEEE libraries.

To generate the bitstream just run the `all` target. In case you need some help, run the `help` target.
This will also show the current Makefile configuration.

```bash
neorv32-setups/cologne_chip/GateMateA1-EVB$ make all
```

This will generate the bitstream file (`neorv32_gatemate_00.cfg`) that can be uploaded to the FPGA using OpenFPGALoader
(part of the Cologne Chip toolchain). Better press the "FPGA_RST1" button before uploading the bitstream (see note at the end).

```bash
neorv32-setups/cologne_chip/GateMateA1-EVB$ make jtag
```

> [!IMPORTANT]
> In order to program the Olimex Board via JTAG, openFPGAloader's "DirtyJTAG" (implemented by the on-board RP2040)
cable driver has to be used (`-c dirtyJtag`).

Synthesis and implementations logs are available in `synth.log` and `impl.log`, respectively. Here is the implementation's
resource utilization:

```
Utilization Report

 CPEs                   5010 /  20480  ( 24.5 %)
 -----------------------------------------------
   CPE Registers        1944 /  40960  (  4.7 %)
     Flip-flops         1944
     Latches               0

 GPIOs                     5 /    144  (  3.5 %)
 -----------------------------------------------
   Single-ended            5 /    144  (  3.5 %)
     IBF                   3
     OBF                   2
     TOBF                  0
     IOBF                  0
   LVDS pairs              0 /     72  (  0.0 %)
     IBF                   0
     OBF                   0
     TOBF                  0
     IOBF                  0

 GPIO Registers            0 /    288  (  0.0 %)
 -----------------------------------------------
   FF_IBF                  0
   FF_OBF                  0
   IDDR                    0
   ODDR                    0

 Block RAMs             10.0 /     32  ( 31.3 %)
 -----------------------------------------------
   BRAM_20K                2 /     64  (  3.1 %)
   BRAM_40K                8 /     32  ( 25.0 %)
   FIFO_40K                0 /     32  (  0.0 %)

 PLLs                      0 /      4  (  0.0 %)
 GLBs                      1 /      4  ( 25.0 %)
 SerDes                    0 /      1  (  0.0 %)
```

UART0 is used as system and bootloader console. Connect a USB-UART connector to the board's PMOD port:

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

> [!TIP]
> If nothing happens or if the FPGA haves strange, press the "FPGA_RST1" button and upload the bitstream again.
