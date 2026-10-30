--ca_reg / cd_reg / rw_q   input registers. follow inputs while IDLE
--address_decoder          set + byte decode, tag out. byte offset comes from byte_cnt
--mux8 (wr_mux)            write data: CD register for CPU write, MD for refill
--lru_unit                 both ways, LRU bits, victim select
--hit_miss x2              one tag/valid comparator per way
--mux8 (rd_mux)            read data from way that hit
--output_registers         captures selected byte at end of COMPARE/READ
--cd_out                   drives output register onto CD during OUT
--ma_out                   drives block-aligned address onto MA during READ MISS REQUEST

library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity cache_top is
    port (
        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        rw : in std_logic;  --RD/WR (1 = read, 0 = write)
        ca : in std_logic_vector(7 downto 0);   --CPU address
        cd : inout std_logic_vector(7 downto 0);    --CPU data
        md : in std_logic_vector(7 downto 0);   --memory data
        busy : out std_logic;
        enable : out std_logic; --ENABLE to memory
        ma : out std_logic_vector(7 downto 0)   -- memory address
    );
end cache_top;

architecture structural of cache_top is

    component cache_fsm
        port (
            clk : in std_logic;
            reset : in std_logic;
            start : in std_logic;
            rw : in std_logic;
            hit : in std_logic;
            busy : out std_logic;
            load_in : out std_logic;
            out_load : out std_logic;
            out_oe : out std_logic;
            enable : out std_logic;
            ma_oe : out std_logic;
            dec_en : out std_logic;
            refill : out std_logic;
            byte_cnt : out std_logic_vector(1 downto 0);
            data_wr : out std_logic;
            tv_wr : out std_logic
        );
        end component;

    component ca_reg
        port (
            ca : in std_logic_vector(7 downto 0);
            load : in std_logic;
            clk : in std_logic;
            q : out std_logic_vector(7 downto 0)
        );
        end component;

    component cd_reg
        port (
            ca : in std_logic_vector(7 downto 0);
            load : in std_logic;
            clk : in std_logic;
            q : out std_logic_vector(7 downto 0)
        );
        end component;

    component reg
        port (
            d : in std_logic;
            load : in std_logic;
            clk : in std_logic;
            q : out std_logic
        );
        end component;

    component address_decoder
        port (
            address : in std_logic_vector(5 downto 0);
            chip_en : in std_logic;
            refill : in std_logic;
            byte_cnt: in std_logic_vector(1 downto 0);
            rq_tag : out std_logic_vector(1 downto 0);
            block_en: out std_logic_vector(3 downto 0);
            byte_en : out std_logic_vector(15 downto 0)
        );
        end component;

    component lru_unit
        port (
            wr_data : in std_logic_vector(7 downto 0);
            rq_tag : in std_logic_vector(1 downto 0);
            block_en : in std_logic_vector(3 downto 0);
            byte_en : in std_logic_vector(15 downto 0);
            data_wr : in std_logic;
            tv_wr : in std_logic;
            refill : in std_logic;
            lookup : in std_logic;
            way_in : in std_logic;
            rd_done : in std_logic;
            clk : in std_logic;
            rst : in std_logic;
            valid0 : out std_logic;
            valid1 : out std_logic;
            tag0 : out std_logic_vector(1 downto 0);
            tag1 : out std_logic_vector(1 downto 0);
            rd_data0 : out std_logic_vector(7 downto 0);
            rd_data1 : out std_logic_vector(7 downto 0);
            victim : out std_logic
        );
        end component;

    component hit_miss
        port (
            tag_req : in std_logic_vector(1 downto 0);
            tag_stored : in std_logic_vector(1 downto 0);
            valid : in std_logic;
            hit : out std_logic
        );
        end component;

    component mux
        port (
            input1 : in std_logic;
            input2 : in std_logic;
            sel : in std_logic;
            y : out std_logic
        );
        end component;

    component mux8
        port (
            input1 : in std_logic_vector(7 downto 0);
            input2 : in std_logic_vector(7 downto 0);
            sel : in std_logic;
            y : out std_logic_vector(7 downto 0)
        );
        end component;

    component or2
        port (
            input1 : in std_logic;
            input2 : in std_logic;
            output : out std_logic
        );
        end component;

    component output_registers
        port (
            data_in : in std_logic_vector(7 downto 0);
            load : in std_logic;
            clk : in std_logic;
            data_out : out std_logic_vector(7 downto 0)
        );
        end component;

    component cd_out
        port (
            data_in : in std_logic_vector(7 downto 0);
            en : in std_logic;
            y : out std_logic_vector(7 downto 0)
        );
        end component;

    component ma_out
        port (
            addr_in : in std_logic_vector(7 downto 0);
            en : in std_logic;
            y : out std_logic_vector(7 downto 0)
        );
        end component;

    for fsm_1: cache_fsm use entity work.cache_fsm(structural);
    for ca_reg_1: ca_reg use entity work.ca_reg(structural);
    for cd_reg_1: cd_reg use entity work.cd_reg(structural);
    for rw_reg: reg use entity work.reg(structural);
    for addr_dec: address_decoder use entity work.address_decoder(structural);
    for lru_1: lru_unit use entity work.lru_unit(structural);
    for hit_0, hit_1: hit_miss use entity work.hit_miss(structural);
    for way_mux: mux use entity work.mux(structural);
    for wr_mux, rd_mux: mux8 use entity work.mux8(structural);
    for hit_or, chip_or: or2 use entity work.or2(structural);
    for out_reg: output_registers use entity work.output_registers(structural);
    for cd_drv: cd_out use entity work.cd_out(structural);
    for ma_drv: ma_out use entity work.ma_out(structural);

    --CPU request. held while cache is busy
    signal ca_q, cd_q : std_logic_vector(7 downto 0);
    signal rw_q : std_logic;

    --fsm signals
    signal load_in, out_load, out_oe, ma_oe : std_logic;
    signal dec_en, chip_en, refill : std_logic;
    signal data_wr, tv_wr : std_logic;
    signal byte_cnt : std_logic_vector(1 downto 0);

    --address decoder
    signal rq_tag : std_logic_vector(1 downto 0);
    signal block_en : std_logic_vector(3 downto 0);
    signal byte_en : std_logic_vector(15 downto 0);

    --ways
    signal valid0, valid1 : std_logic;
    signal tag0, tag1 : std_logic_vector(1 downto 0);
    signal rd_data0, rd_data1 : std_logic_vector(7 downto 0);
    signal victim : std_logic;
    signal hit0, hit1, hit_i, way_in : std_logic;

    --data paths
    signal wr_data, rd_sel, out_q : std_logic_vector(7 downto 0);
    signal ma_addr : std_logic_vector(7 downto 0);

