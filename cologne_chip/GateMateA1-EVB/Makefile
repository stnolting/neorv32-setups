# Cologne Chip GateMate Makefile
# (c) 2024 Cologne Chip, based on the original config.sh
# (c) 2025 S. Nolting, adapted for neorv32-setups

# -----------------------------------------------------------------------------
# project setup
# -----------------------------------------------------------------------------
TOP       = neorv32_gatemate
VHDL_SRC  = $(TOP).vhd
GHDLFLAGS = --work=neorv32 --warn-no-binding -C --ieee=synopsys
SYNFLAGS  = -nomx8
PRFLAGS   = -ccf $(TOP).ccf -cCP +uCIO
OFLFLAGS  = -c dirtyJtag
NETLIST   = $(TOP).synth.v

# -----------------------------------------------------------------------------
# cologne chip toolchain
# -----------------------------------------------------------------------------
CCTOOLS = /opt/cc-toolchain
YOSYS   = $(CCTOOLS)/bin/yosys/yosys
PR      = $(CCTOOLS)/bin/p_r/p_r
OFL     = $(CCTOOLS)/bint/openFPGALoader/openFPGALoader

# -----------------------------------------------------------------------------
# neorv32 sources
# -----------------------------------------------------------------------------
NEORV32_HOME  = ../../neorv32
VHDL_SRC     += $(NEORV32_HOME)/rtl/core/*.vhd

# -----------------------------------------------------------------------------
# targets
# -----------------------------------------------------------------------------
.PHONY: help
.DEFAULT_GOAL := help

all: clean synth impl

info:
	$(YOSYS) -V
	$(PR) -h

synth: $(VHDL_SRC)
	$(YOSYS) -ql synth.log -p 'ghdl $(GHDLFLAGS) $^ -e $(TOP); synth_gatemate -top $(TOP) $(SYNFLAGS) -vlog $(NETLIST)'

impl:
	$(PR) -i $(NETLIST) -o $(TOP) $(PRFLAGS) > impl.log

jtag:
	$(OFL) $(OFLFLAGS) $(TOP)_00.cfg

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
	@echo " help  - show this text"
	@echo " info  - show toolchain version (Yosys and P_R)"
	@echo " clean - remove all build artifacts"
	@echo " synth - synthesize design (including technology mapping) and generate netlist"
	@echo " impl  - implement design (place and route) and generate bitstream"
	@echo " jtag  - upload bitstream via JTAG"
	@echo " all   - clean + synth + impl"
	@echo ""
