-- 2 to 4 decoder

library STD;
library IEEE;
use IEEE.std_logic_1164.all;

-- 2:4 decoder
entity decoder2to4 is
    port (
        A1    : in std_logic;
        A0    : in std_logic;
        E     : in std_logic;
        Y3    : out std_logic;
        Y2    : out std_logic;
        Y1    : out std_logic;
        Y0    : out std_logic
    );
end decoder2to4;

architecture structural of decoder2to4 is

-- 2-input AND gate
component and2
  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    output   : out std_logic);
end component;

-- inverter
component inverter
  port (
    input    : in  std_logic;
    output   : out std_logic);
end component;

-- 2 AND gates for a1 and e, 4 AND gates for result of previous AND gates and a0
for and2_1, and2_1_1, and2_1_2, and2_2, and2_2_1, and2_2_2: and2 use entity work.and2(structural);
-- inverters to invert a1 and a0
for inv_a1, inv_a0: inverter use entity work.inverter(structural);

-- signals for the a1 inversion, a0 inversion, output of ~a1 and e, and output of a1 and e
signal not_a1, not_a0, ea1, ea2: std_logic;

begin

    -- a1 and a0 inversions
    inv_a1: inverter port map (A1, not_a1);
    inv_a0: inverter port map (A0, not_a0);

    -- 2 AND gates for initial stage of ~a1 and e, and a1 and e
    and2_1: and2 port map (not_a1, E, ea1);
    and2_2: and2 port map (A1, E, ea2);

    -- outputs y0 and y1 after ~a1 and e AND gate being passed to AND gates with ~a0 and a0
    and2_1_1: and2 port map (not_a0, ea1, Y0);
    and2_1_2: and2 port map (A0, ea1, Y1);

    -- outputs y2 and y3 after a1 and e AND gate being passed to AND gates with ~a0 and a0
    and2_2_1: and2 port map (not_a0, ea2, Y2);
    and2_2_2: and2 port map (A0, ea2, Y3);

end structural;