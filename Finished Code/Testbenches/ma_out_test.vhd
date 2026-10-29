library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity ma_out_test is 
end ma_out_test;

architecture test of ma_out_test is
    component ma_out port (
            addr_in   : in std_logic_vector(7 downto 0);
            en  : in std_logic;
            y   : out std_logic_vector(7 downto 0)
        );
    end component;

    for ma_out_1: ma_out use entity work.ma_out(structural);

    signal addr_in, y: std_logic_vector(7 downto 0);
    signal en: std_logic;
    signal clock: std_logic;
    signal done: std_logic := '0';

    --test values
    type byte_array is array (0 to 9) of std_logic_vector(7 downto 0);
    constant addr_in_vals : byte_array := (
        "00000000",
        "00000100",
        "00010100",
        "00100100",
        "00110100",
        "00111100",
        "00100100",
        "00111100",
        "00000100",
        "00110100"
    );
    --iterates through whether enable output of values
    constant en_vals : std_logic_vector(0 to 9) := "1111110011";

begin 
    ma_out_1: ma_out port map(addr_in, en, y);

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
    variable buff : line;

begin
    for k in 0 to 9 loop
        addr_in <= addr_in_vals(k);
        en <= en_vals(k);

        wait until falling_edge(clock);

        --write results
        write(buff, string'("addr_in="));
        write(buff, addr_in);
        write(buff, string'(" en="));
        write(buff, en);
        write(buff, string'("  ->  y="));
        write(buff, y);
        writeline(output, buff);

    end loop;
    --set done
    done <= '1';
    wait;
end process io_process;

end test;