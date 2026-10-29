--4 bit counter
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity counter is
    port (
        clk     :   in std_logic;
        rst     :   in std_logic;
        q       :   out std_logic_vector(3 downto 0)
    );
end counter;

architecture structural of counter is

component pdflip_wrst
    port (
        d   :   in std_logic;
        clk :   in std_logic;
        rst :   in std_logic;
        q   :   out std_logic
    );
end component;

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

component xor2
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        output   : out std_logic
    );
end component;

for dff_0, dff_1, dff_2, dff_3: pdflip_wrst use entity work.pdflip_wrst(structural);
for inverter_1: inverter use entity work.inverter(structural);
for and2_1, and2_2: and2 use entity work.and2(structural);
for xor2_1, xor2_2, xor2_3: xor2 use entity work.xor2(structural);

signal q_temp: std_logic_vector(3 downto 0);
signal d: std_logic_vector(3 downto 0);
signal q1q0, q2q1q0: std_logic;

begin
    
    inverter_1: inverter port map(q_temp(0), d(0));

    xor2_1: xor2 port map(q_temp(1), q_temp(0), d(1));

    and2_1: and2 port map(q_temp(1), q_temp(0), q1q0);
    xor2_2: xor2 port map(q_temp(2), q1q0, d(2));

    and2_2: and2 port map(q_temp(2), q1q0, q2q1q0);
    xor2_3: xor2 port map(q_temp(3), q2q1q0, d(3));

    dff_0: pdflip_wrst port map(d(0), clk, rst, q_temp(0));
    dff_1: pdflip_wrst port map(d(1), clk, rst, q_temp(1));
    dff_2: pdflip_wrst port map(d(2), clk, rst, q_temp(2));
    dff_3: pdflip_wrst port map(d(3), clk, rst, q_temp(3));

    q<=q_temp;

end structural;