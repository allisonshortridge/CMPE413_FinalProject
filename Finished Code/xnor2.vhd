library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity xnor2 is
    port (
        input1  :   in std_logic;
        input2  :   in std_logic;
        output  :   out std_logic
    );
end xnor2;

architecture structural of xnor2 is

-- inverter
component inverter
    port (
        input    : in  std_logic;
        output   : out std_logic
    );
end component;

-- 2-input AND
component and2
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        output   : out std_logic
    );
end component;

-- 2-input OR
component or2
    port (
        input1  :   in std_logic;
        input2  :   in std_logic;
        output  :   out std_logic
    );
end component;


for inverter_1, inverter_2: inverter use entity work.inverter(structural);
for and2_1, and2_2: and2 use entity work.and2(structural);
for or2_1: or2 use entity work.or2(structural);

signal not_a, not_b, ab, not_ab: std_logic;

begin
    -- inverted input 1 and input 2
    inverter_1: inverter port map(input1, not_a);
    inverter_2: inverter port map(input2, not_b);

    -- a and b
    and2_1: and2 port map(input1, input2, ab);

    -- not a and not b
    and2_2: and2 port map(not_a, not_b, not_ab);

    -- ab or not(ab)
    or2_1: or2 port map(ab, not_ab, output);

end structural;
