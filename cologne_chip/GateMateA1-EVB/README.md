# Olimex GateMateA1-EVB

A small NEORV32 SoC on the _low-cost_ and _open-source_ GateMateA1-EVB(-2M) development board
powered by a Cologne Chip GateMate `CCGM1A1` FPGA.

* Board: [olimex.com/Products/FPGA/GateMate/GateMateA1-EVB](https://www.olimex.com/Products/FPGA/GateMate/GateMateA1-EVB)
* Board sources: [github.com/OLIMEX/GateMateA1-EVB](https://github.com/OLIMEX/GateMateA1-EVB)

#### Setup Configuration

* CPU: RISC-V `rv32imcx_zicntr_zicsr_zifencei`
* Tuning options: none
* Peripherals: `IMEM`, `DMEM`, `GPIO` (heart beat LED "FPGA_LED"), `CLINT`, `UART0`, `SPI`, `TWI`
* Bootmode: 0 = boot via build-in bootloader
* Memory: 16kB IMEM, 8kB DMEM, 4kB bootloader ROM
* Clock: 25Mhz via CC_PLL from 10MHz on-board oscillator
* Reset: on-board button ("FPGA_BUT1")
* FPGA operation mode: "speed"

> [!TIP]
> The SPI port is connected to the on-board bitstream flash (using SPI.CSn0)
and can be used to store/load application firmware via the NEORV32 bootloader.

## How-To

A simple [Makefile](Makefile) is provided to automate bitstream generation (i.e. synthesis, technology mapping, placement and routing)
via Yosys + GHDL and (CC's) place&route. You can see all the available targets and the (default) variable configuration by executing `make`:

```bash
$ make
Cologne Chip GateMate Makefile

Configuration:
 TOP       = neorv32_gatemate
 NETLIST   = neorv32_gatemate.synth.v
 CCTOOLS   = /opt/cc-toolchain
 GHDLFLAGS = --work=neorv32 --warn-no-binding -C --ieee=synopsys
 SYNFLAGS  = -nomx8
 PRFLAGS   = -uCIO -ccf neorv32_gatemate.ccf -cCP
 OFLFLAGS  = -c dirtyJtag

Targets:
 help  - show this text
 info  - show toolchain version (Yosys and P_R)
 clean - remove all build artifacts
 synth - synthesize design (including technology mapping) and generate netlist
 impl  - implement design (place and route) and generate bitstream
 jtag  - upload bitstream via JTAG
 all   - clean + synth + impl
```

### Toolchain

Download and unpack the [Cologne Chip toolchain](https://www.colognechip.com/programmable-logic/gatemate/gatemate-download)
to some system folder. Adjust the Makefile's `CCTOOLS` variable to point to the Cologne Chip toolchain home folder:

```makefile
CCTOOLS = /opt/cc-toolchain
```

> [!NOTE]
> The `bin` folder contains three sub folder: `openFPGALoader`, `p_r` and `yosys`.

### GHDL Installation Issues

The precompiled FPGA toolchain expects GHDL to be installed in a specific folder in `/usr`. If GHDL is installed
somewhere else you might get the following error:

```
warning: ieee library directory '/usr/local/lib/ghdl/ieee/v93/' not found
error: cannot find "std" library
```

This can be fixed by linking the expected installation folder to the actual one (`/opt/ghdl` in this example):

```bash
/usr/local/lib$ sudo ln -s /opt/ghdl/lib/ghdl ghdl
```

See https://github.com/chili-chips-ba/openCologne/issues/24 for more information.

### Bitstream Generation

To generate the bitstream just run the `all` target. In case you need some help, run the `help` target.
This will also show the current Makefile/setup configuration. The synthesis flow uses the GHDL plugin for Yosys
for processing the VHDL sources. Note that all VHDL sources are added to the `neorv32` library.

```bash
$ make all
```

This will generate the bitstream final file (`neorv32_gatemate_00.cfg`).
Synthesis and implementations logs are available in `synth.log` and `impl.log`, respectively.

### Bitstream Programming

> [!NOTE]
> The FPGA's programming interface requires a special driver (on Windows). You can use [Zadig](https://zadig.akeo.ie)
to install the according driver (requires administrator privileges). Change the default (FTDI-bus) driver to
`WinUSB` See https://github.com/trabucayre/openFPGALoader/issues/245#issuecomment-1336159690 for more information.

Before you can upload that via JTAG, make sure the FPGA's boot mode is also set to "JTAG" via the on-board
"CFG_SET1" DIP switches (`1100`):

```
+-+-+-+-+
|#|#| | | ON
| | |#|#| OFF
+-+-+-+-+
 1 2 3 4
```

OpenFPGALoader (part of the Cologne Chip toolchain) is used to upload the bitstream.

```bash
$ make jtag
```

> [!NOTE]
> Better press the "FPGA_RST1" button before uploading the bitstream. I am not sure why this is required.

### UART Console

UART0 is used as bootloader and system console. Unfortunately, I was not able to make the on-board "debug"
UART. Hence, I used an external USB-UART bridge connected to the board's PMOD port:

```
PMOD front-view:
  ________________________
 /                       /|
+---+---+---+---+---+---+ |
|3.3|GND| 4 | 3 | 2 | 1 | |
+---+---+---+---+---+---+ |
|3.3|GND|10 | 9 | 8 | 7 | |
+---+---+---+---+---+---+/
```

| PMOD pin | Signal   | FPGA pin | Description    |
|:--------:|:--------:|:--------:|:--------------:|
| 1        | `txd_o`  | IO_EA_A4 | UART TX output |
| 2        | `scl_io` | IO_EA_A5 | TWI clock      |
| 7        | `rxd_i`  | IO_EA_B4 | UART RX input  |
| 8        | `sda_io` | IO_EA_B5 | TWI data       |
| GND      | -        | -        | ground         |
| 3.3      | -        | -        | 3.3V output    |

Open a serial terminal using the following configuration: `19200-8-N-1`; linebreak on `/r/n` (carriage
return + newline). When you press the reset button ("FPGA_BUT1") the on-board LED should start flashing
and the bootloader prompt should show up in the terminal:

```
<< NEORV32 Bootloader >>

BLDV: Feb  1 2025
HWV:  0x01110109
CLK:  0x02faf080
MISA: 0x40801104
XISA: 0x00000083
SOC:  0x0003800d
IMEM: 0x00004000
DMEM: 0x00002000

Autoboot in 10s. Press any key to abort.
Aborted.

Available CMDs:
 h: Help
 r: Restart
 u: Upload
 s: Store to flash
 l: Load from flash
 e: Execute
CMD:>
```

### Implementation Reports

> [!NOTE]
> Generated for NEORV32 version v1.11.2.1.

#### Timing

```
Longest Path from Q of Component 724_2 to D-Input of Component 2455/8 Delay: 34765 ps
Maximum Clock Frequency on CLK 3953 (3953/1):   28.76 MHz
```

#### Utilization

```
CPEs                   4188 /  20480  ( 20.4 %)
-----------------------------------------------
  CPE Registers        1770 /  40960  (  4.3 %)
    Flip-flops         1770
    Latches               0

GPIOs                    11 /    162  (  6.8 %)
-----------------------------------------------
  Single-ended           11 /    162  (  6.8 %)
    IBF                   4
    OBF                   5
    TOBF                  0
    IOBF                  2
  LVDS pairs              0 /     81  (  0.0 %)
    IBF                   0
    OBF                   0
    TOBF                  0
    IOBF                  0

GPIO Registers            0 /    324  (  0.0 %)
-----------------------------------------------
  FF_IBF                  0
  FF_OBF                  0
  IDDR                    0
  ODDR                    0

Block RAMs              9.0 /     32  ( 28.1 %)
-----------------------------------------------
  BRAM_20K                2 /     64  (  3.1 %)
  BRAM_40K                7 /     32  ( 21.9 %)
  FIFO_40K                0 /     32  (  0.0 %)

PLLs                      1 /      4  ( 25.0 %)
GLBs                      1 /      4  ( 25.0 %)
SerDes                    0 /      1  (  0.0 %)
```
