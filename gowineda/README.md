# NEORV32 Gowin EDA Example Setups

## How To Run

The `create_project.tcl` TCL script in the board subdirectories can be used for creating a complete Gowin EDA project and for running the implementation.
If not already available, this script will create a `work` folder in those subdirectories. Assuming that `gw_sh` is on you path, you can run `gw_sh create_project.tcl`. You can also pass arguments like `gw_sh create_project.tcl --project-name myproject --project-path "~/Sources"`. 

Arguments do not work if you are already inside the Gowin shell (e.g. `% source create_project.tcl`), at least not as of version 1.9.9. You can set environment variables instead, like `set nrv_project_name myproject` and `set nrv_project_creation_path "~/Sources"`. Check the source code for all the flags.

### Creating from a shell

Execute the Gowin shell `gw_sh create_project.tcl` from the board subdir.
The project will be created. You can then open the project from the Gowin IDE to synthesise and route, and finally program the device with the Gowin Programmer.

### GUI

As of version 1.9.9, trying to create the project from the Gowin IDE GUI will result in the script stopping as soon as the new project is created, so the project will be missing the VHDL and constraint files. A workaround is possible, explained below.

1. start the Gowin IDE
2. click on the TCL Console text box at the bottom, next to the "%" symbol
3. use the console to navigate to the board's folder. For example `cd somewhere/neord32-setups/gowineda/tang-nano-9k`
4. execute `source create_project.tcl`  —this will create the actual project in the `work` directory. As of version 1.9.9, this will launch a new instance of the Gowin IDE, with the project open.
5. move over to the TCL console on the new Gowin IDE window that just opened
6. execute `set nrv_skip_creation true`
7. execute `source ../create_project.tcl`
8. execute `unset nrv_skip_creation`
9. at this point you can manually run the synthesis and routing, and program the device.

## Programming the Bitstream

1. open the Programmer by clicking on its icon in the toolbar.
2. select the appropriate cable and click save.
  * **note**: under Linux, you must not be running the `ftdi_sio` kernel module for some Gowin programmers to work (e.g. Tang Nano 9K's built-in BL702 microcontroller). To stop this module, run `sudo modprobe -r ftdi_sio`, and "query the cables" again on the programmer software. The port will change from "USB Debugger A/0/0/null" to something like "USB Debugger A/0/4177/null". To restore the board's serial port functionallity, add `ftdi_sio` again: run `sudo modprobe ftdi_sio`. There is no need to unplug the device from the USB port. 
3. select the correct FPGA part number.
4. the .fs bitstream file should be automatically loaded, if not, click on the blank cell below the "FS file" header, and click the ellipsis (...). The file is at `work/impl/pnr/work.fs`.
5. adjust any other settings you want and click the "Program/Configue" icon.
6. at this point you should see the board flashing the LED number 1 (at the top) for a few seconds. Congratulations! This means the processor and bootloader are working.
  * **note**: under Linux, make sure you add the `ftdi_sio` kernel module again, to allow communication with the board. You should see two new serial ports if you run `ls /dev/ttyUSB*`. Use the highest numbered out of the two.
7. use a serial terminal (like :earth_asia: [Tera Term](https://ttssh2.osdn.jp/index.html.en)) to connect to the USB-UART interface using the following configuration:
19200 Baud, 8 data bits, 1 stop bit, no parity bits, no transmission / flow control protocol (raw bytes only), newline on `\r\n` (carriage return & newline)
8. now you can communicate with the bootloader console and upload a new program. Check out the [example programs](https://github.com/stnolting/neorv32/tree/master/sw/example)
and see section "Let's Get It Started" of the :page_facing_up: [NEORV32 data sheet](https://raw.githubusercontent.com/stnolting/neorv32/master/docs/NEORV32.pdf) for further resources.