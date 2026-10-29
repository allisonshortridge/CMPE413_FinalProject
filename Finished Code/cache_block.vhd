library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity cache_block is
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
end cache_block;

architecture structural of cache_block is

-- 8 cache cells
component cache_byte
    port (
        wr_data     :   in std_logic_vector(7 downto 0);
        chip_en     :   in std_logic;
        rd_wr       :   in std_logic;
        rd_data   :   out std_logic_vector(7 downto 0)
    );
end component;

-- 1-bit cache cell for valid bit and 2-bit tag
component cache_cell
    port (
        wr_data   : in  std_logic;
        chip_en : in  std_logic;
        rd_wr : in std_logic;
        rd_data   : out std_logic
    );
end component;


for cache_byte0, cache_byte1, cache_byte2, cache_byte3: cache_byte use entity work.cache_byte(structural);
for valid_bit1, tag1, tag0: cache_cell use entity work.cache_cell(structural);

begin

    -- use byte enable from decoder logic to determine which byte is going to be accessed
    cache_byte0: cache_byte port map(wr_data, byte_en(0), rd_wr, rd_data);
    cache_byte1: cache_byte port map(wr_data, byte_en(1), rd_wr, rd_data);
    cache_byte2: cache_byte port map(wr_data, byte_en(2), rd_wr, rd_data);
    cache_byte3: cache_byte port map(wr_data, byte_en(3), rd_wr, rd_data);

    valid_bit1: cache_cell port map(wr_valid, chip_en, vt_en, valid_bit);

    tag1: cache_cell port map(wr_tag(1), chip_en, vt_en, tag(1));
    tag0: cache_cell port map(wr_tag(0), chip_en, vt_en, tag(0));

end structural;