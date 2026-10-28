library STD;
library ieee;
use ieee.std_logic_1164.all;

entity ca_reg is
    port (
        ca   : in  std_logic_vector(7 downto 0);
        load : in  std_logic;
        clk  : in  std_logic;
        q    : out std_logic_vector(7 downto 0)
    );
end entity ca_reg;

architecture structural of ca_reg is
    component reg
        port (
            d   : in std_logic;
            load : in std_logic;
            clk    : in std_logic;
            q   : out std_logic
        );
        end component;

for bit_0, bit_1, bit_2, bit_3, bit_4, bit_5, bit_6, bit_7: reg use entity work.reg(structural);;

begin
  bit0 : port map (ca(0), load, clk, q(0));
  bit1 : port map (ca(1), load, clk, q(1));
  bit2 : port map (ca(2), load, clk, q(2));
  bit3 : port map (ca(3), load, clk, q(3));
  bit4 : port map (ca(4), load, clk, q(4));
  bit5 : port map (ca(5), load, clk, q(5));
  bit6 : port map (ca(6), load, clk, q(6));
  bit7 : port map (ca(7), load, clk, q(7));
end architecture structural;