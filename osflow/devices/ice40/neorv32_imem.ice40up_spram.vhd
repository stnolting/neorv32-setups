-- ================================================================================ --
-- NEORV32 SoC - Processor-Internal Instruction Memory (IMEM)                       --
-- -------------------------------------------------------------------------------- --
-- The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32              --
-- Copyright (c) NEORV32 contributors.                                              --
-- Copyright (c) 2020 - 2026 Stephan Nolting. All rights reserved.                  --
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
    AWIDTH  : natural; -- memory address width (byte-addressing)
    INITROM : boolean; -- implement IMEM as pre-initialized read-only memory?
    OUTREG  : boolean  -- add output register stage
  );
  port (
    -- global control --
    clk_i      : in  std_ulogic;                     -- clock, trigger on rising edge
    rstn_i     : in  std_ulogic;                     -- async reset, low-active
    -- bus request --
    req_addr_i : in  std_ulogic_vector(31 downto 0); -- access address (byte-addressing)
    req_data_i : in  std_ulogic_vector(31 downto 0); -- write data
    req_ben_i  : in  std_ulogic_vector(3 downto 0);  -- byte enable
    req_stb_i  : in  std_ulogic;                     -- request strobe
    req_rw_i   : in  std_ulogic;                     -- 0 = read, 1 = write
    -- bus response --
    rsp_data_o : out std_ulogic_vector(31 downto 0); -- read data
    rsp_ack_o  : out std_ulogic;                     -- access acknowledge
    rsp_err_o  : out std_ulogic                      -- access error
  );
end neorv32_imem;

architecture neorv32_imem_rtl of neorv32_imem is

  -- advanced configuration --------------------------------------------------------------------------------
  constant spram_sleep_mode_en_c : boolean := false; -- put IMEM into sleep mode when idle (for low power)
  -- -------------------------------------------------------------------------------------------------------

  -- memory size in bytes --
  constant mem_size_c_c : natural := 2**AWIDTH;

  -- IO space: module base address --
  constant hi_abb_c : natural := 31; -- high address boundary bit
  constant lo_abb_c : natural := index_size_f(mem_size_c); -- low address boundary bit

  -- local signals --
  signal rdata : std_ulogic_vector(31 downto 0);
  signal rden  : std_ulogic;

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
  assert not (INITROM = true)
    report "[NEORV32] ICE40 Ultra Plus SPRAM cannot be initialized by bitstream!" severity failure;

  assert not (mem_size_c /= 64*1024)
    report "[NEORV32] IMEM SPRAM has a fixed physical size of 64kB." severity note;

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
  spram_addr  <= std_logic_vector(req_addr_i(13+2 downto 0+2));
  spram_di_lo <= std_logic_vector(req_data_i(15 downto 00));
  spram_di_hi <= std_logic_vector(req_data_i(31 downto 16));
  spram_we    <= '1' when (req_rw_i = '1') else '0'; -- global write enable
  spram_cs    <= std_logic(req_stb_i);
  spram_be_lo <= std_logic(req_ben_i(1)) & std_logic(req_ben_i(1)) & std_logic(req_ben_i(0)) & std_logic(req_ben_i(0)); -- low byte write enable
  spram_be_hi <= std_logic(req_ben_i(3)) & std_logic(req_ben_i(3)) & std_logic(req_ben_i(2)) & std_logic(req_ben_i(2)); -- high byte write enable
  spram_pwr_n <= '0' when ((spram_sleep_mode_en_c = false) or (req_stb_i = '1')) else '1'; -- LP mode disabled or IMEM selected
  rdata       <= std_ulogic_vector(spram_do_hi) & std_ulogic_vector(spram_do_lo);

  buffer_ff: process(clk_i)
  begin
    if rising_edge(clk_i) then
      rsp_ack_o <= req_stb_i;
      rden      <= req_stb_i and (not req_rw_i);
    end if;
  end process buffer_ff;

  rsp_err_o  <= '0'; -- no access error supported
  rsp_data_o <= rdata when (rden = '1') else (others => '0'); -- output gate

end neorv32_imem_rtl;
