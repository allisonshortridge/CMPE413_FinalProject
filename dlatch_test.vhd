--
-- Entity: dlatch_test
-- Architecture: test
-- Author: s348 (Allison Shortridge)
-- Created On: 10/10/2026
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity dlatch_test is 
end dlatch_test;

architecture test of dlatch_test is
    component
        Dlatch port(
            d   : in  std_logic;
            clk : in  std_logic;
            q   : out std_logic;
            qbar: out std_logic
        );
    end component;

    -- d and q initialized to 0
    signal d_test, clk_test: std_logic := '0';
    signal q_test, qbar_test: std_logic;

begin
    -- dlatch object to test
    dlatch_tb: Dlatch
        port map(
            d => d_test,
            clk => clk_test,
            q => q_test,
            qbar => qbar_test
        );

    -- process for formatting and printing values
    print_proc: process(d_test, clk_test, q_test, qbar_test)
        variable out_line: line;
    begin
        write(out_line, string'("clk = "));
        write(out_line, clk_test);

        write(out_line, string'(", d = "));
        write(out_line, d_test);

        write(out_line, string'(", q = "));
        write(out_line, q_test);

        write(out_line, string'(", qbar = "));
        write(out_line, qbar_test);

        writeline(output, out_line);
    end process;

    -- process to test each case of the dlatch
    test_proc: process
    begin
        clk_test <= '1';
        d_test <= '1';
        wait for 20 ns;
        d_test <= '0';
        wait for 20 ns;
        d_test <= '1';
        wait for 20 ns;

        clk_test <= '0';
        wait for 20 ns;
        d_test <= '0';
        wait for 20 ns;
        d_test <= '1';
        wait for 20 ns;

        clk_test <= '1';
        d_test <= '0';
        wait for 20 ns;

        wait;
    end process;
end test;