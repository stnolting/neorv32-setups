-- ================================================================================ --
-- NEORV32 - Test Setup Using Altera FPGAs Internal JTAG Atom To Access The OCD     --
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

entity neorv32_on_chip_debugger_altera is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY : natural := 50000000;  -- clock frequency of clk_i in Hz
    IMEM_SIZE       : natural := 16*1024;   -- size of processor-internal instruction memory in bytes
    DMEM_SIZE       : natural := 8*1024     -- size of processor-internal data memory in bytes
  );
  port (
    -- Global control --
    clk_i  : in  std_ulogic; -- global clock, rising edge
    rstn_i : in  std_ulogic; -- global reset, low-active, async
    -- JTAG on-chip debugger interface --
    altera_reserved_tck : in  std_ulogic; -- serial clock
    altera_reserved_tdi : in  std_ulogic; -- serial data input
    altera_reserved_tdo : out std_ulogic; -- serial data output
    altera_reserved_tms : in  std_ulogic; -- mode select
    -- GPIO --
    gpio_o : out std_ulogic_vector(7 downto 0); -- parallel output
    -- UART0 --
    uart0_txd_o : out std_ulogic; -- UART0 send data
    uart0_rxd_i : in  std_ulogic  -- UART0 receive data
  );
end entity;

architecture neorv32_on_chip_debugger_altera_rtl of neorv32_on_chip_debugger_altera is

  -- Cyclone IV E specific atom for indirect access to physical JTAG --
  --
  -- Depending on the chip it could be one of these: component arriaii_jtag, arriaiigz_jtag,
  -- arriav_jtag, arriavgz_jtag, cyclone_jtag, cyclone10lp_jtag, cycloneii_jtag, cycloneiii_jtag,
  -- cycloneiiils_jtag, cycloneiv_jtag, cycloneive_jtag, cyclonev_jtag, fiftyfivenm_jtag,
  -- maxii_jtag, maxv_jtag, stratix_jtag, stratixgx_jtag, stratixii_jtag, stratixiigx_jtag,
  -- stratixiii_jtag, stratixiv_jtag, stratixv_jtag, twentynm_jtagblock, twentynm_jtag,
  -- twentynm_hps_interface_jtag, fiftyfivenm_jtag
  -- See: https://tomverbeure.github.io/2021/10/30/Intel-JTAG-Primitive.html
  component cycloneive_jtag
    generic (
      lpm_type : string := "cycloneive_jtag"
    );
    port (
      tms         : in  std_ulogic := '0';
      tck         : in  std_ulogic := '0';
      tdi         : in  std_ulogic := '0';
      tdouser     : in  std_ulogic := '0';
      tdo         : out std_ulogic;
      tmsutap     : out std_ulogic;
      tckutap     : out std_ulogic;
      tdiutap     : out std_ulogic;
      shiftuser   : out std_ulogic;
      clkdruser   : out std_ulogic;
      updateuser  : out std_ulogic;
      runidleuser : out std_ulogic;
      usr1user    : out std_ulogic
    );
  end component;

  signal con_gpio_out : std_ulogic_vector(31 downto 0);
  signal con_jtag_tck, con_jtag_tdi, con_jtag_tdo, con_jtag_tms : std_logic;

begin

  -- The Core Of The Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: neorv32_top
  generic map (
    -- Clocking --
    CLOCK_FREQUENCY  => CLOCK_FREQUENCY,   -- clock frequency of clk_i in Hz
    -- Boot Configuration --
    BOOT_MODE_SELECT => 0,                 -- boot via internal bootloader
    -- On-Chip Debugger (OCD) --
    OCD_EN           => true,              -- implement on-chip debugger
    -- RISC-V CPU Extensions --
    RISCV_ISA_C      => true,              -- implement compressed extension?
    RISCV_ISA_M      => true,              -- implement mul/div extension?
    RISCV_ISA_U      => true,              -- implement user mode extension?
    RISCV_ISA_Zicntr => true,              -- implement base counters?
    -- Internal Instruction memory --
    IMEM_EN          => true,              -- implement processor-internal instruction memory
    IMEM_SIZE        => IMEM_SIZE,         -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    DMEM_EN          => true,              -- implement processor-internal data memory
    DMEM_SIZE        => DMEM_SIZE,         -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_NUM      => 8,                 -- number of GPIO input/output pairs (0..32)
    IO_CLINT_EN      => true,              -- implement core local interruptor (CLINT)?
    IO_UART0_EN      => true               -- implement primary universal asynchronous receiver/transmitter (UART0)?
  )
  port map (
    -- Global control --
    clk_i       => clk_i,        -- global clock, rising edge
    rstn_i      => rstn_i,       -- global reset, low-active, async
    -- JTAG on-chip debugger interface (available if ON_CHIP_DEBUGGER_EN = true) --
    jtag_tck_i  => con_jtag_tck, -- serial clock
    jtag_tdi_i  => con_jtag_tdi, -- serial data input
    jtag_tdo_o  => con_jtag_tdo, -- serial data output
    jtag_tms_i  => con_jtag_tms, -- mode select
    -- GPIO (available if IO_GPIO_NUM > 0) --
    gpio_o      => con_gpio_out, -- parallel output
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o => uart0_txd_o,  -- UART0 send data
    uart0_rxd_i => uart0_rxd_i   -- UART0 receive data
  );

  -- GPIO output --
  gpio_o <= con_gpio_out(7 downto 0);

  -- Altera JTAG atom --
  jtag_inst : cycloneive_jtag
  port map (
    tms         => altera_reserved_tms,
    tck         => altera_reserved_tck,
    tdi         => altera_reserved_tdi,
    tdo         => altera_reserved_tdo,
    tdouser     => con_jtag_tdo,
    tmsutap     => con_jtag_tms,
    tckutap     => con_jtag_tck,
    tdiutap     => con_jtag_tdi,
    shiftuser   => open, -- don't care, dtm has it's own JTAG FSM
    clkdruser   => open,
    updateuser  => open,
    runidleuser => open,
    usr1user    => open
  );

end architecture;
