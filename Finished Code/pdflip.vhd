library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity pdflip is
    port (
        d   :   in std_logic;
        clk :   in std_logic;
        rst :   in std_logic;
        q   :   out std_logic
    );
end pdflip;

architecture structural of pdflip is

component inverter
    port (
        input    : in  std_logic;
        output   : out std_logic
    );
end component;

component and2
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        output   : out std_logic
    );
end component;

component positive_dlatch
    port (
        d   : in  std_logic;
        en : in  std_logic;
        q   : out std_logic;
        qbar: out std_logic
    );
end component;

for inverter_1, inverter_2: inverter use entity work.inverter(structural);
for and2_1: and2 use entity work.and2(structural);
for pdl_1, pdl_2: positive_dlatch use entity work.positive_dlatch(structural);

signal not_clk, not_rst, d_temp, q_temp: std_logic;

begin

    inverter_1: inverter port map(clk, not_clk);

    inverter_2: inverter port map(rst, not_rst);
    and2_1: and2 port map(d, not_rst, d_temp);

    pdl_1: positive_dlatch port map(d_temp, not_clk, q_temp, open);
    pdl_2: positive_dlatch port map(q_temp, clk, q, open);

end structural;