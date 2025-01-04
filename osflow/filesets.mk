# read default SoC file-list file
NEORV32_HOME = ../neorv32
NEORV32_SOC_FILE = $(shell cat $(NEORV32_HOME)/rtl/file_list_soc.f) 
NEORV32_CORE_SRC = $(subst NEORV32_RTL_PATH_PLACEHOLDER, $(NEORV32_HOME)/rtl, $(NEORV32_SOC_FILE))

# Before including this partial makefile, NEORV32_MEM_SRC needs to be set
# (containing two VHDL sources: one for IMEM and one for DMEM)

NEORV32_SRC := $(NEORV32_CORE_SRC) ${NEORV32_MEM_SRC} ${NEORV32_MEM_SRC_EXTRA} ${NEORV32_CORE_SRC_EXTRA}
NEORV32_VERILOG_ALL := ${NEORV32_VERILOG_SRC} ${NEORV32_VERILOG_SRC_EXTRA}

ICE40_SRC := \
  devices/ice40/sb_ice40_components.vhd

ECP5_SRC := \
  devices/ecp5/ecp5_components.vhd

ifeq ($(DEVICE_SERIES),ecp5)
DEVICE_SRC := ${ECP5_SRC}
else
DEVICE_SRC := ${ICE40_SRC}
endif

# Optionally NEORV32_VERILOG_SRC can be set to a list of Verilog sources
