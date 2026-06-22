# NEORV32 Test Setup for using Altera FPGA integrated JTAG as On-Chip Debugger

This setup provides a way to use the FPGA's own JTAG connection as an on-chip debugger with OpenOCD & GDB.
Instead of requiring four additional I/O pins to implement a custom JTAG TAP, the JTAG connection used
to program the FPGA itself can be used within the user design. The basic principle of operation is based
on the excellent blog post by [tomverbeure](https://tomverbeure.github.io/2021/10/30/Intel-JTAG-Primitive.html).

Please refer to the blog post for an in-depth explanation of the topic. But basically Altera FPGAs allow the user to use two special ir addresses (10-bit) for their own purpose: USR0 at `0x00c`
and USR1 at `0x00e`. For those (and only those) addresses, a user can supply the `tdo` signals that are then
output from the FPGA. OpenOCD as debugger can be configured to use those addresses instead of the default RISC-V ones with the following commands:

```tcl
riscv set_ir dtmcs 0x00c
riscv set_ir dmi 0x00e
```

The top entity is a modified version of [`neorv32_test_setup_on_chip_debugger.vhd`](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_on_chip_debugger.vhd)
that uses Altera-specific entities to get access to the FPGA's own JTAG TAP. An additional modified `dtm` implementation replaces the default `neorv32_debug_dtm` entity, listens for the Altera-specific ir addresses and acts as the usual translator for DMI access to the core.

* FPGA Board: :books: [Gecko4Education Cyclone-IV E FPGA Board](https://gecko4education.ti.bfh.ch/gecko4education/index.html)
* FPGA: Altera Cyclone-IV E `EP4CE15F23C8`
* Toolchain: Altera Quartus Prime (tested with Quartus Prime 25.1 - Lite Edition)


### NEORV32 Configuration

:information_source: See the original top entity [`neorv32_test_setup_on_chip_debugger.vhd`](https://github.com/stnolting/neorv32/blob/master/rtl/test_setups/neorv32_test_setup_on_chip_debugger.vhd) for
configuration and entity details.

:warning: The Gecko board is used at the University of Bern, so you probably won't have access to one. As such the pin mapping is different and needs to be changed in `create_project.tcl` to match your FPGA's pin mapping.

* CPU: `rv32imcu_Zicsr` + On-Chip Debugger
* Memory: 16kB instruction memory (internal IMEM), 8kB data memory (internal DMEM), bootloader ROM
* Peripherals: `GPIO`, `CLINT`, `UART`
* Tested with version [`1.13.1`](https://github.com/stnolting/neorv32/blob/master/CHANGELOG.md)
* Clock: 50MHz from on-board oscillator
* Reset: via on-board button next to seven-segment displays
* GPIO output port `gpio_o` (8-bit) connected to the uppermost LED-matrix row


### FPGA Utilization

```
+--------------------------------------------------------------------------------------+
; Flow Summary                                                                         ;
+------------------------------------+-------------------------------------------------+
; Flow Status                        ; Successful - Sun Jun 21 13:56:29 2026           ;
; Quartus Prime Version              ; 25.1std.0 Build 1129 10/21/2025 SC Lite Edition ;
; Revision Name                      ; neorv32_on_chip_debugger_altera                 ;
; Top-level Entity Name              ; neorv32_on_chip_debugger_altera                 ;
; Family                             ; Cyclone IV E                                    ;
; Device                             ; EP4CE15F23C8                                    ;
; Timing Models                      ; Final                                           ;
; Total logic elements               ; 4,032 / 15,408 ( 26 % )                         ;
;     Total combinational functions  ; 3,738 / 15,408 ( 24 % )                         ;
;     Dedicated logic registers      ; 2,019 / 15,408 ( 13 % )                         ;
; Total registers                    ; 2019                                            ;
; Total pins                         ; 12 / 344 ( 3 % )                                ;
; Total virtual pins                 ; 0                                               ;
; Total memory bits                  ; 230,400 / 516,096 ( 45 % )                      ;
; Embedded Multiplier 9-bit elements ; 0 / 112 ( 0 % )                                 ;
; Total PLLs                         ; 0 / 4 ( 0 % )                                   ;
+------------------------------------+-------------------------------------------------+
```


## How To Run

The `create_project.tcl` TCL script in this directory can be used to create a complete Quartus project.

1. Run `quartus_sh -t create_project.tcl` once to generate the Quartus project
2. Start Quartus (in GUI mode) and open the `neorv32_on_chip_debugger_altera.qpf` file
3. Double-click on "Compile Design" in the "Tasks" window. This will synthesize, map and place & route your design and will also generate the actual FPGA bitstream
4. When the process is done, open the programmer (for example via "Tools/Programmer") and click "Start" in the programmer window to upload the bitstream to your FPGA
5. Open a debug connection with OpenOCD with the command `openocd -f openocd_neorv32_altera.cfg`
6. Upload a program or debug an existing one as described in section "Debugging with GDB" of the :page_facing_up: [NEORV32 User Guide](https://stnolting.github.io/neorv32/ug/#_debugging_with_gdb)
