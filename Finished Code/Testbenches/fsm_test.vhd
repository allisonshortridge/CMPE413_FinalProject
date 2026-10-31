library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity fsm_test is
end fsm_test;

architecture test of fsm_test is
    component cache_fsm port (
            clk      : in std_logic;
            reset    : in std_logic;
            start    : in std_logic;
            rw       : in std_logic;
            hit      : in std_logic;
            busy     : out std_logic;
            load_in  : out std_logic;
            out_load : out std_logic;
            out_oe   : out std_logic;
            enable   : out std_logic;
            ma_oe    : out std_logic;
            dec_en   : out std_logic;
            refill   : out std_logic;
            byte_cnt : out std_logic_vector(1 downto 0);
            data_wr  : out std_logic;
            tv_wr    : out std_logic
        );
    end component;

    for cache_fsm_1: cache_fsm use entity work.cache_fsm(structural);

    signal reset, start, rw, hit : std_logic;
    signal busy, load_in, out_load, out_oe, enable, ma_oe, dec_en, refill : std_logic;
    signal data_wr, tv_wr : std_logic;
    signal byte_cnt : std_logic_vector(1 downto 0);
    signal clock: std_logic;
    signal done: std_logic := '0';

begin
    cache_fsm_1: cache_fsm port map(clk => clock, reset => reset, start => start, rw => rw, hit => hit,
        busy => busy, load_in => load_in, out_load => out_load, out_oe => out_oe, enable => enable,
        ma_oe => ma_oe, dec_en => dec_en, refill => refill, byte_cnt => byte_cnt,
        data_wr => data_wr, tv_wr => tv_wr);

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
    file infile : text is in "./cache_fsm_in.txt";
    variable buf : line;
    variable out_line : line;
    variable reset_v, start_v, rw_v, hit_v : std_logic;
    variable exp_outs : std_logic_vector(11 downto 0);
    variable got : std_logic_vector(11 downto 0);
    variable k : integer := 0;
    variable fails : integer := 0;

begin
    while not endfile(infile) loop
        readline(infile, buf);

        --copy comment lines to output
        if buf(buf'left) = '-' then
            writeline(output, buf);
            next;
        end if;
        
        read(buf, reset_v);
        read(buf, start_v);
        read(buf, rw_v);
        read(buf, hit_v);
        read(buf, exp_outs);

        --new inputs on rising edge
        wait until rising_edge(clock);
        reset <= reset_v;
        start <= start_v;
        rw    <= rw_v;
        hit   <= hit_v;

        --states update on falling edge
        wait until falling_edge(clock);
        wait for 1 ns;

        got := busy & load_in & out_load & out_oe & enable & ma_oe & dec_en & refill & data_wr & tv_wr & byte_cnt;

        --write results
        write(out_line, string'("Cycle: "));
        write(out_line, k);
        write(out_line, string'(" Reset: "));
        write(out_line, reset);
        write(out_line, string'(" Start: "));
        write(out_line, start);
        write(out_line, string'(" Read/Write: "));
        write(out_line, rw);
        write(out_line, string'(" Hit: "));
        write(out_line, hit);
        writeline(output, out_line);
        write(out_line, string'(" Busy: "));
        write(out_line, busy);
        write(out_line, string'(" Load_in: "));
        write(out_line, load_in);
        write(out_line, string'(" Out_load: "));
        write(out_line, out_load);
        write(out_line, string'(" Out_oe: "));
        write(out_line, out_oe);
        write(out_line, string'(" Enable: "));
        write(out_line, enable);
        write(out_line, string'(" MA_oe: "));
        write(out_line, ma_oe);
        write(out_line, string'(" Dec_en: "));
        write(out_line, dec_en);
        write(out_line, string'(" Refill: "));
        write(out_line, refill);
        write(out_line, string'(" Data_wr: "));
        write(out_line, data_wr);
        write(out_line, string'(" Tv_wr: "));
        write(out_line, tv_wr);
        write(out_line, string'(" Byte_cnt: "));
        write(out_line, byte_cnt);
        writeline(output, out_line);
        --break to separate each test
        write(out_line, string'(" ----------------------------------------------"));
        writeline(output, out_line);
        k := k + 1;

    end loop;
    --set done bit
    done <= '1';
    wait;
end process io_process;

end test;