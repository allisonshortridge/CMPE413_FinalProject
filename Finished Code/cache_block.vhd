--one block = 4 data bytes + 2 bit tag + valid bit
--
--cache_byte        4 data bytes. byte_en(i) is chip enable of byte i
--tag1, tag0        tag cells (wr_tag in, tag out)
--valid_bit1        valid cell (wr_valid in, valid_bit out)
--
--chip_en     selects block. tag, valid and selected byte only driven while chip_en = 1
--byte_en     byte select from address decoder
--rd_wr       1 = read, 0 = write
--vt_en       tag/valid write, 1 = read, 0 = write
--
--data and tag/valid have separate signals. refill writes tag and valid on byte 0 only
--rd_data is for all 4 bytes
--tag and valid sent out while chip_en = 1
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