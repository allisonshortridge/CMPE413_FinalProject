library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity address_decoder is
    port (
        address     :   in std_logic_vector(5 downto 0);
        chip_en     :   in std_logic;
        rq_tag         :   out std_logic_vector(1 downto 0);
        block_en    :   out std_logic_vector(3 downto 0);
        byte_en     :   out std_logic_vector(15 downto 0)
    );
end address_decoder;

architecture structural of address_decoder is

component decoder2to4
    port (
        A1    : in std_logic;
        A0    : in std_logic;
        E     : in std_logic;
        Y3    : out std_logic;
        Y2    : out std_logic;
        Y1    : out std_logic;
        Y0    : out std_logic
    );
end component;

for block_decoder, byte_dec0, byte_dec1, byte_dec2, byte_dec3: decoder2to4 use entity work.decoder2to4(structural);

signal blk: std_logic_vector(3 downto 0);

begin
    
    -- passes first 2 bits of address as tag
    rq_tag<=address(5 downto 4);

    -- decode which block is being accessed
    block_decoder: decoder2to4 port map(address(3), address(2), chip_en, blk(3), blk(2), blk(1), blk(0));

    -- decode which byte in a block is being accessed
    byte_dec0: decoder2to4 port map(address(1), address(0), blk(0), byte_en(3), byte_en(2), byte_en(1), byte_en(0));
    byte_dec1: decoder2to4 port map(address(1), address(0), blk(1), byte_en(7), byte_en(6), byte_en(5), byte_en(4));
    byte_dec2: decoder2to4 port map(address(1), address(0), blk(2), byte_en(11), byte_en(10), byte_en(9), byte_en(8));
    byte_dec3: decoder2to4 port map(address(1), address(0), blk(3), byte_en(15), byte_en(14), byte_en(13), byte_en(12));

    block_en<=blk;

end structural;