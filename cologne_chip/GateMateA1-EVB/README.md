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

Setup the toolchain as noted here: [Cologne Chip Toolchain](https://www.colognechip.com/programmable-logic/gatemate/).
If your yosys tools are not in your `$PATH` then you have to add it to the toolchain commands

```makefile
YOSYS   ?= /your/path/to/yosys
GMPACK  ?= /your/path/to/gmpack
NEXTPNR ?= /your/path/to/nextpnr-himbaechel
OFL     ?= /your/path/to/openFPGALoader
```

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

This will generate the bitstream final file (`neorv32_gatemate.bit`).
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

To write the bitstream to flash you can run this:
```
openFPGALoader -c dirtyJtag -b gatemate_evb_jtag -v -f neorv32_gatemate.bit
```

Afterwards the DIP switches should be set to all zero:
```
+-+-+-+-+
| | | | | ON
|#|#|#|#| OFF
+-+-+-+-+
 1 2 3 4
```
Now your board should boot from flash after the next power-cycle.


### UART Console

UART0 output should now be present on the USB-C connector (for me it's on `/dev/ttyACM0` usually).
Open a serial terminal using the following configuration: `19200-8-N-1`; linebreak on `/r/n` (carriage
return + newline). When you press the reset button ("FPGA_BUT1") the on-board LED should start flashing
and the bootloader prompt should show up in the terminal:

```
NEORV32 Bootloader
build: May  1 2026

Auto-boot in 8s. Press any key to abort.
Aborted.

Type 'h' for help.
CMD:> h
Available CMDs:
h: Help
i: System info
r: Restart
u: Upload via UART
l: SPI flash - load
s: SPI flash - program
e: Start executable
x: Exit
CMD:> i
HWV:  0x01130100
CLK:  0x017D7840
MISA: 0x40801104
XISA: 0x00000000:0x10000083
SOC:  0x000F800D
MISC: 0x59010D0E
```

### TWI Connection

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
| 2        | `scl_io` | IO_EA_A5 | TWI clock      |
| 8        | `sda_io` | IO_EA_B5 | TWI data       |
| GND      | -        | -        | ground         |
| 3.3      | -        | -        | 3.3V output    |

### Implementation Reports

> [!NOTE]
> Generated for NEORV32 version v1.13.1.

#### Timing

```
Info: Max frequency for clock 'clk_sys': 29.45 MHz (PASS at 25.00 MHz)
```

#### Utilization

```
Info: Device utilisation:
Info: 	            USR_RSTN:       0/      1     0%
Info: 	            CPE_COMP:       0/  20480     0%
Info: 	         CPE_CPLINES:      31/  20480     0%
Info: 	               IOSEL:      11/    162     6%
Info: 	                GPIO:      11/    162     6%
Info: 	               CLKIN:       1/      1   100%
Info: 	              GLBOUT:       1/      1   100%
Info: 	                 PLL:       1/      4    25%
Info: 	            CFG_CTRL:       0/      1     0%
Info: 	              SERDES:       0/      1     0%
Info: 	              CPE_LT:    6239/  40960    15%
Info: 	              CPE_FF:    1906/  40960     4%
Info: 	           CPE_RAMIO:     720/  40960     1%
Info: 	            RAM_HALF:      16/     64    25%
```
