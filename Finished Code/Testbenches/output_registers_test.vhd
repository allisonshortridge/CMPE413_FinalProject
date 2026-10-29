library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity output_registers_test is 
end output_registers_test;

architecture test of output_registers_test is
    component output_registers port (
            data_in   : in std_logic_vector(7 downto 0);
            load : in std_logic;
            clk : in std_logic;
            data_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    for output_registers_1: output_registers use entity work.output_registers(structural);

    signal data_in, data_out: std_logic_vector(7 downto 0);
    signal load: std_logic;
    signal clock: std_logic;
    signal done: std_logic := '0';

    --test values
    type byte_array is array (0 to 7) of std_logic_vector(7 downto 0);
    constant data_in_vals : byte_array := (
        "10100101",   -- A5, load
        "00111100",   -- 3C, hold
        "00111100",   -- 3C, load
        "11111111",   -- FF, load
        "00000000",   -- 00, hold
        "00000000",   -- 00, hold
        "00000000",   -- 00, load
        "01011010"    -- 5A, hold
    );

    --iterates through whether to load or hold values in byte array
    constant load_vals : std_logic_vector(0 to 7) := "10110010";

begin 
    output_registers_1: output_registers port map(data_in, load, clock, data_out);

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
    variable buf : line;

begin
    for k in 0 to 7 loop
        --new inputs on rising edge
        wait until rising_edge(clock);
        data_in <= data_in_vals(k);
        load <= load_vals(k);

        --latches inpus on falling edge
        wait until falling_edge(clock);
        wait for 1 ns;

        --write result
        write(buf, string'("load="));
        write(buf, load);
        write(buf, string'(" data_in="));
        write(buf, data_in);
        write(buf, string'("  ->  data_out="));
        write(buf, data_out);
        writeline(output, buf);

    end loop;
    --set done bit
    done <= '1';
    wait;
end process io_process;


end test;