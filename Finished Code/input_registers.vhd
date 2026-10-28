library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity input_register is
    port (
        d   : in std_logic;
        load : in std_logic;
        clk    : in std_logic;
        q   : out std_logic
    );
end input_register;

architecture structural of input_register is
    component mux
        port (
            input1   : in std_logic;
            input2   : in std_logic;
            sel      : in std_logic;
            y : out std_logic
        );
        end component;

    component ndflip
        port (
            d   : in std_logic;
            clk   : in std_logic;
            q : out std_logic
        );
        end component;

--declaration of individual gates
for mux_1: mux use entity work.mux(structural);
for ndflip_1: ndflip use entity work.ndflip(structural);
--intermediate signals between gates
signal sel_1, q_int: std_logic;

begin
--mapping ports to gates
    mux_1: mux port map(q_int, d, load, sel_1);

    ndflip_1: ndflip port map(sel_1, clk, q_int);

    q <= q_int;
end structural;