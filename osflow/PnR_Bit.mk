${IMPL}.${PNR2BIT_EXT}: $(IMPL).json $(CONSTRAINTS)
	$(NEXTPNR) \
	  $(PNRFLAGS) \
	  --$(CONSTRAINTS_FORMAT) $(CONSTRAINTS) \
	  --json $(IMPL).json \
	  --${NEXTPNR_OUT} $@ 2>&1 | tee nextpnr-report.txt

ifeq ($(DEVICE_SERIES),xilinx)
${IMPL}.bit: ${IMPL}.frames
	$(PACKTOOL) $(PACKARGS) --frm_file $< --output_file $@ 
${IMPL}.frames: ${IMPL}.${PNR2BIT_EXT}
	$(FRAMETOOL) $(FRAMEARGS) $< > $@
else
${IMPL}.bit: ${IMPL}.${PNR2BIT_EXT}
	$(PACKTOOL) $< $@
endif

ifeq ($(DEVICE_SERIES),ecp5)
${IMPL}.svf: ${IMPL}.${PNR2BIT_EXT}
	$(PACKTOOL) $(PACKARGS) --svf $@ $<
endif
