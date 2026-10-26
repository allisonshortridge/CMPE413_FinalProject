library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity nor2 is
    port (
        input1  :   in std_logic;
        input2  :   in std_logic;
        output  :   out std_logic
    );
end nor2;

architecture structural of nor2 is

component inverter
    port (
        input    : in  std_logic;
        output   : out std_logic
    );
end component;

component or2
    port (
        input1  :   in std_logic;
        input2  :   in std_logic;
        output  :   out std_logic
    );
end component;

for inverter_1: inverter use entity work.inverter(structural);
for or2_1: or2 use entity work.or2(structural);

signals or_input1, or_input2, or_output, inverter_output: std_logic;

begin
    or_input1<=input1;
    or_input2<=input2;

    or2_1: or2 port map(or_input1, or_input2, or_output);
    
    inverter_1: inverter port map(or_output, inverter_output);

    output<=inverter_output;

end structural;