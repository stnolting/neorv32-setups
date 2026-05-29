# Cologne Chip GateMate Makefile
# (c) 2024 Cologne Chip, based on the original config.sh
# (c) 2025 S. Nolting, adapted for neorv32-setups

# -----------------------------------------------------------------------------
# project setup
# -----------------------------------------------------------------------------
TOP       = neorv32_gatemate
VHDL_SRC  = $(TOP).vhd
GHDLFLAGS =  --work=neorv32 --warn-no-binding -C
# use new LUT tree approach; do not use CC_MX{8,4}
# https://colognechip.com/programmable-logic/gatemate/gatemate-toolchain-quickstart/
SYNFLAGS  = -luttree -nomx8
NEXTPNR_ROUTER = router2 # recommended by cologne chip
OFLFLAGS  = -c dirtyJtag

# NOTE: For me nextpnr sometimes seemed to get stuck. I experimented a bit with
# the  flags and These seem to work for me:

# - use new experimental parallelised engine for placement refinement
NEXTPNR_FLAGS = --parallel-refine
# - enable experimental timing-driven ripup in router
NEXTPNR_FLAGS += --tmg-ripup

# Timing report can be exported to JSON, if needed:
# TIMING_REPORT = timing.json
# # - write timing and utilization report in JSON format to file
# NEXTPNR_FLAGS += --report $(TIMING_REPORT)
# # - Append detailed net timing data to the JSON report
# NEXTPNR_FLAGS += --detailed-timing-report

# constraints file
CCF = neorv32_gatemate.ccf

# -----------------------------------------------------------------------------
# cologne chip toolchain
# -----------------------------------------------------------------------------
YOSYS   ?= yosys
GMPACK  ?= gmpack
NEXTPNR ?= nextpnr-himbaechel
OFL     ?= openFPGALoader

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
	$(NEXTPNR) -V

synth: $(TOP).json

impl: $(TOP).bit

jtag: $(TOP).bit
	$(OFL) $(OFLFLAGS) $?

$(TOP).json: $(VHDL_SRC)
	$(YOSYS) -m ghdl -ql synth.log -p 'ghdl $(GHDLFLAGS) -C $^ -e $(TOP); opt; synth_gatemate -top $(TOP) $(SYNFLAGS) -json $@'

$(TOP).cfg: $(TOP).json
	$(NEXTPNR) -v --device CCGM1A1 $(NEXTPNR_FLAGS) --json $? \
		-o ccf=$(CCF) -o out=$@ -r --router $(NEXTPNR_ROUTER) --log nextpnr.log

$(TOP).bit: $(TOP).cfg
	$(GMPACK) --input $? --bit $@

clean:
	rm -rf *.json *.cfg *.bit *.log

help:
	@echo "Cologne Chip GateMate Makefile"
	@echo ""
	@echo "Configuration:"
	@echo " TOP           = $(TOP)"
	@echo " GHDLFLAGS     = $(GHDLFLAGS)"
	@echo " SYNFLAGS      = $(SYNFLAGS)"
	@echo " NEXTPNR_FLAGS = $(NEXTPNR_FLAGS)"
	@echo " OFLFLAGS      = $(OFLFLAGS)"
	@echo ""
	@echo "Targets:"
	@echo " help  - show this text"
	@echo " info  - show toolchain version (yosys and nextpnr-himbaechel)"
	@echo " clean - remove all build artifacts"
	@echo " synth - synthesize design (including technology mapping) and generate netlist"
	@echo " impl  - implement design (place and route) and generate bitstream"
	@echo " jtag  - upload bitstream via JTAG"
	@echo " all   - clean + synth + impl"
	@echo ""
