library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity output_registers is
    port (
        data_in   : in std_logic_vector(7 downto 0);
        load  : in std_logic;
        clk : in std_logic;
        data_out  : out std_logic_vector(7 downto 0)
    );
end output_registers;

architecture structural of output_registers is
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
for mux_1, mux_2, mux_3, mux_4, mux_5, mux_6, mux_7, mux_8: mux use entity work.mux(structural);
for ndflip_1, ndflip_2, ndflip_3, ndflip_4, ndflip_5, ndflip_6, ndflip_7, ndflip_8: ndflip use entity work.ndflip(structural);
--intermediate signals between gates
signal sel_1, sel_2, sel_3, sel_4, sel_5, sel_6, sel_7, sel_8: std_logic;
signal q_int: std_logic_vector(7 downto 0);

begin
--mapping ports to gates
    mux_1: mux port map(q_int(0), data_in(0), load, sel_1);
    mux_2: mux port map(q_int(1), data_in(1), load, sel_2);
    mux_3: mux port map(q_int(2), data_in(2), load, sel_3);
    mux_4: mux port map(q_int(3), data_in(3), load, sel_4);
    mux_5: mux port map(q_int(4), data_in(4), load, sel_5);
    mux_6: mux port map(q_int(5), data_in(5), load, sel_6);
    mux_7: mux port map(q_int(6), data_in(6), load, sel_7);
    mux_8: mux port map(q_int(7), data_in(7), load, sel_8);

    ndflip_1: ndflip port map(sel_1, clk, q_int(0));
    ndflip_2: ndflip port map(sel_2, clk, q_int(1));
    ndflip_3: ndflip port map(sel_3, clk, q_int(2));
    ndflip_4: ndflip port map(sel_4, clk, q_int(3));
    ndflip_5: ndflip port map(sel_5, clk, q_int(4));
    ndflip_6: ndflip port map(sel_6, clk, q_int(5));
    ndflip_7: ndflip port map(sel_7, clk, q_int(6));
    ndflip_8: ndflip port map(sel_8, clk, q_int(7));

    data_out <= q_int;
end structural;