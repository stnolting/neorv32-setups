#!/bin/bash
set -ex

export XRAY_DIR=~/osflow/prjxray_git
export NEXTPNR_DIR=~/osflow/nextpnr-xilinx

source "${XRAY_DIR}/utils/environment.sh"

make BOARD=nexys_a7 MinimalBoot GHDL_PLUGIN_MODULE=ghdl

openFPGALoader -b arty ./neorv32_nexys_a7_MinimalBoot.bit
