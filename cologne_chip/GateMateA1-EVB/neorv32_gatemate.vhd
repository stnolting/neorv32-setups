-- ================================================================================ --
-- NEORV32 Setup for the Olimex GateMateA1-EVB-2M development board                 --
-- featuring the Cologne Chip Gate Mate CCGM1A1 FPGA                                --
-- -------------------------------------------------------------------------------- --
-- The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32-setups       --
-- Copyright (c) NEORV32 contributors.                                              --
-- Copyright (c) 2020 - 2024 Stephan Nolting. All rights reserved.                  --
-- Licensed under the BSD-3-Clause license, see LICENSE for details.                --
-- SPDX-License-Identifier: BSD-3-Clause                                            --
-- ================================================================================ --

library ieee;
use ieee.std_logic_1164.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_gatemate is
  port (
    -- clock and reset --
    clk_i  : in  std_ulogic;
    rstn_i : in  std_ulogic;
    -- status led --
    led_o  : out std_ulogic;
    -- uart --
    txd_o  : out std_ulogic;
    rxd_i  : in  std_ulogic
  );
end entity;

architecture neorv32_gatemate_rtl of neorv32_gatemate is

  signal con_gpio_out : std_ulogic_vector(63 downto 0);

begin

  -- The Core Of The Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: neorv32_top
  generic map (
    -- General --
    CLOCK_FREQUENCY            => 10_000_000, -- frequency of clk_i in Hz
    INT_BOOTLOADER_EN          => true,
    -- RISC-V CPU Extensions --
    CPU_EXTENSION_RISCV_C      => true,
    CPU_EXTENSION_RISCV_M      => true,
    CPU_EXTENSION_RISCV_Zicntr => true,
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN            => true,
    MEM_INT_IMEM_SIZE          => 16*1024,
    -- Internal Data memory --
    MEM_INT_DMEM_EN            => true,
    MEM_INT_DMEM_SIZE          => 8*1024,
    -- Processor peripherals --
    IO_GPIO_NUM                => 1,
    IO_MTIME_EN                => true,
    IO_UART0_EN                => true,
    IO_UART0_RX_FIFO           => 128,
    IO_UART0_TX_FIFO           => 128
  )
  port map (
    -- Global control --
    clk_i       => clk_i,
    rstn_i      => rstn_i,
    -- GPIO (available if IO_GPIO_NUM > 0) --
    gpio_o      => con_gpio_out,
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o => txd_o,
    uart0_rxd_i => rxd_i
  );

  -- low-active status LED --
  led_o <= not con_gpio_out(0);


end architecture;
