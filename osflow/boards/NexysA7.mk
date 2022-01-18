.PHONY: all

all: bit
	echo "! Built $(IMPL) for $(BOARD)"

# Use openFPGALoader to load the Bitstream to the target.
load: $(IMPL).bit
	openFPGALoader -b arty $<

.PHONY: load