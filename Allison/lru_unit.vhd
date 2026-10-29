-- four LRU bits (one per index)
-- update logic on hits and refills
-- victim-select logic (invalid way first, otherwise LRU way)

library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity lru_unit is
    port (
        wr_data     :   in std_logic_vector(7 downto 0);
        rq_tag      :   in std_logic_vector(1 downto 0);
        block_en    :   in std_logic_vector(3 downto 0);
        byte_en     :   in std_logic_vector(15 downto 0);
        rd_wr       :   in std_logic;
        vt_en       :   in std_logic;
        wr_valid    :   in std_logic;
        valid_bit   :   out std_logic;
        tag         :   out std_logic_vector(1 downto 0);
        rd_data     :   out std_logic_vector(7 downto 0)
    );
end lru_unit;

architecture structural of lru_unit is
    

component cache_way
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
end component;




begin
    
    
    
end architecture structural;