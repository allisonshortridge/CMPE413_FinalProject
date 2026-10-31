library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity cache_top_test is
end cache_top_test;

architecture test of cache_top_test is
    component cache_top port (
            ca     : in std_logic_vector(5 downto 0);
            cd     : inout std_logic_vector(7 downto 0);
            rw     : in std_logic;
            start  : in std_logic;
            clk    : in std_logic;
            reset  : in std_logic;
            md     : in std_logic_vector(7 downto 0);
            vdd    : in std_logic;
            gnd    : in std_logic;
            busy   : out std_logic;
            enable : out std_logic;
            ma     : out std_logic_vector(5 downto 0)
        );
    end component;

    for cache_top_1: cache_top use entity work.cache_top(structural);

    signal vdd, gnd: std_logic;
    signal cd, md: std_logic_vector(7 downto 0);
    signal ca, ma: std_logic_vector(5 downto 0);
    signal rw, reset, clk, start, clock, busy, enable: std_logic;
    signal done: std_logic := '0';

    --clock cycle count
    signal clk_count: integer := 0;

    --write every pin of chip to output
    procedure print_output is
        variable out_line: line;

    begin
        write(out_line, string'(" Clock: "));
        write(out_line, clk_count);
        write(out_line, string'(" Start: "));
        write(out_line, start);
        write(out_line, string'(" Read/Write: "));
        write(out_line, rw);
        write(out_line, string'(" Reset: "));
        write(out_line, reset);
        writeline(output, out_line);
        write(out_line, string'(" CPU address: "));
        write(out_line, ca);
        write(out_line, string'(" CPU data: "));
        write(out_line, cd);
        writeline(output, out_line);
        write(out_line, string'(" Memory data: "));
        write(out_line, md);
        writeline(output, out_line);
        writeline(output, out_line);
        write(out_line, string'(" Busy: "));
        write(out_line, busy);
        write(out_line, string'(" Memory  Enable: "));
        write(out_line, enable);
        writeline(output, out_line);
        write(out_line, string'(" Memory  Address: "));
        write(out_line, ma);
        writeline(output, out_line);
        --break to separate each test
        write(out_line, string'(" ----------------------------------------------"));
        writeline(output, out_line);

    end print_output;

begin
    vdd <= '1';
    gnd <= '0';
    clk <= clock;

    cache_top_1: cache_top port map(ca, cd, rw, start, clk, reset, md, vdd, gnd, busy, enable, ma);

clk1: process
begin
    --stop the clock after done bit set
    if done = '1' then
        wait;
    end if;

    clock<='1','0' after 5 ns;
    wait for 10 ns;
end process clk1;

io_process: process
    file infile : text is in "./cache_in.txt";
    variable buf: line;
    variable value: std_logic_vector(7 downto 0);
    variable value0: std_logic_vector(5 downto 0);
    variable value1: std_logic;

begin
    while not (endfile(infile)) loop
        --print pins before clock edge
        wait until rising_edge(clock);
        print_output;

        --new inputs on rising edge (address, cpu data, read/write, start, reset)
        readline(infile, buf);
        read(buf, value0);
        ca <= value0;
        readline(infile, buf);
        read(buf, value);
        cd <= value;
        readline(infile, buf);
        read(buf, value1);
        rw <= value1;
        readline(infile, buf);
        read(buf, value1);
        start <= value1;
        readline(infile, buf);
        read(buf, value1);
        reset <= value1;

        --latch inputs on falling edge
        wait until falling_edge(clock);
        readline(infile, buf);
        read(buf, value);
        md <= value;
        --progress clock
        clk_count <= clk_count + 1;

        --write results
        print_output;

    end loop;
    --final output
    wait until rising_edge(clock);
    print_output;

    --set done bit
    done <= '1';
    wait;
end process io_process;

end test;