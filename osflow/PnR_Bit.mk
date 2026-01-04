ifeq ($(DEVICE_SERIES),gowin)
	CONSTRAINTS_ARG ?= --vopt $(CONSTRAINTS_FORMAT)=$(CONSTRAINTS)
else
	CONSTRAINTS_ARG ?= --$(CONSTRAINTS_FORMAT) $(CONSTRAINTS)
endif

${IMPL}.${PNR2BIT_EXT}: $(IMPL).json $(CONSTRAINTS)
	$(NEXTPNR) \
	  $(PNRFLAGS) \
	  $(CONSTRAINTS_ARG) \
	  --json $(IMPL).json \
	  --${NEXTPNR_OUT} $@ 2>&1 | tee nextpnr-report.txt

${IMPL}.bit: ${IMPL}.${PNR2BIT_EXT}
	$(PACKTOOL) $< $@

ifeq ($(DEVICE_SERIES),ecp5)
${IMPL}.svf: ${IMPL}.${PNR2BIT_EXT}
	$(PACKTOOL) $(PACKARGS) --svf $@ $<
endif

ifeq ($(DEVICE_SERIES),gowin)
${IMPL}.fs: ${IMPL}.${PNR2BIT_EXT}
	$(PACKTOOL) $(PACKARGS) -o $@ $<
endif