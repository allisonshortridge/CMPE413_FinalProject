library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity cd_reg_test is 
end cd_reg_test;

architecture test of cd_reg_test is
    component cd_reg port (
        ca  : in std_logic_vector(7 downto 0);
        load    : in std_logic;
        clk : in std_logic;
        q   : output std_logic_vector(7 downto 0)
        );
    end component;

    for cd_reg_1: cd_reg use entity work.cd_reg(structural);

    signal ca, q: std_logic_vector(7 downto 0);
    signal load: std_logic; 
    signal clock: std_logic;
    signal done: std_logic := '0';

    --test values
    type byte_array is array (0 to 7) of std_logic_vector(7 downto 0);
    constant ca_vals : byte_array := (
        "10100101",   
        "00111100",   
        "00111100",   
        "11111111",   
        "00000000",   
        "00000000",   
        "00000000",   
        "01011010"
    );

    --iterates through whether to load or hold values in byte array
    constant load_vals : std_logic_vector(0 to 7) := "10110010";

begin 
    cd_reg_1: cd_reg port map(ca, load, clock, q);

clk : process
begin
    --stop the clock after done bit set
    if done = '1' then
        wait;
    end if;

    clock<='0','1' after 5 ns;
    wait for 10 ns;
end process clk;

--new inputs on rising edge
stim_process: process
begin
    for k in 0 to 7 loop
        wait until rising_edge(clock);
        ca <= ca_vals(k);
        load <= load_vals(k);
    end loop;
    wait;
end process stim_process;

io_process: process
    variable buff : line;

begin
    --skip the first rising edge
    wait until rising_edge(clock);

    for k in 0 to 7 loop
        wait until rising_edge(clock);

        --write results
        write(buff, string'("load="));
        write(buff, load);
        write(buff, string'(" ca="));
        write(buff, ca);
        write(buff, string'(" q="));
        write(buff, q);
        writeline(output, buff);

    end loop;
    --set done bit
    done <= '1';
    wait;
end process io_process;

end test;
