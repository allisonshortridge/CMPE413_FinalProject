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
        hit         :   in std_logic;       -- from hit/miss logic
        way_clk     :   in std_logic;       -- from state machine; step to next way
        way_rst     :   in std_logic;       -- from state machine; back to way 0
        lru_upd     :   in std_logic;       -- from state machine; record the access
        valid_bit   :   out std_logic;
        tag         :   out std_logic_vector(1 downto 0);
        rd_data     :   out std_logic_vector(7 downto 0);
        way_q       :   out std_logic;      -- currently selected way
        victim      :   out std_logic;
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

component pdflip
    port (
        d   : in  std_logic;
        clk : in  std_logic;
        rst : in  std_logic;
        q   : out std_logic
    ); 
end component;

component positive_dlatch
    port (
        d    : in  std_logic;
        en   : in  std_logic;
        q    : out std_logic;
        qbar : out std_logic
    );
end component;

component inverter
    port (
        input  : in  std_logic;
        output : out std_logic
    );
end component;

component and2
    port (
        input1 : in  std_logic;
        input2 : in  std_logic;
        y      : out std_logic
    );
end component;

component or2
    port (
        input1 : in  std_logic;
        input2 : in  std_logic;
        y      : out std_logic
    ); 
end component;

component mux
    port (
        input1 : in  std_logic;
        input2 : in  std_logic;
        sel    : in  std_logic;
        y      : out std_logic
    );
end component;

for way0, way1: cache_way use entity work.cache_way(structural);
for way_ff: pdflip use entity work.pdflip(structural);
for lru_latch0, lru_latch1, lru_latch2, lru_latch3: positive_dlatch use entity work.positive_dlatch(structural);
for inv_way, inv_v1, inv_hit: inverter use entity work.inverter(structural);
for all

begin
    
    
    
end architecture structural;