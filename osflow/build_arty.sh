#!/bin/bash
set -ex

export XRAY_DIR=/opt/prjxray
export NEXTPNR_DIR=/opt/nextpnr-xilinx

source "${XRAY_DIR}/utils/environment.sh"

make BOARD=nexys-a7 MinimalBoot GHDL_PLUGIN_MODULE=ghdl

openFPGALoader -b arty ./neorv32_nexys_a7_MinimalBoot.bit
