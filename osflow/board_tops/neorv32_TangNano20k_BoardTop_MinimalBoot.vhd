-- ================================================================================ --
-- NEORV32 - Test Setup Using The UART-Bootloader To Upload And Run Executables     --
-- -------------------------------------------------------------------------------- --
-- The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32              --
-- Copyright (c) NEORV32 contributors.                                              --
-- Copyright (c) 2020 - 2025 Stephan Nolting. All rights reserved.                  --
-- Licensed under the BSD-3-Clause license, see LICENSE for details.                --
-- SPDX-License-Identifier: BSD-3-Clause                                            --
-- ================================================================================ --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_TangNano20k_BoardTop_MinimalBoot is
  port (
    -- Global control --
    TangNano_CLK     : in  std_ulogic;
    TangNano_RST     : in  std_ulogic;
    -- GPIO --
    TangNano_LED     : out std_ulogic_vector(5 downto 0);
    -- UART0 --
    TangNano_UART_TX : out std_ulogic;
    TangNano_UART_RX : in  std_ulogic
  );
end entity;

architecture neorv32_TangNano20k_BoardTop_MinimalBoot_rtl of neorv32_TangNano20k_BoardTop_MinimalBoot is
  
  -- configuration --
  constant f_clock_c : natural := 27000000;    -- PLL output clock frequency in Hz
  constant n_imem_size_c : natural := 32*1024; -- size of processor-internal instruction memory in bytes
  constant n_dmem_size_c : natural := 32*1024; -- size of processor-internal data memory in bytes
  constant n_gpio_width_c : natural := 6;      -- width of GPIO port

  signal con_led_o : std_ulogic_vector(5 downto 0);
  signal rst_active_low : std_ulogic;

begin

  -- Invert active-high external reset to active-low internal reset
  rst_active_low <= not TangNano_RST;

  -- The Core Of The Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: entity work.neorv32_ProcessorTop_MinimalBoot
  generic map (
    -- Clocking --
    CLOCK_FREQUENCY   => f_clock_c,
    IMEM_SIZE         => n_imem_size_c,
    DMEM_SIZE         => n_dmem_size_c,
    IO_GPIO_NUM       => n_gpio_width_c
  )
  port map (
    -- Global control --
    clk_i      => TangNano_CLK,
    rstn_i     => rst_active_low,
    -- GPIO --
    gpio_o     => con_led_o,
    -- primary UART0 --
    uart_txd_o => TangNano_UART_TX,
    uart_rxd_i => TangNano_UART_RX
  );

  -- GPIO output --
  TangNano_LED <= not con_led_o;

end architecture;
