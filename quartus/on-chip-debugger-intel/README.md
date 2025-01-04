# NEORV32 Test Setup for using Intel FPGA integrated JTAG as On-Chip Debugger

This setup provides a way to use the FPGAs own JTAG connection as on chip debugger with OpenOCD & GDB.
Instead of requiring additional four I/O pins to implement a custom JTAG TAP, the JTAG connection used
to program the FPGA itself can be used within the user design. The basic principle of operation is based
on the excellent blog of [tomverbeure](https://tomverbeure.github.io/2021/10/30/Intel-JTAG-Primitive.html).

Please refer to the blog post for an in-depth explanation of the topic. But basically Intel FPGAs allows the user to use two special ir addresses (10 bit) for their own purpose. USR0 at `0x00c`
and USR1 at `0x00e`. For those (and only those) addresses a user can supply the `tdo` signals that then are
outputted from the FPGA. OpenOCD as debugger can be configured to use those addresses instead of the default RISC-V ones with following commands:

```tcl
riscv set_ir dtmcs 0x00c
riscv set_ir dmi 0x00e
```

The top entity is a modified version of [`neorv32_test_setup_on_chip_debugger.vhd`](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_on_chip_debugger.vhd)
that uses Intel specific entities to get access to the FPGAs own JTAG TAP. An additional modified `dtm` implementation replaces the default `neorv32_debug_dtm` entity, listens for the Intel specific ir addresses and acts as usual translator for DMI access to the core.

* FPGA Board: :books: [Gecko4Education Cyclone-IV E FPGA Board](https://gecko-wiki.ti.bfh.ch/gecko4education:start)
* FPGA: Intel Cyclone-IV E `EP4CE15F23C8`
* Toolchain: Intel Quartus Prime (tested with Quartus Prime 21.1 - Lite Edition)


### NEORV32 Configuration

:information_source: See the original top entity [`neorv32_test_setup_on_chip_debugger.vhd`](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_on_chip_debugger.vhd) for
configuration and entity details.

:warning: The Gecko board is used in university at Bern and you propably won't have access to one. As such the pin mapping is different and needs to be changed in `create_project.tcl` to your according FPGA pin mapping.

* CPU: `rv32imcu_Zicsr` + On-Chip Debugger
* Memory: 16kB instruction memory (internal IMEM), 8kB data memory (internal DMEM), bootloader ROM
* Peripherals: `GPIO`, `MTIME`
* Tested with version [`1.8.0`](https://github.com/stnolting/neorv32/blob/master/CHANGELOG.md)
* Clock: 50MHz from on-board oscillator
* Reset: via on-board button next to seven segment displays
* GPIO output port `gpio_o` (8-bit) connected to the upper-most LED-matrix row


### FPGA Utilization

```
Total logic elements                    3,791 / 15,408 ( 25 % )
Total registers                         1,750 / 17,056 ( 11 % )
Total LABs                              278 / 963 ( 29 % )
Virtual pins                            0
I/O pins                                10 / 344 ( 3 % )
M9Ks                                    30 / 56 ( 54 % )
Total block memory bits                 231,424 / 516,096 ( 45 % )
Total block memory implementation bits  276,480 / 516,096 ( 54 % )
Embedded Multiplier 9-bit elements      0 / 112 ( 0 % )
PLLs                                    0 / 4 ( 0 % )
JTAGs                                   1 / 1 ( 100 % )
CRC blocks                              0 / 1 ( 0 % )
ASMI blocks                             0 / 1 ( 0 % )
Oscillator blocks                       0 / 1 ( 0 % )
Impedance control blocks                0 / 4 ( 0 % )
Average interconnect usage (total/H/V)  10.0% / 9.4% / 10.7%
Peak interconnect usage (total/H/V)     39.7% / 37.3% / 43.1%
```


## How To Run

The `create_project.tcl` TCL script in this directory can be used to create a complete Quartus project.

1. run `quartus_sh -t create_project.tcl` once to generate the Quartus project
2. start Quartus (in GUI mode) and open the `neorv32_on_chip_debugger_intel.qpf` file
3. double click on "Compile Design" in the "Tasks" window. This will synthesize, map and place & route your design and will also generate the actual FPGA bitstream
4. when the process is done open the programmer (for example via "Tools/Programmer") and click "Start" in the programmer window to upload the bitstream to your FPGA
5. open a debug connection with OpenOCD with the command `openocd -f openocd_neorv32_intel.cfg`
6. upload a program or debug existing one as described in section "Debugging with GDB" of the :page_facing_up: [NEORV32 User Guide](https://stnolting.github.io/neorv32/ug/#_debugging_with_gdb)