begin

    --control signals
    fsm_1: cache_fsm port map (
        clk => clk,
        reset => reset,
        start => start,
        rw => rw_q,
        hit => hit_i,
        busy => busy,
        load_in => load_in,
        out_load => out_load,
        out_oe => out_oe,
        enable => enable,
        ma_oe => ma_oe,
        dec_en => dec_en,
        refill => refill,
        byte_cnt => byte_cnt,
        data_wr => data_wr,
        tv_wr => tv_wr
    );

    --input registers
    ca_reg_1: ca_reg port map (ca, load_in, clk, ca_q);
    cd_reg_1: cd_reg port map (cd, load_in, clk, cd_q);
    rw_reg: reg port map (rw, load_in, clk, rw_q);

    --address decoding
    --chip_en is dec_en plus the OUT state, so the set stays selected for the LRU update during OUT
    chip_or: or2 port map (dec_en, out_oe, chip_en);
    addr_dec: address_decoder port map (ca_q(5 downto 0), chip_en, refill, byte_cnt, rq_tag, block_en, byte_en);

    --write data: CPU data for a write, memory data for a refill
    wr_mux: mux8 port map (cd_q, md, refill, wr_data);

    --the two ways, LRU bits and victim select
    lru_1: lru_unit port map (
        wr_data => wr_data,
        rq_tag => rq_tag,
        block_en => block_en,
        byte_en => byte_en,
        data_wr => data_wr,
        tv_wr => tv_wr,
        refill => refill,
        lookup => out_load,
        way_in => way_in,
        rd_done => out_oe,
        clk => clk,
        rst => reset,
        valid0 => valid0,
        valid1 => valid1,
        tag0 => tag0,
        tag1 => tag1,
        rd_data0 => rd_data0,
        rd_data1 => rd_data1,
        victim => victim
    );

    --hit detect. checks per way
    hit_0: hit_miss port map (rq_tag, tag0, valid0, hit0);
    hit_1: hit_miss port map (rq_tag, tag1, valid1, hit1);
    hit_or: or2 port map (hit0, hit1, hit_i);

    --way to use: the hit way on a hit, the victim way on a miss
    way_mux: mux port map (victim, hit1, hit_i, way_in);

    --read data from the way that hit
    rd_mux: mux8 port map (rd_data0, rd_data1, hit1, rd_sel);
    out_reg: output_registers port map (rd_sel, out_load, clk, out_q);
    cd_drv: cd_out port map (out_q, out_oe, cd);

    --memory address
    ma_addr <= ca_q(7 downto 2) & "00";
    ma_drv: ma_out port map (ma_addr, ma_oe, ma);

end structural;