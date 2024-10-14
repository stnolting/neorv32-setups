NEORV32_CORE_SRC :=                                 \
  ../neorv32/rtl/core/neorv32_package.vhd           \
  ../neorv32/rtl/core/neorv32_sys.vhd               \
  ../neorv32/rtl/core/neorv32_clockgate.vhd         \
  ../neorv32/rtl/core/neorv32_fifo.vhd              \
  ../neorv32/rtl/core/neorv32_cpu_decompressor.vhd  \
  ../neorv32/rtl/core/neorv32_cpu_control.vhd       \
  ../neorv32/rtl/core/neorv32_cpu_regfile.vhd       \
  ../neorv32/rtl/core/neorv32_cpu_cp_shifter.vhd    \
  ../neorv32/rtl/core/neorv32_cpu_cp_muldiv.vhd     \
  ../neorv32/rtl/core/neorv32_cpu_cp_bitmanip.vhd   \
  ../neorv32/rtl/core/neorv32_cpu_cp_fpu.vhd        \
  ../neorv32/rtl/core/neorv32_cpu_cp_cfu.vhd        \
  ../neorv32/rtl/core/neorv32_cpu_cp_cond.vhd       \
  ../neorv32/rtl/core/neorv32_cpu_cp_crypto.vhd     \
  ../neorv32/rtl/core/neorv32_cpu_alu.vhd           \
  ../neorv32/rtl/core/neorv32_cpu_lsu.vhd           \
  ../neorv32/rtl/core/neorv32_cpu_pmp.vhd           \
  ../neorv32/rtl/core/neorv32_cpu.vhd               \
  ../neorv32/rtl/core/neorv32_bus.vhd               \
  ../neorv32/rtl/core/neorv32_cache.vhd             \
  ../neorv32/rtl/core/neorv32_dma.vhd               \
  ../neorv32/rtl/core/neorv32_boot_rom.vhd          \
  ../neorv32/rtl/core/neorv32_xip.vhd               \
  ../neorv32/rtl/core/neorv32_xbus.vhd              \
  ../neorv32/rtl/core/neorv32_cfs.vhd               \
  ../neorv32/rtl/core/neorv32_sdi.vhd               \
  ../neorv32/rtl/core/neorv32_gpio.vhd              \
  ../neorv32/rtl/core/neorv32_wdt.vhd               \
  ../neorv32/rtl/core/neorv32_mtime.vhd             \
  ../neorv32/rtl/core/neorv32_uart.vhd              \
  ../neorv32/rtl/core/neorv32_spi.vhd               \
  ../neorv32/rtl/core/neorv32_twi.vhd               \
  ../neorv32/rtl/core/neorv32_pwm.vhd               \
  ../neorv32/rtl/core/neorv32_trng.vhd              \
  ../neorv32/rtl/core/neorv32_neoled.vhd            \
  ../neorv32/rtl/core/neorv32_xirq.vhd              \
  ../neorv32/rtl/core/neorv32_gptmr.vhd             \
  ../neorv32/rtl/core/neorv32_onewire.vhd           \
  ../neorv32/rtl/core/neorv32_slink.vhd             \
  ../neorv32/rtl/core/neorv32_crc.vhd               \
  ../neorv32/rtl/core/neorv32_sysinfo.vhd           \
  ../neorv32/rtl/core/neorv32_debug_dtm.vhd         \
  ../neorv32/rtl/core/neorv32_debug_auth.vhd        \
  ../neorv32/rtl/core/neorv32_debug_dm.vhd          \
  ../neorv32/rtl/core/neorv32_top.vhd               \
  ../neorv32/rtl/core/neorv32_application_image.vhd \
  ../neorv32/rtl/core/neorv32_bootloader_image.vhd

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
