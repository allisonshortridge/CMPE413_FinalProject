library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity mux is
    port (
        input1   : in std_logic;
        input2   : in std_logic;
        sel  : in std_logic;
        y   : out std_logic
    );
end mux;

architecture structural of mu1 is
    component and2
        port (
        input1   : in std_logic;
        input2   : in std_logic;
        output   : out std_logic
        );
        end component;
    
    component or2
        port (
        input1   : in std_logic;
        input2   : in std_logic;
        output   : out std_logic
        );
        end component;
    
    component inverter
        port (
        input   : in std_logic;
        output   : out std_logic
        );
        end component;
    
    --basic gate instantiation
    for inv_1: inverter use entity work.inverter(structural);
    for and_1, and_2: and2 use entity work.and2(structural);
    for or_1: or2 use entity work.or2(structural);

    --intermediate signals
    signal sel_not: std_logic;
    signal and_1_out, and_2_out: std_logic;

begin
    inv_1: inverter port map(sel, sel_not);

    and_1: and3 port map (sel_not, input1, and_1_out);
    and_2: and3 port map (sel, input2, and_2_out);

    or_1: or4 port map (and_1_out, and_2_out, y);
end structural;