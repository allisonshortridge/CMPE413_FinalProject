library STD;
library IEEE;
use IEEE.std_logic_1164.all;

-- 1:2 decoder
entity decoder1to2 is
    port (
        A0    : in std_logic;
        E     : in std_logic;
        Y1    : out std_logic;
        Y0    : out std_logic
    );
end decoder1to2;

architecture structural of decoder1to2 is

-- inverter
component inverter
  port (
    input    : in  std_logic;
    output   : out std_logic);
end component;

-- 2-input AND
component and2
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        output   : out std_logic
    );
end component

for inverter_1: inverter use entity work.inverter(structural);
for and2_1, and2_2: and2 use entity work.and2(structural);

signals not_a0: std_logic;

begin
    inverter_1: inverter port map(A0, not_a0);

    and2_1: and2 port map(not_a0, E, Y0);
    and2_2: and2 port map(A0, E, Y1);

end structural