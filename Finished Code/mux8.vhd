library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity mux8 is
    port (
        input1   : in std_logic_vector(7 downto 0);
        input2   : in std_logic_vector(7 downto 0);
        sel  : in std_logic;
        y   : out std_logic_vector(7 downto 0)
    );
end mux8;

architecture structural of mux8 is
    component mux
        port (
        input1   : in std_logic;
        input2   : in std_logic;
        sel  : in std_logic;
        y   : out std_logic
        );
        end component;
    
    --basic gate instantiation
    for mux_1, mux_2, mux_3, mux_4, mux_5, mux_6, mux_7, mux_8: mux use entity work.mux(structural);

begin
    mux_1 : mux port map (input1(0), input2(0), sel, y(0));
    mux_2 : mux port map (input1(1), input2(1), sel, y(1));
    mux_3 : mux port map (input1(2), input2(2), sel, y(2));
    mux_4 : mux port map (input1(3), input2(3), sel, y(3));
    mux_5 : mux port map (input1(4), input2(4), sel, y(4));
    mux_6 : mux port map (input1(5), input2(5), sel, y(5));
    mux_7 : mux port map (input1(6), input2(6), sel, y(6));
    mux_8 : mux port map (input1(7), input2(7), sel, y(7));
end structural;