library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity ndflip is
    port (
        d   : in std_logic;
        clk    : in std_logic;
        rst     :  in std_logic;
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

component and2
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        output   : out std_logic
    );
end component;

--declaration of individual gates
for inv_1, inv_2: inverter use entity work.inverter(structural);
for and2_1: and2 use entity work.and2(structural);
for pdl_1, pdl_2: positive_dlatch use entity work.positive_dlatch(structural);
--intermediate signals between gates
signal clk_not, rst_not, d_int, q_int: std_logic;

begin
--mapping ports to gates
    inv_1: inverter port map(clk, clk_not);

    inv_2: inverter port map(rst, rst_not);
    and2_1: and2 port map(d, rst_not, d_int);

    pdl_1: positive_dlatch port map(d_int, clk, q_int, open);
    pdl_2: positive_dlatch port map(q_int, clk_not, q, open);

end structural;