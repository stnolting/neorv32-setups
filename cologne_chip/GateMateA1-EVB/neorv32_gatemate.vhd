-- ================================================================================ --
-- NEORV32 Setup for the Olimex GateMateA1-EVB-2M development board                 --
-- featuring the Cologne Chip GateMate CCGM1A1 FPGA.                                --
-- -------------------------------------------------------------------------------- --
-- The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32              --
-- Copyright (c) NEORV32 contributors.                                              --
-- Copyright (c) 2020 - 2025 Stephan Nolting. All rights reserved.                  --
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
    clk_i   : in  std_ulogic;
    rstn_i  : in  std_ulogic;
    -- spi flash --
    sck_o  : out std_ulogic;
    csn_o  : out std_ulogic;
    sdo_o  : out std_ulogic;
    sdi_i  : in  std_ulogic;
    -- i2c host --
    scl_io : inout std_logic;
    sda_io : inout std_logic;
    -- status led --
    led_o  : out std_ulogic;
    -- uart --
    txd_o  : out std_ulogic;
    rxd_i  : in  std_ulogic
  );
end entity;

architecture neorv32_gatemate_rtl of neorv32_gatemate is

  component CC_PLL is
  generic (
    REF_CLK         : string;  -- reference input in MHz
    OUT_CLK         : string;  -- pll output frequency in MHz
    PERF_MD         : string;  -- LOWPOWER, ECONOMY, SPEED
    LOW_JITTER      : integer; -- 0: disable, 1: enable low jitter mode
    CI_FILTER_CONST : integer; -- optional CI filter constant
    CP_FILTER_CONST : integer  -- optional CP filter constant
  );
  port (
    CLK_REF             : in  std_logic;
    USR_CLK_REF         : in  std_logic;
    CLK_FEEDBACK        : in  std_logic;
    USR_LOCKED_STDY_RST : in  std_logic;
    USR_PLL_LOCKED_STDY : out std_logic;
    USR_PLL_LOCKED      : out std_logic;
    CLK0                : out std_logic;
    CLK90               : out std_logic;
    CLK180              : out std_logic;
    CLK270              : out std_logic;
    CLK_REF_OUT         : out std_logic
  );
  end component;

  signal clk_sys : std_logic;
  signal con_gpio_out : std_ulogic_vector(31 downto 0);
  signal con_spi_csn : std_ulogic_vector(7 downto 0);
  signal twi_sda_i, twi_sda_o, twi_scl_i, twi_scl_o : std_ulogic;

begin

  -- System PLL -----------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  socket_pll: CC_PLL
  generic map (
    REF_CLK         => "10.0",
    OUT_CLK         => "25.0",
    PERF_MD         => "SPEED",
    LOW_JITTER      => 1,
    CI_FILTER_CONST => 2,
    CP_FILTER_CONST => 4
  )
  port map (
    CLK_REF             => clk_i,
    USR_CLK_REF         => '0',
    CLK_FEEDBACK        => '0',
    USR_LOCKED_STDY_RST => '0',
    USR_PLL_LOCKED_STDY => open,
    USR_PLL_LOCKED      => open,
    CLK0                => clk_sys,
    CLK90               => open,
    CLK180              => open,
    CLK270              => open,
    CLK_REF_OUT         => open
  );

  -- The Core Of The Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: neorv32_top
  generic map (
    -- Processor Clocking --
    CLOCK_FREQUENCY   => 25_000_000, -- core frequency in Hz
    BOOT_MODE_SELECT  => 0, -- boot via build-in bootloader
    -- RISC-V CPU Extensions --
    RISCV_ISA_C       => true,
    RISCV_ISA_M       => true,
    RISCV_ISA_Zicntr  => true,
    -- Internal instruction memory --
    IMEM_EN   => true,
    IMEM_SIZE => 16*1024,
    -- Internal data memory --
    DMEM_EN   => true,
    DMEM_SIZE => 8*1024,
    -- Processor peripherals --
    IO_GPIO_NUM       => 1,
    IO_CLINT_EN       => true,
    IO_UART0_EN       => true,
    IO_SPI_EN         => true,
    IO_TWI_EN         => true
  )
  port map (
    -- Global control --
    clk_i       => std_ulogic(clk_sys),
    rstn_i      => rstn_i,
    -- GPIO (available if IO_GPIO_NUM > 0) --
    gpio_o      => con_gpio_out,
    gpio_i      => (others => '0'),
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o => txd_o,
    uart0_rxd_i => rxd_i,
    -- SPI (available if IO_SPI_EN = true) --
    spi_clk_o   => sck_o,
    spi_dat_o   => sdo_o,
    spi_dat_i   => sdi_i,
    spi_csn_o   => con_spi_csn,
    -- TWI (available if IO_TWI_EN = true) --
    twi_sda_i   => twi_sda_i,
    twi_sda_o   => twi_sda_o,
    twi_scl_i   => twi_scl_i,
    twi_scl_o   => twi_scl_o
  );

  -- low-active status LED --
  led_o <= not con_gpio_out(0);

  -- on-board SPI flash --
  csn_o <= con_spi_csn(0);

  -- TWI tri-state drivers --
  scl_io    <= '0' when (twi_scl_o = '0') else 'Z';
  sda_io    <= '0' when (twi_sda_o = '0') else 'Z';
  twi_scl_i <= std_ulogic(scl_io);
  twi_sda_i <= std_ulogic(sda_io);

end architecture;
