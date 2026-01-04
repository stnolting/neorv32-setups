GHDL_FLAGS += --std=08 --workdir=build -Pbuild
GHDL       ?= ghdl
GHDLSYNTH  ?= ghdl
YOSYS      ?= yosys
ICEPACK    ?= icepack
ECPPACK    ?= ecppack
GOWINPACK  ?= gowin_pack
OPENOCD    ?= openocd
COPY       ?= cp -a

DEVICE_SERIES ?= ice40
DEVICE_LIB    ?= $(DEVICE_SERIES)
YOSYSSYNTH    ?= $(DEVICE_SERIES)
NEXTPNR       ?= nextpnr-$(DEVICE_SERIES)

ifeq ($(DEVICE_SERIES),ice40)
YOSYSPIPE          ?= -dsp
CONSTRAINTS_FORMAT ?= pcf
NEXTPNR_OUT        ?= asc
PNR2BIT_EXT        ?= asc
PACKTOOL           ?= $(ICEPACK)
PACKARGS           ?=
else ifeq($(DEVICE_SERIES),gowin)
NEXTPNR            = nextpnr-himbaechel
CONSTRAINTS_FORMAT ?= cst
NEXTPNR_OUT        ?= write
PNR2BIT_EXT        ?= out.json
PACKTOOL           ?= $(GOWINPACK)
PACKARGS           ?= --device $(DEVICE_FAMILY)
else
CONSTRAINTS_FORMAT ?= lpf
NEXTPNR_OUT        ?= textcfg
PNR2BIT_EXT        ?= cfg
PACKTOOL           ?= $(ECPPACK)
PACKARGS           ?= --compress
endif
