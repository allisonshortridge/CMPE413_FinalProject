library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity cd_out_test is 
end cd_out_test;

architecture test of cd_out_test is
    component cd_out port (
            data_in   : in std_logic_vector(7 downto 0);
            en  : in std_logic;
            y   : out std_logic_vector(7 downto 0)
        );
    end component;

    for cd_out_1: cd_out use entity work.cd_out(structural);

    signal data_in, y: std_logic_vector(7 downto 0);
    signal en: std_logic;
    signal clock: std_logic;
    signal done: std_logic := '0';

    --test values
    type byte_array is array (0 to 9) of std_logic_vector(7 downto 0);
    constant data_in_vals : byte_array := (
        "00000000",
        "11111111",
        "10101010",
        "01010101",
        "00100100",
        "10101010",
        "11111111",
        "00000000",
        "01010101",
        "10000001"
    );

    --iterates through whether enable output of values
    constant en_vals : std_logic_vector(0 to 9) := "1111100011";

begin 
    cd_out_1: cd_out port map(data_in, en, y);

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
        data_in <= data_in_vals(k);
        en <= en_vals(k);

        wait until falling_edge(clock);

        --write result
        write(buff, string'("data_in="));
        write(buff, data_in);
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