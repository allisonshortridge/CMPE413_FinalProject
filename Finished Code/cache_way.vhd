-- four blocks of 4-bytes w/ 2-bit tag and valid bit
    -- index decoder, byte-offset select, read mux, outputs for stored tag and valid bit

    -- write inputs: chip-enable, selector, data, and address bits

-- *could be separate file* 2-bit equality comparator that combines with valid bit to hit signal


library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity cache_way is
    port (
        wr_data     :   in std_logic_vector(7 downto 0);
        block_en    :   in std_logic_vector(3 downto 0);
        byte_en     :   in std_logic_vector(15 downto 0);
        rd_wr       :   in std_logic;
        vt_en       :   in std_logic;
        wr_valid    :   in std_logic;
        wr_tag      :   in std_logic_vector(1 downto 0);
        valid_bit   :   out std_logic;
        tag         :   out std_logic_vector(1 downto 0);
        rd_data    :   out std_logic_vector(7 downto 0)
    );
end cache_way;

architecture structural of cache_way is


component cache_block
    port (
        wr_data     :   in std_logic_vector(7 downto 0);
        chip_en     :   in std_logic;
        byte_en     :   in std_logic_vector(3 downto 0);
        rd_wr       :   in std_logic;
        vt_en       :   in std_logic;
        wr_valid    :   in std_logic;
        wr_tag      :   in std_logic_vector(1 downto 0);
        valid_bit   :   out std_logic;
        tag         :   out std_logic_vector(1 downto 0);
        rd_data   :   out std_logic_vector(7 downto 0)
    );
end component;

for cache_block0, cache_block1, cache_block2, cache_block3: cache_block use entity work.cache_block(structural);

begin

    cache_block0: cache_block port map(wr_data, block_en(0), byte_en(3 downto 0), rd_wr, vt_en, wr_valid, wr_tag, valid_bit, tag, rd_data);
    cache_block1: cache_block port map(wr_data, block_en(1), byte_en(7 downto 4), rd_wr, vt_en, wr_valid, wr_tag, valid_bit, tag, rd_data);
    cache_block2: cache_block port map(wr_data, block_en(2), byte_en(11 downto 8), rd_wr, vt_en, wr_valid, wr_tag, valid_bit, tag, rd_data);
    cache_block3: cache_block port map(wr_data, block_en(3), byte_en(15 downto 12), rd_wr, vt_en, wr_valid, wr_tag, valid_bit, tag, rd_data);
    
end structural;
