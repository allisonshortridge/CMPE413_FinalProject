--
-- Entity: 2to4decoder_test
-- Architecture: test
-- Author: s348 (Allison Shortridge)
-- Created On: 10/10/2026
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;


entity decoder2to4_test is 
end decoder2to4_test;

architecture test of decoder2to4_test is
    component
        decoder2to4 port (
            A1    : in std_logic;
            A0    : in std_logic;
            E     : in std_logic;
            Y3    : out std_logic;
            Y2    : out std_logic;
            Y1    : out std_logic;
            Y0    : out std_logic
        );
    end component;

    for decoder2to4_1: decoder2to4 use entity work.decoder2to4(structural);
    signal a1, a0, e: std_logic;
    signal y3, y2, y1, y0: std_logic;
    signal clock: std_logic;

begin 
    decoder2to4_1: decoder2to4 port map(a1, a0, e, y3, y2, y1, y0);

clk : process
begin  -- process clk

    clock<='0','1' after 5 ns;
    wait for 10 ns;

end process clk;

io_process: process
    file infile : text is in "2to4decoder_in.txt";
    file outfile : text is out "2to4decoder_out.txt";
    variable a_1, a_0, e_0: std_logic;
    variable y_3, y_2, y_1, y_0: std_logic;
    variable buf : line;

begin
    while not (endfile(infile)) loop
        readline(infile, buf);
        read(buf, e_0);
        e <= e_0;
        
        readline(infile, buf);
        read(buf, a_1);
        a1 <= a_1;

        readline(infile, buf);
        read(buf, a_0);
        a0 <= a_0;

        wait until falling_edge(clock);

        y_3:=y3;
        y_2:=y2;
        y_1:=y1;
        y_0:=y0;

        write(buf, y3);
        writeline(outfile, buf);

        write(buf, y2);
        writeline(outfile, buf);

        write(buf, y1);
        writeline(outfile, buf);

        write(buf, y0);
        writeline(outfile, buf);

    end loop;
        wait;
    end process io_process;


end test;