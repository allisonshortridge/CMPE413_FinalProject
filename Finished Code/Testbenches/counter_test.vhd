library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity counter_test is
end counter_test;

architecture test of counter_test is
    component counter port (
            clk : in std_logic;
            rst : in std_logic;
            q   : out std_logic_vector(3 downto 0)
        );
    end component;

    for counter_1: counter use entity work.counter(structural);

    signal q: std_logic_vector(3 downto 0);
    signal rst: std_logic;
    signal clock: std_logic;
    signal done: std_logic := '0';

    --number of test cycles
    constant N : integer := 32;

    --if 1, rst high and counter resets to 0
    constant rst_vals : std_logic_vector(0 to N-1) := "11000000000000000000001000011000";

begin
    counter_1: counter port map(clock, rst, q);

clk : process
begin
    --stop the clock after done bit set
    if done = '1' then
        wait;
    end if;

    clock<='0','1' after 5 ns;
    wait for 10 ns;
end process clk;

io_process: process
    variable out_line : line;
    variable exp_q : integer := 0;
    variable exp_vec : std_logic_vector(3 downto 0);

begin
    for k in 0 to N-1 loop
        --new input on the falling edge, so it is stable before the rising edge
        wait until falling_edge(clock);
        rst <= rst_vals(k);

        --counter updates on the rising edge
        wait until rising_edge(clock);
        wait for 1 ns;

        --expected count
        if rst_vals(k) = '1' then
            exp_q := 0;
        else
            exp_q := (exp_q + 1) mod 16;
        end if;
        exp_vec := std_logic_vector(to_unsigned(exp_q, 4));

        --write results
        write(out_line, string'(" Cycle: "));
        write(out_line, k);
        write(out_line, string'(" Reset: "));
        write(out_line, rst);
        write(out_line, string'("  ->  Count: "));
        write(out_line, q);
        write(out_line, string'("  Expected: "));
        write(out_line, exp_vec);
        writeline(output, out_line);

    end loop;
    --set done bit
    done <= '1';
    wait;
end process io_process;

end test;