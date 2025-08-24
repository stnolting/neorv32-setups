-- ================================================================================ --
-- NEORV32 SoC - Processor-Internal Instruction Memory (IMEM)                       --
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

library iCE40;
use iCE40.components.all;

entity neorv32_imem is
  generic (
    MEM_SIZE  : natural; -- memory size in bytes, has to be a power of 2, min 4
    MEM_INIT  : boolean; -- implement IMEM as pre-initialized read-only memory?
    OUTREG_EN : boolean  -- implement output register stage
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
  constant lo_abb_c : natural := index_size_f(MEM_SIZE); -- low address boundary bit

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
  assert not (MEM_INIT = true)
    report "[NEORV32] ICE40 Ultra Plus SPRAM cannot be initialized by bitstream!" severity failure;

  assert not (MEM_SIZE /= 64*1024)
    report "[NEORV32] IMEM SPRAM has a fixed physical size of 64kB." severity note;


  -- Access Control -------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  mem_cs <= bus_req_i.stb;


  -- Memory Access --------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  imem_spram_lo_inst : SB_SPRAM256KA
  port map (
    ADDRESS    => spram_addr,  -- I
    DATAIN     => spram_di_lo, -- I
    MASKWREN   => spram_be_lo, -- I
    WREN       => spram_we,    -- I
    CHIPSELECT => spram_cs,    -- I
    CLOCK      => spram_clk,   -- I
    STANDBY    => '0',         -- I
    SLEEP      => spram_pwr_n, -- I
    POWEROFF   => '1',         -- I
    DATAOUT    => spram_do_lo  -- O
  );

  imem_spram_hi_inst : SB_SPRAM256KA
  port map (
    ADDRESS    => spram_addr,  -- I
    DATAIN     => spram_di_hi, -- I
    MASKWREN   => spram_be_hi, -- I
    WREN       => spram_we,    -- I
    CHIPSELECT => spram_cs,    -- I
    CLOCK      => spram_clk,   -- I
    STANDBY    => '0',         -- I
    SLEEP      => spram_pwr_n, -- I
    POWEROFF   => '1',         -- I
    DATAOUT    => spram_do_hi  -- O
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
