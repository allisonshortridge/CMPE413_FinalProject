library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity lru_test is
end lru_test;

architecture test of lru_test is
    component lru_unit
        port (
            wr_data     :   in std_logic_vector(7 downto 0);
            rq_tag      :   in std_logic_vector(1 downto 0);
            block_en    :   in std_logic_vector(3 downto 0);
            byte_en     :   in std_logic_vector(15 downto 0);
            data_wr     :   in std_logic; 
            tv_wr       :   in std_logic; 
            refill      :   in std_logic;   
            lookup      :   in std_logic;  
            way_in      :   in std_logic;   
            rd_done     :   in std_logic;    
            clk         :   in std_logic;
            rst         :   in std_logic;
            valid0      :   out std_logic;
            valid1      :   out std_logic;
            tag0        :   out std_logic_vector(1 downto 0);
            tag1        :   out std_logic_vector(1 downto 0);
            rd_data0    :   out std_logic_vector(7 downto 0);
            rd_data1    :   out std_logic_vector(7 downto 0);
            victim      :   out std_logic
    );
    end component;
    
    for lru_1: lru_unit use entity work.lru_unit(structural);

    signal wr_data  : std_logic_vector(7 downto 0)  := (others => '0');
    signal rq_tag   : std_logic_vector(1 downto 0)  := (others => '0');
    signal block_en : std_logic_vector(3 downto 0)  := (others => '0');
    signal byte_en  : std_logic_vector(15 downto 0) := (others => '0');
    signal data_wr, tv_wr, refill, lookup, way_in, rd_done : std_logic := '0';
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal valid0, valid1, victim : std_logic;
    signal tag0, tag1 : std_logic_vector(1 downto 0);
    signal rd_data0, rd_data1 : std_logic_vector(7 downto 0);

    signal done : boolean := false;

begin
    lru_1: lru_unit port map(wr_data, rq_tag, block_en, byte_en, data_wr, tv_wr, refill, lookup, way_in, rd_done, clk, rst,
        valid0, valid1, tag0, tag1, rd_data0, rd_data1, victim);
    
    clk_gen : process
    begin
        while not done loop
            clk <= '0'; wait for 10 ns;
            clk <= '1'; wait for 10 ns;
        end loop;
        wait;
    end process clk_gen;

    io_process : process
        file infile  : text is in  "lru_in.txt";
        file outfile : text is out "lru_out.txt";
        variable wr_in   : std_logic_vector(7 downto 0);
        variable tag_in  : std_logic_vector(1 downto 0);
        variable blk_in  : std_logic_vector(3 downto 0);
        variable byte_in : std_logic_vector(15 downto 0);
        variable dw_in, tv_in, ref_in, look_in, way_i, done_in, rst_in : std_logic;
        variable inbuf, outbuf : line;
        variable sp : character;
    begin
        while not endfile(infile) loop
            readline(infile, inbuf);
            read(inbuf, wr_in);     
            read(inbuf, sp);

            read(inbuf, tag_in);    
            read(inbuf, sp);

            read(inbuf, blk_in);    
            read(inbuf, sp);

            read(inbuf, byte_in);   
            read(inbuf, sp);

            read(inbuf, dw_in);     
            read(inbuf, sp);

            read(inbuf, tv_in);     
            read(inbuf, sp);

            read(inbuf, ref_in);    
            read(inbuf, sp);

            read(inbuf, look_in);   
            read(inbuf, sp);

            read(inbuf, way_i);     
            read(inbuf, sp);

            read(inbuf, done_in);   
            read(inbuf, sp);

            read(inbuf, rst_in);

            wait until rising_edge(clk);
            wait for 2 ns;

            wr_data  <= wr_in;
            rq_tag   <= tag_in;
            block_en <= blk_in;
            byte_en  <= byte_in;
            data_wr  <= dw_in;
            tv_wr    <= tv_in;
            refill   <= ref_in;
            lookup   <= look_in;
            way_in   <= way_i;
            rd_done  <= done_in;
            rst      <= rst_in;

            wait for 16 ns;

            write(outbuf, valid0);
            write(outbuf, ' ');

            write(outbuf, valid1);
            write(outbuf, ' ');

            write(outbuf, tag0);
            write(outbuf, ' ');

            write(outbuf, tag1);
            write(outbuf, ' ');

            write(outbuf, victim);
            write(outbuf, ' ');

            write(outbuf, rd_data0);
            write(outbuf, ' ');

            write(outbuf, rd_data1);
            writeline(outfile, outbuf);

        end loop;
        wait for 20 ns;
        done <= true;
        wait;
    end process io_process;
    
end test;