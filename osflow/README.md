# Exemplary FPGA Board Setups - Using Open Source Toolchains

This folder provides the infrastructure for generating bitstream for various FPGAs using
open-source toolchains. Synthesis is based on [ghdl-yosys-plugin](https://github.com/ghdl/ghdl-yosys-plugin).

:information_source: Note that the provided setups just implement very basic SoC configurations.
These setups are intended as minimal examples (how to synthesize the processor) for a given FPGA + board,
that can be used as starting point to build more complex user-defined SoCs.


## Folder Structure

* `constraints/`: submoduled [hdl/constraints](https://github.com/hdl/constraints), contains physical constraints and
  board data.
* `osflow/`:
  * `.`: Main makefile (main entry point) and partial-makefiles for synthesis, place & route and bitstream generation.
  * `boards`: board-specific _partial makefiles_ (used by main makefile "`Makefile`") for generating bitstreams.
  * `board_top`: board-specific top entities (board wrappers; may include FPGA-specific modules).
     See [hdl.github.io/constraints: Usage](https://hdl.github.io/constraints/Usage.html).
  * `constraints`: *local* physical constraints (mainly pin mappings).
  * `devices`: FPGA-specific primitives and optimized processor modules (such as memories).


## Prerequisites

The Makefiles in this subdir require the following tools:

* [GHDL](https://hdl.github.io/awesome/items/ghdl/)
* [Yosys](https://hdl.github.io/awesome/items/yosys/)
* [Nextpnr](https://hdl.github.io/awesome/items/nextpnr/)

Moreover, depending on the target board and/or device, the following are used:

* [Icestorm](https://hdl.github.io/awesome/items/icestorm/): for Lattice's ICE40 family devices.
* [Project Trellis](https://hdl.github.io/awesome/items/prjtrellis/): for Lattice's ECP5 family devices.
* [Device Firmware Upgrade Utilities (dfu-util) ](https://hdl.github.io/awesome/items/dfu-util/): for uploading bitstreams to Fomu.

On the software side, a RISC-V GCC toolchain is required in order to compile C sources.

As listed in [hdl/packages](https://github.com/hdl/packages), there are multiple alternatives to install/setup the
tools.
The makefiles in this subdir are agnostic to the installation procedure.
Any solution which makes them available in the PATH is suitable.
Moreover, if necessary, command names can be overriden through [tools.mk](tools.mk).

In the CI workflow of this repository, two tool setup procedures are showcased:

* On `ubuntu-latest`, an all-in-one GNU/Linux container based on `impl` from
  [hdl.github.io/containers](https://hdl.github.io/containers), which includes all the required tools.
  That works on Linux, Windows or macOS hosts.
* On `windows-latest`, upstream [MSYS2](https://www.msys2.org/) packages are used.
  See [hdl.github.io/MINGW-packages](https://hdl.github.io/MINGW-packages/).


## How To Run

The `Makefile` in this folder is the main entry point.
To run the whole process of synthesis, place & route and bitstream generation run:

**Prototype:**
```sh
make BOARD=<FPGA_board> <System_Top_HDL>
```

**Example:**
```sh
make BOARD=Fomu Minimal
```

where:

* `<FPGA_board>` specifies the actual FPGA board and implicitly sets the FPGA type. The currently supported FPGA board
  targets are listed in the `boards/` folder where each partial-makefile corresponds to a supported platform.

* `<System_Top_HDL>` is used to define the actual SoC top. Available SoCs are located in
  [`rtl/processor_templates`](https://github.com/stnolting/neorv32/tree/master/rtl/processor_templates).

The default tasks are `clean *.bit`.
However, users can override then through `TASK`.
For instance, the following command will upload the bitstream to the board after building it:

```sh
make BOARD=Fomu TASK=load Minimal
```

## Porting to a new FPGA or Board

This section illustrates how to add a new basic setup for a specific FPGA board.
This tutorial uses the iCEBreaker "MinimalBoot" setup as reference.

#### 1. Setup a board- and FPGA-specific top entity

1. Write a new top design unit that instantiates one of the provided processor templates from
   [`rtl/processor_templates`](https://github.com/stnolting/neorv32/tree/master/rtl/processor_templates).
   This new top unit can be a Verilog or VHDL file.

2. _Optional:_ You can also include FPGA-specific primitives like PLLs or block RAMs (but keep it simple).
   These components need to be added to a FPGA-specific library in [`devices`](https://github.com/stnolting/neorv32-setups/tree/main/osflow/devices).

3. Try to keep the external IO at a minimum even if the targeted FPGA boards provides cool features.
   Besides of clock and reset you need to add at least one kind of IO interface such as a UART, GPIO or PWM.

4. Give your new top entity file a specific name that includes the board's name and the instantiated processor template.
   The name scheme is `neorv32_[board-name]_BoardTop_[template-name].[v/vhd]`.

5. Put this file in `board_tops`.

6. Take a look at the iCEBreaker MinimalBoot top entity as a reference:
   [`board_tops/neorv32_iCEBreaker_BoardTop_MinimalBoot.vhd`](https://github.com/stnolting/neorv32-setups/blob/main/osflow/board_tops/neorv32_iCEBreaker_BoardTop_MinimalBoot.vhd)

#### 2. Pin mapping

A constraints file is required to define the mapping between your top unit's IO and the FPGA's physical pins.
The recommended approach is to check whether the desired board and the required constraints file(s) are included in [hdl/constraints](https://github.com/hdl/constraints). Otherwise, contributing them is suggested.

Alternatively, you can add a *local* constraints file in subdir [constraints](constraints):

1. Name the new constraints file according to the board `[board-name].pcf`.

2. You can add _all_ of the FPGA's physical pins even though just a subset is used by the new setup.

3. Take a look at the iCEBreaker pin mapping as a reference:
[`iCEBreaker.pcf`](https://github.com/hdl/constraints/blob/main/board/iCEBreaker/constraints.pcf)

#### 3. Adding a board-specific makefile

1. Add a board-specific partial makefile to the `boards` folder.
   Name it according to the board `[board-name].mk`.

2. The makefile must contain (at least) one target to build the final bitstream:

```makefile
.PHONY: all

all: bit
	echo "! Built $(IMPL) for $(BOARD)"
```

3. Take a look at the iCEBreaker pin mapping as a reference:
   [`boards/iCEBreaker.mk`](https://github.com/stnolting/neorv32-setups/blob/main/osflow/boards/iCEBreaker.mk)

#### 4. Adding a new target to `index.mk`

1. Add a new conditional section to the boards management makefile `boards/index.mk`.

2. This board-specific section sets variables that are required to run synthesis, mapping, place & route and bitstream generation:
   * `CONSTRAINTS` defines the physical pin mapping file
   * `PNRFLAGS` defines the FPGA-specific flags for mapping and place & route
   * `IMPL` defines the setup's implementation name

```makefile
ifeq ($(BOARD),iCEBreaker)
$(info Setting constraints and implementation args for BOARD iCEBreaker)

CONSTRAINTS ?= $(PCF_PATH)/$(BOARD).pcf
PNRFLAGS    ?= --up5k --package sg48 --ignore-loops --timing-allow-fail
IMPL        ?= neorv32_$(BOARD)_$(ID)

endif
```

Note that the definition of `CONSTRAINTS` depends on the location of the constraints file (*submoduled* or *local*).

#### 5. Adding a new target to the main makefile

1. As final step, add the new setup to the main osflow makefile `Makefile`.

2. Use the board's name to create a new makefile target.
   * The new target should set the final bitstream's name using the `BITSTREAM` variable.
   * Alternative _memory_ HDL sources like FPGA-optimized modules can be set using the `NEORV32_MEM_SRC` variable.
   * If the board name contains symbols that cannot be used in VHDL identifiers, override the `TOP` variable. See, for instance, `iCESugar-v1.5` or `UPDuino-v3.0`.

```makefile
iCEBreaker:
	$(eval BITSTREAM ?= neorv32_$(BOARD)_$(DESIGN).bit)
	$(eval NEORV32_MEM_SRC ?= devices/ice40/neorv32_imem.ice40up_spram.vhd devices/ice40/neorv32_dmem.ice40up_spram.vhd)
	$(MAKE) \
	  BITSTREAM="$(BITSTREAM)" \
	  NEORV32_MEM_SRC="$(NEORV32_MEM_SRC)" \
	  run
```

#### 6. _Optional:_ Add the new setup to the automatic "Implementation" github workflow

If you like, you can add the new setup to the automatic build environment of the project.
The project's "Implementation" workflow will generate bitstreams for all configured osflow setups on every repository push.
This is used to check for regressions and also to provide up-to-date bitstreams that can be used right away.

1. Add the new setup to the job matrix file `.github/generate-job-matrix.py`.

```python
{
  'board': 'iCEBreaker',
  'design': 'MinimalBoot',
  'bitstream': 'neorv32_iCEBreaker_MinimalBoot.bit'
},
```
