# Cologne Chip GateMate Makefile
# (c) based on the original config.sh by Cologne Chip
# (c) adapted for neorv32-setups by Stephan Nolting

# -----------------------------------------------------------------------------
# project setup
# -----------------------------------------------------------------------------
TOP       = neorv32_gatemate
VHDL_SRC  = $(TOP).vhd
GHDLFLAGS = --work=neorv32 --warn-no-binding -C --ieee=synopsys
SYNFLAGS  = -nomx8 -retime
PRFLAGS   = -ccf $(TOP).ccf -cCP
OFLFLAGS  = -c dirtyJtag
NETLIST   = $(TOP).synth.v

# -----------------------------------------------------------------------------
# cologne chip toolchain
# -----------------------------------------------------------------------------
CCTOOLS = ../../bin
YOSYS   = $(CCTOOLS)/yosys/yosys
PR      = $(CCTOOLS)/p_r/p_r
OFL     = $(CCTOOLS)/openFPGALoader/openFPGALoader

# -----------------------------------------------------------------------------
# neorv32 sources
# -----------------------------------------------------------------------------
NEORV32_HOME  = ../../neorv32
VHDL_SRC     += $(NEORV32_HOME)/rtl/core/*.vhd $(NEORV32_HOME)/rtl/core/mem/*.default.vhd

# -----------------------------------------------------------------------------
# targets
# -----------------------------------------------------------------------------
.PHONY: help
.DEFAULT_GOAL := help

all: help clean synth impl

info:
	$(YOSYS) -V
	$(PR) -V

synth: $(VHDL_SRC)
	$(YOSYS) -ql synth.log -p 'ghdl $(GHDLFLAGS) $^ -e $(TOP); synth_gatemate -top $(TOP) $(SYNFLAGS) -vlog $(NETLIST)'

impl:
	$(PR) -i $(NETLIST) -o $(TOP) $(PRFLAGS) > impl.log

jtag:
	$(OFL) $(OFLFLAGS) $(TOP)_00.cfg

jtag-flash:
	$(OFL) $(OFLFLAGS) -f --verify $(TOP)_00.cfg

clean:
	@rm -rf $(NETLIST) *.log *_00* *.id *.net *.pathes *.pos *.txt *.refcomp *.refparam *.refwire *.prn

help:
	@echo "Cologne Chip GateMate Makefile"
	@echo ""
	@echo "Configuration:"
	@echo " TOP       = $(TOP)"
	@echo " NETLIST   = $(NETLIST)"
	@echo " CCTOOLS   = $(CCTOOLS)"
	@echo " GHDLFLAGS = $(GHDLFLAGS)"
	@echo " SYNFLAGS  = $(SYNFLAGS)"
	@echo " PRFLAGS   = $(PRFLAGS)"
	@echo " OFLFLAGS  = $(OFLFLAGS)"
	@echo ""
	@echo "Targets:"
	@echo " help     - show this text"
	@echo " info     - show toolchain version (Yosys and P_R)"
	@echo " clean    - remove all build artifacts"
	@echo " synth    - synthesize design (including technology mapping) and generate netlist"
	@echo " impl     - implement design (place and route) and generate bitstream"
	@echo " jtag     - upload bitstream via JTAG"
	@echo " jtag-spi - program bitstream to SPI flash"
	@echo " all      - help + clean + synth + impl"
	@echo ""
