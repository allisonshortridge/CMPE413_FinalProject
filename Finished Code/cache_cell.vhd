-- cache cell architecture and small selector
    -- positive-level-sensitive latch -> transmission gate
    -- write-data, write-enable and read-enable ports

    -- decoder selector
        -- chip enable and RD/WR -> read-enable and write-enable


library STD;
library IEEE;
use IEEE.std_logic_1164.all;


-- 1-bit cache cell
entity cache_cell is
    port (
        wr_data   : in  std_logic;
        chip_en : in  std_logic;
        rd_wr : in std_logic;
        rd_data   : out std_logic
    );
end cache_cell;

architecture structural of cache_cell is

-- positive level sensitive latch
component pos_dlatch
    port (
        d   : in  std_logic;
        en : in  std_logic;
        q   : out std_logic;
        qbar: out std_logic
    );
end component


component inverter
    port (
        input    : in  std_logic;
        output   : out std_logic
    );
end component;

-- transmission gate
component tx
    port ( 
        sel   : in std_logic;
        selnot: in std_logic;
        input : in std_logic;
        output : out std_logic
    );
end component


-- 1-to-2 decoder
component decoder1to2
    port (
        A0    : in std_logic;
        E     : in std_logic;
        Y1    : out std_logic;
        Y0    : out std_logic
    );
end component

for pos_dlatch_1: pos_dlatch use entity work.pos_dlatch(structural);
for inverter_1: inverter use entity work.inverter(structural);
for tx_1: tx use entity work.tx(structural);
for decoder1to2_1: decoder1to2 use entity work.decoder1to2(structural);

signal wr_en, rd_en, not_rd_en, dlatch_out: std_logic;

begin

    decoder1to2_1: decoder1to2 port map(rd_wr, chip_en, rd_en, wr_en);

    pos_dlatch_1: pos_dlatch port map(wr_data, wr_en, dlatch_out, dlatch_out);

    inverter_1: inverter port map(rd_en, not_rd_en);

    tx_1: tx port map(rd_en, not_rd_en, dlatch_out, rd_data);

end structural
