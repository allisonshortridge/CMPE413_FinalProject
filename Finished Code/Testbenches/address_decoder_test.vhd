library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity address_decoder_test is
end address_decoder_test;

architecture test of address_decoder_test is
    component address_decoder
        port (
            address     :   in std_logic_vector(5 downto 0);
            chip_en     :   in std_logic;
            refill      :   in std_logic;                       
            byte_cnt    :   in std_logic_vector(1 downto 0);    
            rq_tag         :   out std_logic_vector(1 downto 0);
            block_en    :   out std_logic_vector(3 downto 0);
            byte_en     :   out std_logic_vector(15 downto 0)
        );
    end component;


    for address_decoder_1: address_decoder use entity work.address_decoder(structural);

    signal address : std_logic_vector(5 downto 0);
    signal chip_en, refill : std_logic;
    signal byte_cnt, rq_tag : std_logic_vector(1 downto 0);
    signal block_en : std_logic_vector(3 downto 0);
    signal byte_en : std_logic_vector(15 downto 0);

begin
    address_decoder_1: address_decoder port map(address, chip_en, refill, byte_cnt, rq_tag, block_en, byte_en);

io_process : process

    file infile : text is in "address_decoder_in.txt";
    file outfile : text is out "address_decoder_out.txt";
    variable address_in : std_logic_vector(5 downto 0);
    variable en_chip, refill_req : std_logic;
    variable cnt_byte: std_logic_vector(1 downto 0);

    variable inbuf, outbuf : line;
    variable sp : character; --to handle the space between values in txt file

begin
    while not (endfile(infile)) loop
        readline(infile, inbuf);
        read(inbuf, address_in);   
        read(inbuf, sp);
        read(inbuf, en_chip);      
        read(inbuf, sp);
        read(inbuf, refill_req);   
        read(inbuf, sp);
        read(inbuf, cnt_byte);

        address  <= address_in;
        chip_en  <= en_chip;
        refill   <= refill_req;
        byte_cnt <= cnt_byte;

        wait for 10 ns;

        write(outbuf, rq_tag);
        write(outbuf, ' ');
        write(outbuf, block_en);
        write(outbuf, ' ');
        write(outbuf, byte_en);
        writeline(outfile, outbuf);
        
    end loop;
        wait;
end process io_process;

end test;