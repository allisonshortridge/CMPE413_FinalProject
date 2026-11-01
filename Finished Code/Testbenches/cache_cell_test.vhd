library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity cache_cell_test is
end cache_cell_test;

architecture test of cache_cell_test is
    component cache_cell
        port (
            wr_data   : in  std_logic;
            chip_en : in  std_logic;
            rd_wr : in std_logic;
            rd_data   : out std_logic
        );
    end component;


    for cache_cell_1: cache_cell use entity work.cache_cell(structural);

    signal wr_data, chip_en, rd_wr, rd_data : std_logic;

begin
    cache_cell_1: cache_cell port map(wr_data, chip_en, rd_wr, rd_data);

    io_process : process
        file infile : text is in "cache_cell_in.txt";
        file outfile : text is out "cache_cell_out.txt";
        variable data_in, en_chip, rw_in : std_logic;
        variable inbuf, outbuf : line;
        variable sp : character;
    begin
        while not (endfile(infile)) loop
            readline(infile, inbuf);
            read(inbuf, data_in);
            read(inbuf, sp);
            read(inbuf, en_chip);
            read(inbuf, sp);
            read(inbuf, rw_in);

            wr_data <= data_in;
            chip_en <= en_chip;
            rd_wr <= rw_in;

            wait for 10 ns;

            write(outbuf, rd_data);
            writeline(outfile, outbuf);
        end loop;
        wait;
    end process io_process;

end test;