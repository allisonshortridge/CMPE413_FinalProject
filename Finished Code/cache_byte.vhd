library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity cache_byte is
    port (
        wr_data     :   in std_logic_vector(7 downto 0);
        chip_en     :   in std_logic;
        rd_wr       :   in std_logic;
        rd_data   :   out std_logic_vector(7 downto 0)
    );
end cache_byte;

architecture structural of cache_byte is

-- 1-bit cache cell
component cache_cell
    port (
        wr_data   : in  std_logic;
        chip_en : in  std_logic;
        rd_wr : in std_logic;
        rd_data   : out std_logic
    );
end component;

for bit7, bit6, bit5, bit4, bit3, bit2, bit1, bit0: cache_cell use entity work.cache_cell(structural);

begin

    -- 8 cache cells
    bit7: cache_cell port map(wr_data(7), chip_en, rd_wr, rd_data(7));
    bit6: cache_cell port map(wr_data(6), chip_en, rd_wr, rd_data(6));
    bit5: cache_cell port map(wr_data(5), chip_en, rd_wr, rd_data(5));
    bit4: cache_cell port map(wr_data(4), chip_en, rd_wr, rd_data(4));
    bit3: cache_cell port map(wr_data(3), chip_en, rd_wr, rd_data(3));
    bit2: cache_cell port map(wr_data(2), chip_en, rd_wr, rd_data(2));
    bit1: cache_cell port map(wr_data(1), chip_en, rd_wr, rd_data(1));
    bit0: cache_cell port map(wr_data(0), chip_en, rd_wr, rd_data(0));

end structural;