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
for all: and2 use entity work.and2(structural);
for all: or2 use entity work.or2(structural);
for all: mux use entity work.mux(structural);

signal way_i, nway, nhit, nvalid1, rd_mode: std_logic;
signal vic, hit_or_vic, next_way: std_logic;
signal way_en: std_logic_vector(1 downto 0);
signal blk0, blk1 : std_logic_vector(3 downto 0);
signal v0, v1 :std_logic;
signal t0, t1 :std_logic_vector(1 downto 0);
signal d0, d1: std_logic_vector(7 downto 0);
signal lru_wr_en, lru, lru_pick: std_logic_vector(3 downto 0);
signal pick01, pick23, lru_sel, t_vic: std_logic;

begin
    
    -- register for way: reset = way 0, each way_clk pulse loads next way
    way_ff: pdflip port map(next_way, way_clk, way_rst, way_i);
    way_q<=way_i;

    -- next way: way_i = 0 -> try way 1 on a miss (not hit)
    --           way_i = 1 -> stay on hit, otherwise go to victim
    inv_hit: inverter port map(hit, nhit);
    hv_or: or2 port map(hit, vic, hit_or_vic);
    next_mux: mux port map(nhit, hit_or_vic, way_i, next_way);

    inv_way: inverter port map(way_i, nway);

    -- read mode (rd_wr = 1 and vt_en = 1): both ways enabled
    -- any write: only the selected way is enabled
    rd_and: and2 port map(rd_wr, vt_en, rd_mode);
    way_en0_or: or2 port map(rd_mode, nway, way_en(0));
    way_en1_or: or2 port map(rd_mode, way_i, way_en(1));

    blk_gate: for i in 0 to 3 generate
        g0: and2 port map(block_en(i), way_en(0), blk0(i));
        g1: and2 port map(block_en(i), way_en(1), blk1(i));
    end generate;

    way0: cache_way port map(wr_data, blk0, byte_en, rd_wr, vt_en, wr_valid, rq_tag, v0, t0, d0);
    way1: cache_way port map(wr_data, blk1, byte_en, rd_wr, vt_en, wr_valid, rq_tag, v1, t1, d1);

    -- outputs come from selected way
    valid_mux: mux port map(v0, v1, way_i, valid_bit);

    tag_mux: for i in 0 to 1 generate
        m: mux port map(t0(i), t1(i), way_i, tag(i));
    end generate;

    data_mux: for i in 0 to 7 generate
        m: mux port map(d0(i), d1(i), way_i, rd_data(i));
    end generate;

    -- four LRU bits, one per set: lru(i) = 1 means way 1 is least recently used
    en_and0: and2 port map(block_en(0), lru_upd, lru_wr_en(0));
    en_and1: and2 port map(block_en(1), lru_upd, lru_wr_en(1));
    en_and2: and2 port map(block_en(2), lru_upd, lru_wr_en(2));
    en_and3: and2 port map(block_en(3), lru_upd, lru_wr_en(3));
    
    -- the way just used is no longer the LRU
    lru_latch0: positive_dlatch port map(nway, lru_wr_en(0), lru(0), open);
    lru_latch1: positive_dlatch port map(nway, lru_wr_en(1), lru(1), open);
    lru_latch2: positive_dlatch port map(nway, lru_wr_en(2), lru(2), open);
    lru_latch3: positive_dlatch port map(nway, lru_wr_en(3), lru(3), open);

    -- LRU bit of the indexed set
    sel_and0: and2 port map(block_en(0), lru(0), lru_pick(0));
    sel_and1: and2 port map(block_en(1), lru(1), lru_pick(1));
    sel_and2: and2 port map(block_en(2), lru(2), lru_pick(2));
    sel_and3: and2 port map(block_en(3), lru(3), lru_pick(3));
    sel_or01: or2 port map(lru_pick(0), lru_pick(1), pick01);
    sel_or23: or2 port map(lru_pick(2), lru_pick(3), pick23);
    sel_or: or2 port map(pick01, pick23, lru_sel);

    -- victim = v0 and (not v1 or lru): way 0 if invalid, else way 1 if invalid, else LRU
    inv_v1: inverter port map(v1, nvalid1);
    vic_or: or2 port map(nvalid1, lru_sel, t_vic);
    vic_and: and2 port map(v0, t_vic, vic);
    victim<=vic;

    
end architecture structural;