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
        data_wr     :   in std_logic;    -- FSM data_wr, before retiming
        tv_wr       :   in std_logic;    -- FSM tv_wr, before retiming
        refill      :   in std_logic;    -- FSM refill
        lookup      :   in std_logic;    -- FSM out_load: both ways on, way register loads
        way_in      :   in std_logic;    -- hit logic: hit way, or victim on a miss
        rd_done     :   in std_logic;    -- FSM out_oe: a read has finished
        clk         :   in std_logic;
        rst         :   in std_logic;
        valid0      :   out std_logic;
        valid1      :   out std_logic;
        tag0        :   out std_logic_vector(1 downto 0);
        tag1        :   out std_logic_vector(1 downto 0);
        rd_data0    :   out std_logic_vector(7 downto 0);
        rd_data1    :   out std_logic_vector(7 downto 0);
        victim      :   out std_logic
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

component ndflip
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


component nor2
    port (
        input1  : in  std_logic;
        input2  : in  std_logic;
        output  : out std_logic
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
for data_ff, tv_ff, rstp_ff: pdflip use entity work.pdflip(structural);
for way_ff, rstn_ff: ndflip use entity work.ndflip(structural);
for lru_latch0, lru_latch1, lru_latch2, lru_latch3: positive_dlatch use entity work.positive_dlatch(structural);
for inv_way, inv_v1, inv_clk, inv_ref, inv_wr: inverter use entity work.inverter(structural);
for all: and2 use entity work.and2(structural);
for all: or2 use entity work.or2(structural);
for all: nor2 use entity work.nor2(structural);
for all: mux use entity work.mux(structural);

signal data_q, tv_q, rd_wr, vt_en, wr_valid  : std_logic;
signal rst_p, rst_n                          : std_logic;
signal way_i, nway, way_d, nvalid1, v0, v1   : std_logic;
signal nclk, nrefill, upd_rd, upd_wr, lru_upd: std_logic;
signal way_en                                : std_logic_vector(1 downto 0);
signal bw0, bw1, blk0, blk1                  : std_logic_vector(3 downto 0);
signal ben0, ben1                            : std_logic_vector(15 downto 0);
signal lru_wr_en, lru, lru_pick              : std_logic_vector(3 downto 0);
signal pick01, pick23, lru_sel, t_vic        : std_logic;

begin

    -- write strobes retimed to the rising edge: low = write, one clock wide
    data_ff: pdflip port map(data_wr, clk, rst, data_q);
    tv_ff:   pdflip port map(tv_wr, clk, rst, tv_q);
    inv_wr:  inverter port map(data_q, rd_wr);

    -- reset invalidation: rst_p is reset sampled on the rising edge, rst_n lags it by half a clock.
    -- wr_valid stays 0 until half a clock after the valid latches close.
    rstp_ff: pdflip port map(rst, clk, '0', rst_p);
    rstn_ff: ndflip port map(rst_p, clk, '0', rst_n);
    vt_nor:  nor2 port map(tv_q, rst_p, vt_en);
    wv_nor:  nor2 port map(rst_p, rst_n, wr_valid);

    -- way register: loads way_in while lookup is high, otherwise holds
    way_mux: mux port map(way_i, way_in, lookup, way_d);
    way_ff:  ndflip port map(way_d, clk, rst, way_i);
    inv_way: inverter port map(way_i, nway);

    -- lookup enables both ways, otherwise only the held way
    we0_or: or2 port map(lookup, nway, way_en(0));
    we1_or: or2 port map(lookup, way_i, way_en(1));

    -- valid/tag block enables per way; rst_p forces every block on in both ways
    blk_gate: for i in 0 to 3 generate
        g0: and2 port map(block_en(i), way_en(0), bw0(i));
        g1: and2 port map(block_en(i), way_en(1), bw1(i));
        r0: or2  port map(bw0(i), rst_p, blk0(i));
        r1: or2  port map(bw1(i), rst_p, blk1(i));
    end generate;

    -- data byte enables per way, so a write only reaches the held way
    byte_gate: for j in 0 to 15 generate
        b0: and2 port map(byte_en(j), way_en(0), ben0(j));
        b1: and2 port map(byte_en(j), way_en(1), ben1(j));
    end generate;

    way0: cache_way port map(wr_data, blk0, ben0, rd_wr, vt_en, wr_valid, rq_tag, v0, tag0, rd_data0);
    way1: cache_way port map(wr_data, blk1, ben1, rd_wr, vt_en, wr_valid, rq_tag, v1, tag1, rd_data1);
    valid0 <= v0;
    valid1 <= v1;

    -- LRU update pulse
    --   read (hit or miss): first (low) half of the out state
    --   write hit: the retimed data strobe, but not during a refill
    inv_clk: inverter port map(clk, nclk);
    inv_ref: inverter port map(refill, nrefill);
    rdp_and: and2 port map(rd_done, nclk, upd_rd);
    wrp_and: and2 port map(data_q, nrefill, upd_wr);
    upd_or:  or2  port map(upd_rd, upd_wr, lru_upd);

    -- four LRU bits, one per set: lru(i) = 1 means way 1 is least recently used
    en_and0: and2 port map(block_en(0), lru_upd, lru_wr_en(0));
    en_and1: and2 port map(block_en(1), lru_upd, lru_wr_en(1));
    en_and2: and2 port map(block_en(2), lru_upd, lru_wr_en(2));
    en_and3: and2 port map(block_en(3), lru_upd, lru_wr_en(3));

    -- the way just used is no longer the LRU, so store not way_i
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
    sel_or:   or2 port map(pick01, pick23, lru_sel);

    -- victim = v0 and (not v1 or lru): way 0 if invalid, else way 1 if invalid, else LRU
    inv_v1:  inverter port map(v1, nvalid1);
    vic_or:  or2 port map(nvalid1, lru_sel, t_vic);
    vic_and: and2 port map(v0, t_vic, victim);
    
end architecture structural;