# Exemplary NEORV32 Setups and Projects

[![Containers](https://img.shields.io/github/actions/workflow/status/stnolting/neorv32-setups/Containers.yml?branch=main&longCache=true&style=flat-square&label=Containers&logo=Github%20Actions&logoColor=fff)](https://github.com/stnolting/neorv32-setups/actions?query=workflow%3AContainers)
[![Implementation](https://img.shields.io/github/actions/workflow/status/stnolting/neorv32-setups/Implementation.yml?branch=main&longCache=true&style=flat-square&label=Implementation&logo=Github%20Actions&logoColor=fff)](https://github.com/stnolting/neorv32-setups/actions?query=workflow%3AImplementation)
[![License](https://img.shields.io/github/license/stnolting/neorv32-setups?longCache=true&style=flat-square&label=License)](https://github.com/stnolting/neorv32-setups/blob/main/LICENSE)

* [**Community Projects** (hardware / software)](#community-projects)
* [**Setups using Commercial Toolchains** (FPGA setups)](#setups-using-commercial-toolchains)
* [**Setups using Open-Source Toolchains** (FPGA setups)](#setups-using-open-source-toolchains)
* [Adding Your Project or Setup](#ADDING-YOUR-PROJECT-OR-SETUp)
* [Setup-Specific NEORV32 Software Framework Modifications](#setup-specific-neorv32-software-framework-modifications)

This repository provides community projects as well as exemplary setups for different FPGAs, platforms, boards
and toolchains for the [**NEORV32 RISC-V Processor**](https://github.com/stnolting/neorv32).
Project maintainers may make pull requests against this repository to add or link their setups and projects.

> [!TIP]
> **Ready-to-use bitstreams** for the provided _open source toolchain-based setups_ are available via the assets of the[Implementation Workflow](https://github.com/stnolting/neorv32-setups/actions/workflows/Implementation.yml).


## Community Projects

This list shows projects that focus on custom hard- or software modifications, specific applications, etc.

| Link | Description | Author(s) |
|:-----|:------------|:----------|
| :earth_africa: [github.com/motius](https://github.com/motius/neorv32/tree/add-custom-crc32-module) | **tutorial:** custom CRC32 processor module for the nexys-a7 boards | [motius](https://github.com/motius) ([ikstvn](https://github.com/ikstvn), [turbinenreiter](https://github.com/turbinenreiter)) |
| :earth_africa: [neorv32-examples](https://github.com/emb4fun/neorv32-examples) | NEORV32 setups/projects for different Intel/Terasic boards | [emb4fun](https://github.com/emb4fun) |
| :earth_africa: [neorv32-xmodem-bootloader](https://www.emb4fun.de/riscv/neorv32xboot/index.html) | A XModem Bootloader for the DE0-Nano board | [emb4fun](https://github.com/emb4fun) |
| :earth_africa: [neorv32-xip-bootloader](https://github.com/betocool-prog/neorv32-xip-bootloader) | A XIP (eXecute In Place) Bootloader for the NEORV32| [betocool-prog](https://github.com/betocool-prog) |


## Setups using Commercial Toolchains

The setups using commercial toolchains provide pre-configured project files that can be opened with the according FPGA tools.

| Setup | Toolchain | Board | FPGA | Author(s) |
|:------|:----------|:------|:-----|:----------|
| :file_folder: [`de0-nano-test-setup`](https://github.com/stnolting/neorv32-setups/tree/main/quartus/de0-nano-test-setup) | Intel Quartus Prime | [Terasic DE0-Nano](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=139&No=593)                     | Intel Cyclone IV `EP4CE22F17C6N`          | [stnolting](https://github.com/stnolting) |
| :file_folder: [`de10-nano-test-setup`](https://github.com/stnolting/neorv32-setups/tree/main/quartus/de10-nano-test-setup) | Intel Quartus Prime | [Terasic DE10-Nano](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=167&No=1046#contents)                     | Intel Cyclone V `5CSEBA6U23I7`          | [provoostkris](https://github.com/provoostkris) |
| :file_folder: [`de0-nano-test-setup-qsys`](quartus/de0-nano-test-setup-qsys) | Intel Quartus Prime | [Terasic DE0-Nano](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=139&No=593)                     | Intel Cyclone IV `EP4CE22F17C6N`          | [torerams](https://github.com/torerams) |
| :file_folder: [`de0-nano-test-setup-avalonmm`](quartus/de0-nano-test-setup-avalonmm-wrapper) | Intel Quartus Prime | [Terasic DE0-Nano](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=139&No=593)                     | Intel Cyclone IV `EP4CE22F17C6N`          | [torerams](https://github.com/torerams) |
| :file_folder: [`terasic-cyclone-V-gx-starter-kit-test-setup`](https://github.com/stnolting/neorv32-setups/tree/main/quartus/terasic-cyclone-V-gx-starter-kit-test-setup) | Intel Quartus Prime | [Terasic Cyclone-V GX Starter Kit](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=167&No=830) | Intel Cyclone V `5CGXFC5C6F27C7N` | zs6mue |
| :file_folder: [`UPduino_v3`](https://github.com/stnolting/neorv32-setups/tree/main/radiant/UPduino_v3)                   | Lattice Radiant     | [tinyVision.ai Inc. UPduino `v3.0`](https://www.tindie.com/products/tinyvision_ai/upduino-v30-low-cost-lattice-ice40-fpga-board/) | Lattice iCE40 UltraPlus `iCE40UP5K-SG48I` | [stnolting](https://github.com/stnolting) |
| :file_folder: [`iCEBreaker`](https://github.com/stnolting/neorv32-setups/tree/main/radiant/iCEBreaker)                   | Lattice Radiant     | [iCEBreaker @ GitHub](https://github.com/icebreaker-fpga/icebreaker)                                                              | Lattice iCE40 UltraPlus `iCE40UP5K-SG48I` | [stnolting](https://github.com/stnolting) |
| :file_folder: [`arty-a7-35-test-setup`](https://github.com/stnolting/neorv32-setups/tree/main/vivado/arty-a7-test-setup) | Xilinx Vivado       | [Digilent Arty A7-35](https://reference.digilentinc.com/reference/programmable-logic/arty-a7/start)                               | Xilinx Artix-7 `XC7A35TICSG324-1L`        | [stnolting](https://github.com/stnolting) |
| :file_folder: [`nexys-a7-test-setup`](https://github.com/stnolting/neorv32-setups/tree/main/vivado/nexys-a7-test-setup)  | Xilinx Vivado       | [Digilent Nexys A7](https://reference.digilentinc.com/reference/programmable-logic/nexys-a7/start)                                | Xilinx Artix-7 `XC7A50TCSG324-1`          | [AWenzel83](https://github.com/AWenzel83) |
| :file_folder: [`nexys-a7-test-setup`](https://github.com/stnolting/neorv32-setups/tree/main/vivado/nexys-a7-test-setup)  | Xilinx Vivado       | [Digilent Nexys 4 DDR](https://reference.digilentinc.com/reference/programmable-logic/nexys-4-ddr/start)                          | Xilinx Artix-7 `XC7A100TCSG324-1`         | [AWenzel83](https://github.com/AWenzel83) |
| :file_folder: [`z7-nano-test-setup`](https://github.com/stnolting/neorv32-setups/tree/main/vivado/z7-nano-test-setup)  | Xilinx Vivado       | [Microphase Z7 Nano FPGA Board](https://github.com/MicroPhase/fpga-docs/blob/master/schematic/Z7-NANO_R21.pdf)                              | Xilinx ZynQ 7000 `c7z020clg400-2`        | [provoostkris](https://github.com/provoostkris) |
| :file_folder: [`on-chip-debugger-intel`](https://github.com/stnolting/neorv32-setups/tree/main/quartus/on-chip-debugger-intel) | Intel Quartus Prime | [Gecko4Education](https://gecko-wiki.ti.bfh.ch/gecko4education:start)                                                       | Intel Cyclone IV E `EP4CE15F23C8`         | [NikLeberg](https://github.com/NikLeberg) |
| :file_folder: [`tang-nano-9k`](https://github.com/stnolting/neorv32-setups/tree/main/gowineda/tang-nano-9k)              | Gowin EDA           | [Sipeed Tang Nano 9K](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html)                                         | Gowin LittleBee GW1NR-9 `GW1NR-LV9QN88PC6/I5` | [IvanVeloz](https://github.com/IvanVeloz)
| :file_folder: [`tang-nano-20k`](https://github.com/stnolting/neorv32-setups/tree/main/gowineda/tang-nano-20k)              | Gowin EDA           | [Sipeed Tang Nano 20K](https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/nano-20k.html)                                         | Gowin Morningside GW2A-18 `GW2AR-LV18QN88C8/I7` | [duvitech-llc](https://github.com/duvitech-llc)


## Setups using Open-Source Toolchains

Most OSS setups using open-source toolchains are located in the
[`osflow`](https://github.com/stnolting/neorv32-setups/tree/main/osflow) folder.
See the [README](https://github.com/stnolting/neorv32-setups/blob/main/osflow/README.md)
there for more information how to run a specific setup and how to add new targets.

| Setup | Toolchain | Board | FPGA | Author(s) |
|:------|:----------|:------|:-----|:----------|
| :file_folder: [`UPDuino-v3.0`](https://github.com/stnolting/neorv32-setups/tree/main/osflow) | GHDL, Yosys, nextPNR | [UPduino v3.0](https://www.tindie.com/products/tinyvision_ai/upduino-v30-low-cost-lattice-ice40-fpga-board/) | Lattice iCE40 UltraPlus `iCE40UP5K-SG48I` | [tmeissner](https://github.com/tmeissner) |
| :file_folder: [`FOMU`](https://github.com/stnolting/neorv32-setups/tree/main/osflow)        | GHDL, Yosys, nextPNR | [FOMU](https://tomu.im/fomu.html)                                                                             | Lattice iCE40 UltraPlus `iCE40UP5K-SG48I` | [umarcor](https://github.com/umarcor) |
| :file_folder: [`iCESugar`](https://github.com/stnolting/neorv32-setups/tree/main/osflow)    | GHDL, Yosys, nextPNR | [iCESugar](https://github.com/wuxx/icesugar/blob/master/README_en.md)                                         | Lattice iCE40 UltraPlus `iCE40UP5K-SG48I` | [umarcor](https://github.com/umarcor) |
| :file_folder: [`AlhambraII`](https://github.com/stnolting/neorv32-setups/tree/main/osflow)  | GHDL, Yosys, nextPNR | [AlhambraII](https://alhambrabits.com/alhambra/)                                                              | Lattice iCE40HX4K                         | [zipotron](https://github.com/zipotron) |
| :file_folder: [`Orange Crab`](https://github.com/stnolting/neorv32-setups/tree/main/osflow) | GHDL, Yosys, nextPNR | [Orange Crab](https://github.com/gregdavill/OrangeCrab)                                                       | Lattice ECP5-25F                          | [umarcor](https://github.com/umarcor), [jeremyherbert](https://github.com/jeremyherbert) |
| :file_folder: [`ULX3S`](https://github.com/stnolting/neorv32-setups/tree/main/osflow)       | GHDL, Yosys, nextPNR | [ULX3S](https://radiona.org/ulx3s/)                                                                           | Lattice ECP5 `LFE5U-85F-6BG381C`          | [zipotron](https://github.com/zipotron) |
| :file_folder: [`GateMateA1-EVB`](https://github.com/stnolting/neorv32-setups/tree/main/cologne_chip/GateMateA1-EVB) | GHDL, Yosys, CC P_R | [GateMateA1-EVB(-2M)](https://www.olimex.com/Products/FPGA/GateMate/GateMateA1-EVB/)             | Cologne Chip GateMate `CCGM1A1`           | [stnolting](https://github.com/stnolting) |
| :file_folder: ChipWhisperer [`iCE40CW312`](https://github.com/stnolting/neorv32-setups/tree/main/osflow) | GHDL, Yosys, nextPNR | [CW312T_ICE40UP](https://github.com/newaetech/chipwhisperer-target-cw308t/tree/main/CW312T_ICE40UP) | Lattice iCE40 UltraPlus `iCE40UP5K-UWG30` | [colinoflynn](https://github.com/colinoflynn) |
| :earth_africa: [`ULX3S-SDRAM`](https://github.com/zipotron/neorv32-complex-setups)          | GHDL, Yosys, nextPNR | [ULX3S](https://radiona.org/ulx3s/)                                                                           | Lattice ECP5 `LFE5U-85F-6BG381C`          | [zipotron](https://github.com/zipotron) |


------------------------------------------------------


### Adding Your Project or Setup

Please respect the following guidelines if you'd like to add or link your setup/project to the list:

* check out the project's [code of conduct](https://github.com/stnolting/neorv32-setups/tree/master/CODE_OF_CONDUCT.md)
* for FPGA- / board- / toolchain-specific **setups**:
  * a "setup" is a wrapped (and maybe script-aided) implementation of the NEORV32 processor for a certain FPGA/board/toolchain
  * add a link if the board you are using provides online documentation or can be purchased somewhere
  * use the :file_folder: emoji (`:file_folder:`) if the setup is located in this repository; use the :earth_africa:
emoji (`:earth_africa:`) if it is a link to your local project
  * please add a `README.md` file to give some brief information about the setup and a `.gitignore` file to keep things clean
  * for local setups you can add your setup to the [implementation](https://github.com/stnolting/neorv32-setups/blob/main/.github/generate-job-matrix.py)
GitHub actions workflow to automatically generate up-to-date bitstreams for your setup
* for **projects**:
  * provide a link to your project (use the :earth_africa: (`:earth_africa:`) emoji)
  * provide a short description
  * further information should be provided by a project-local README


### Setup-Specific NEORV32 Software Framework Modifications

In order to use the features provided by the setups, minor *optional* changes can be made to the default NEORV32 setup.

* To change the default data memory size take a look at the User Guide section
[_General Software Framework Setup_](https://stnolting.github.io/neorv32/ug/#_general_software_framework_setup)
* To modify the SPI flash base address for storing/booting software application see User Guide section
[_Customizing the Internal Bootloader_](https://stnolting.github.io/neorv32/ug/#_customizing_the_internal_bootloader)
