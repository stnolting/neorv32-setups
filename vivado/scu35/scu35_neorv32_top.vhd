library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity scu35_neorv32_top is
  port (
    clk_p       : in  std_logic;
    clk_n       : in  std_logic;
    rstn_i      : in  std_logic;
    gpio_o      : out std_ulogic_vector(7 downto 0);
    uart0_txd_o : out std_logic;
    uart0_rxd_i : in  std_logic
  );
end entity scu35_neorv32_top;

architecture rtl of scu35_neorv32_top is
  signal clk_i : std_logic;
begin
  clock_input : IBUFDS
    port map (
      I  => clk_p,
      IB => clk_n,
      O  => clk_i
    );

  neorv32 : entity work.neorv32_test_setup_bootloader
    generic map (
      CLOCK_FREQUENCY => 100_000_000
    )
    port map (
      clk_i       => clk_i,
      rstn_i      => rstn_i,
      gpio_o      => gpio_o,
      uart0_txd_o => uart0_txd_o,
      uart0_rxd_i => uart0_rxd_i
    );
end architecture rtl;
