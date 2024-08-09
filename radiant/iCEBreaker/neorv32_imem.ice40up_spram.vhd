-- ================================================================================ --
-- NEORV32 SoC - Processor-Internal Instruction Memory (IMEM)                       --
-- -------------------------------------------------------------------------------- --
-- Memory has a physical size of 64kb (2 x SPRAMs).                                 --
-- Logical size IMEM_SIZE must be less or equal.                                    --
-- -------------------------------------------------------------------------------- --
-- The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32              --
-- Copyright (c) NEORV32 contributors.                                              --
-- Copyright (c) 2020 - 2024 Stephan Nolting. All rights reserved.                  --
-- Licensed under the BSD-3-Clause license, see LICENSE for details.                --
-- SPDX-License-Identifier: BSD-3-Clause                                            --
-- ================================================================================ --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

library iCE40UP;
use iCE40UP.components.all; -- for device primitives

entity neorv32_imem is
  generic (
    IMEM_SIZE    : natural; -- processor-internal instruction memory size in bytes, has to be a power of 2
    IMEM_AS_IROM : boolean  -- implement IMEM as pre-initialized read-only memory?
  );
  port (
    clk_i     : in  std_ulogic; -- global clock line
    rstn_i    : in  std_ulogic; -- async reset, low-active
    bus_req_i : in  bus_req_t;  -- bus request
    bus_rsp_o : out bus_rsp_t   -- bus response
  );
end neorv32_imem;

architecture neorv32_imem_rtl of neorv32_imem is

  -- advanced configuration --------------------------------------------------------------------------------
  constant spram_sleep_mode_en_c : boolean := false; -- put IMEM into sleep mode when idle (for low power)
  -- -------------------------------------------------------------------------------------------------------

  -- IO space: module base address --
  constant hi_abb_c : natural := 31; -- high address boundary bit
  constant lo_abb_c : natural := index_size_f(64*1024); -- low address boundary bit

  -- local signals --
  signal mem_cs : std_ulogic;
  signal rdata  : std_ulogic_vector(31 downto 0);
  signal rden   : std_ulogic;

  -- SPRAM signals --
  signal spram_clk   : std_logic;
  signal spram_addr  : std_logic_vector(13 downto 0);
  signal spram_di_lo : std_logic_vector(15 downto 0);
  signal spram_di_hi : std_logic_vector(15 downto 0);
  signal spram_do_lo : std_logic_vector(15 downto 0);
  signal spram_do_hi : std_logic_vector(15 downto 0);
  signal spram_be_lo : std_logic_vector(03 downto 0);
  signal spram_be_hi : std_logic_vector(03 downto 0);
  signal spram_we    : std_logic;
  signal spram_pwr_n : std_logic;
  signal spram_cs    : std_logic;

begin

  -- Sanity Checks --------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  assert false report "NEORV32 PROCESSOR CONFIG NOTE: Using iCE40up SPRAM-based IMEM." severity note;
  assert not (IMEM_AS_IROM = true) report "NEORV32 PROCESSOR CONFIG ERROR: ICE40 Ultra Plus SPRAM cannot be initialized by bitstream!" severity failure;
  assert not (IMEM_SIZE > 64*1024) report "NEORV32 PROCESSOR CONFIG ERROR: IMEM has a fixed physical size of 64kB. Logical size must be less or equal." severity error;


  -- Access Control -------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  mem_cs <= bus_req_i.stb;


  -- Memory Access --------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  imem_spram_lo_inst : SP256K
  port map (
    AD       => spram_addr,  -- I
    DI       => spram_di_lo, -- I
    MASKWE   => spram_be_lo, -- I
    WE       => spram_we,    -- I
    CS       => spram_cs,    -- I
    CK       => spram_clk,   -- I
    STDBY    => '0',         -- I
    SLEEP    => spram_pwr_n, -- I
    PWROFF_N => '1',         -- I
    DO       => spram_do_lo  -- O
  );

  imem_spram_hi_inst : SP256K
  port map (
    AD       => spram_addr,  -- I
    DI       => spram_di_hi, -- I
    MASKWE   => spram_be_hi, -- I
    WE       => spram_we,    -- I
    CS       => spram_cs,    -- I
    CK       => spram_clk,   -- I
    STDBY    => '0',         -- I
    SLEEP    => spram_pwr_n, -- I
    PWROFF_N => '1',         -- I
    DO       => spram_do_hi  -- O
  );

  -- access logic and signal type conversion --
  spram_clk   <= std_logic(clk_i);
  spram_addr  <= std_logic_vector(bus_req_i.addr(13+2 downto 0+2));
  spram_di_lo <= std_logic_vector(bus_req_i.data(15 downto 00));
  spram_di_hi <= std_logic_vector(bus_req_i.data(31 downto 16));
  spram_we    <= '1' when (bus_req_i.rw = '1') else '0'; -- global write enable
  spram_cs    <= std_logic(mem_cs);
  spram_be_lo <= std_logic(bus_req_i.ben(1)) & std_logic(bus_req_i.ben(1)) & std_logic(bus_req_i.ben(0)) & std_logic(bus_req_i.ben(0)); -- low byte write enable
  spram_be_hi <= std_logic(bus_req_i.ben(3)) & std_logic(bus_req_i.ben(3)) & std_logic(bus_req_i.ben(2)) & std_logic(bus_req_i.ben(2)); -- high byte write enable
  spram_pwr_n <= '0' when ((spram_sleep_mode_en_c = false) or (mem_cs = '1')) else '1'; -- LP mode disabled or IMEM selected
  rdata       <= std_ulogic_vector(spram_do_hi) & std_ulogic_vector(spram_do_lo);

  buffer_ff: process(clk_i)
  begin
    if rising_edge(clk_i) then
      bus_rsp_o.ack <= mem_cs;
      rden          <= bus_req_i.stb and (not bus_req_i.rw);
    end if;
  end process buffer_ff;

  -- no access error possible --
  bus_rsp_o.err <= '0';

  -- output gate --
  bus_rsp_o.data <= rdata when (rden = '1') else (others => '0');


end neorv32_imem_rtl;
