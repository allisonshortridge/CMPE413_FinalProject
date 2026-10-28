library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity ndflip is
    port (
        d   : in std_logic;
        load : in std_logic;
        clock    : in std_logic;
        q   : out std_logic
    );
end ndflip;

architecture structural of ndflip is
    component inverter
        port (
        input   : in std_logic;
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

--declaration of individual gates
for inv_1: inverter use entity work.inverter(structural);
for pdl_1, pdl_2: positive_dlatch use entity work.positive_dlatch(structural);
--intermediate signals between gates
signal clk_not, q_int: std_logic;

begin
--mapping ports to gates
    inv_1: inverter port map(clk, clk_n);

    pdl_1: positive_dlatch port map(d, clk, q_int);
    pdl_2: positive_dlatch port map(q_int, clk_not, q);

end structural;