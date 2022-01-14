GHDL_FLAGS += --std=08
GHDL       ?= ghdl
GHDLSYNTH  ?= ghdl
YOSYS      ?= yosys
ICEPACK    ?= icepack
ECPPACK    ?= ecppack
OPENOCD    ?= openocd
COPY       ?= cp -a
FASM2FRAMES ?= ${XRAY_UTILS_DIR}/fasm2frames.py
DBROOT		?= ${XRAY_DATABASE_DIR}/artix7
FRAMES2BIT  ?= ${XRAY_TOOLS_DIR}/xc7frames2bit


DEVICE_SERIES ?= ice40
DEVICE_LIB    ?= $(DEVICE_SERIES)
YOSYSSYNTH    ?= $(DEVICE_SERIES)
YOSYS_WRITE_JSON ?= -json
NEXTPNR       ?= nextpnr-$(DEVICE_SERIES)

ifeq ($(DEVICE_SERIES),ice40)
YOSYSPIPE          ?= -dsp
CONSTRAINTS_FORMAT ?= pcf
NEXTPNR_OUT        ?= asc
PNR2BIT_EXT        ?= asc
PACKTOOL           ?= $(ICEPACK)
PACKARGS           ?=
else ifeq ($(DEVICE_SERIES),xilinx)
CONSTRAINTS_FORMAT ?= xdc
NEXTPNR_OUT        ?= fasm
PNR2BIT_EXT        ?= fasm
FRAMETOOL          ?= $(FASM2FRAMES)
FRAMEARGS          ?= --db-root $(DBROOT) --part $(DEVICE_PART)
PACKTOOL           ?= $(FRAMES2BIT)
PACKARGS           ?= --part_file $(DBROOT)/$(DEVICE_PART)/part.yaml --part_name $(DEVICE_PART) 
YOSYS_WRITE_JSON   = ; write_json
NEXTPNR       	   = $(NEXTPNR_DIR)/nextpnr-$(DEVICE_SERIES)
else
CONSTRAINTS_FORMAT ?= lpf
NEXTPNR_OUT        ?= textcfg
PNR2BIT_EXT        ?= cfg
PACKTOOL           ?= $(ECPPACK)
PACKARGS           ?= --compress
endif
