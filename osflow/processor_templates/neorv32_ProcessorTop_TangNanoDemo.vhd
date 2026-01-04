-- ================================================================================ --
-- NEORV32 - Example setup for Tang Nano boards                                     --
--
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

entity neorv32_ProcessorTop_TangNanoDemo is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY   : natural := 27000000; -- clock frequency of clk_i in Hz
    -- Internal Instruction memory --
    IMEM_EN           : boolean := true;     -- implement processor-internal instruction memory
    IMEM_SIZE         : natural := 32*1024;  -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    DMEM_EN           : boolean := true;     -- implement processor-internal data memory
    DMEM_SIZE         : natural := 32*1024;  -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_NUM       : natural := 6         -- number of GPIO input/output pairs (0..32)
  );
  port (
    -- Global control --
    clk_i             : in  std_ulogic;                    -- global clock, rising edge
    rstn_i            : in  std_ulogic;                    -- global reset, low-active, async
    -- GPIO --
    gpio_o            : out std_ulogic_vector(5 downto 0); -- parallel output
    -- UART0 --
    uart_txd_o        : out std_ulogic;                    -- UART0 send data
    uart_rxd_i        : in  std_ulogic;                    -- UART0 receive data
    -- Neopixel --
    neoled_o          : out std_ulogic;                    -- Neopixel data output
    -- SPI --
    spi_clk_o         : out std_ulogic;                    -- SPI serial clock
    spi_dat_o         : out std_ulogic;                    -- controller data out, peripheral data in
    spi_dat_i         : in  std_ulogic := 'L';             -- controller data in, peripheral data out
    spi_csn_o         : out std_ulogic_vector(7 downto 0)  -- chip-select outputs, low-active
  );
end entity;

architecture neorv32_ProcessorTop_TangNanoDemo_rtl of neorv32_ProcessorTop_TangNanoDemo is

  -- internal IO connection --
  signal con_gpio_o : std_ulogic_vector(31 downto 0);

begin

  -- The Core Of The Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: entity neorv32.neorv32_top
  generic map (
    -- Clocking --
    CLOCK_FREQUENCY   => CLOCK_FREQUENCY,   -- clock frequency of clk_i in Hz
    -- Boot Configuration --
    BOOT_MODE_SELECT  => 0,                 -- boot via internal bootloader
    -- RISC-V CPU Extensions --
    RISCV_ISA_M      => true,               -- implement mul/div extension?
    RISCV_ISA_U      => true,               -- implement user mode extension?
    RISCV_ISA_Zicntr => true,               -- implement base counters?
    -- Internal Instruction memory --
    IMEM_EN           => true,              -- implement processor-internal instruction memory
    IMEM_SIZE         => IMEM_SIZE,         -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    DMEM_EN           => true,              -- implement processor-internal data memory
    DMEM_SIZE         => DMEM_SIZE,         -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_NUM       => 6,                 -- number of GPIO input/output pairs (0..32)
    IO_CLINT_EN       => true,              -- implement core local interruptor (CLINT)?
    IO_UART0_EN       => true,              -- implement primary universal asynchronous receiver/transmitter (UART0)?
    IO_NEOLED_EN      => true,              -- implement NeoPixel-compatible smart LED interface (NEOLED)
    IO_NEOLED_TX_FIFO => 1,                 -- NEOLED FIFO depth, has to be a power of two, min 1
    IO_SPI_EN         => true,              -- implement serial peripheral interface (SPI)
    IO_SPI_FIFO       => 1                  -- RTX FIFO depth, has to be a power of two, min 1
  )
  port map (
    -- Global control --
    clk_i       => clk_i,                   -- global clock, rising edge
    rstn_i      => rstn_i,                  -- global reset, low-active, async
    -- GPIO --
    gpio_o      => con_gpio_o,              -- parallel output
    -- primary UART0 --
    uart0_txd_o => uart_txd_o,              -- UART0 send data
    uart0_rxd_i => uart_rxd_i,              -- UART0 receive data
    -- Neopixel --
    neoled_o    => neoled_o,                -- Neopixel data
    -- SPI --
    spi_clk_o   => spi_clk_o,               -- SPI serial clock  
    spi_dat_o   => spi_dat_o,               -- controller data out, peripheral data in
    spi_dat_i   => spi_dat_i,               -- controller data in, peripheral data out
    spi_csn_o   => spi_csn_o                -- chip-selects, low-active
  );

  -- GPIO --
  gpio_o <= con_gpio_o(IO_GPIO_NUM-1 downto 0);

end architecture;
