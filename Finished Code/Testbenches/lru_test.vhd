library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity tb_lru_unit is
end tb_lru_unit;

architecture behavior of tb_lru_unit is

component lru_unit
    port (
        wr_data     :   in std_logic_vector(7 downto 0);
        rq_tag      :   in std_logic_vector(1 downto 0);
        block_en    :   in std_logic_vector(3 downto 0);
        byte_en     :   in std_logic_vector(15 downto 0);
        data_wr     :   in std_logic;
        tv_wr       :   in std_logic;
        refill      :   in std_logic;
        lookup      :   in std_logic;
        way_in      :   in std_logic;
        rd_done     :   in std_logic;
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
end component;

for dut: lru_unit use entity work.lru_unit(structural);

constant PERIOD : time := 20 ns;
constant TCQ    : time := 1 ns;      -- FSM clock-to-output delay

signal clk      : std_logic := '0';
signal rst      : std_logic := '1';
signal done     : boolean   := false;

signal wr_data  : std_logic_vector(7 downto 0)  := "00000000";
signal rq_tag   : std_logic_vector(1 downto 0)  := "00";
signal block_en : std_logic_vector(3 downto 0)  := "0000";
signal byte_en  : std_logic_vector(15 downto 0) := "0000000000000000";
signal data_wr, tv_wr, refill, lookup, rd_done : std_logic := '0';

signal valid0, valid1, victim : std_logic;
signal tag0, tag1             : std_logic_vector(1 downto 0);
signal rd_data0, rd_data1     : std_logic_vector(7 downto 0);
signal hit0, hit1, way_in     : std_logic;

-- one-hot enables, as the address decoder would produce them
function blk_onehot(b : integer) return std_logic_vector is
    variable v : std_logic_vector(3 downto 0);
begin
    v := "0000";
    v(b) := '1';
    return v;
end blk_onehot;

function byte_onehot(b, o : integer) return std_logic_vector is
    variable v : std_logic_vector(15 downto 0);
begin
    v := "0000000000000000";
    v(4*b + o) := '1';
    return v;
end byte_onehot;

function b2(i : integer) return std_logic_vector is
begin
    case i is
        when 0 => return "00";
        when 1 => return "01";
        when 2 => return "10";
        when others => return "11";
    end case;
end b2;

-- unique data byte for every (tag, block, byte)
function pat(tg : std_logic_vector; b, k : integer) return std_logic_vector is
    variable v : std_logic_vector(7 downto 0);
begin
    v := tg & b2(b) & b2(k) & "01";
    return v;
end pat;

-- integer to string, since 'image is not in VHDL-87
function digit(d : integer) return string is
begin
    case d is
        when 0 => return "0";
        when 1 => return "1";
        when 2 => return "2";
        when 3 => return "3";
        when 4 => return "4";
        when 5 => return "5";
        when 6 => return "6";
        when 7 => return "7";
        when 8 => return "8";
        when others => return "9";
    end case;
end digit;

function itoa(n : integer) return string is
begin
    if n < 10 then
        return digit(n);
    else
        return itoa(n / 10) & digit(n mod 10);
    end if;
end itoa;

begin

    dut: lru_unit port map(wr_data, rq_tag, block_en, byte_en, data_wr, tv_wr, refill, lookup, way_in, rd_done, clk, rst,
                           valid0, valid1, tag0, tag1, rd_data0, rd_data1, victim);

    -- stands in for hit_logic: hit = valid and tag match; way_in = hit way, or victim on a miss
    hit0 <= '1' when (valid0 = '1' and tag0 = rq_tag) else '0';
    hit1 <= '1' when (valid1 = '1' and tag1 = rq_tag) else '0';
    way_in <= '1' when hit1 = '1' else
              '0' when hit0 = '1' else
              victim;

    clk_gen: process
    begin
        while not done loop
            clk <= '0'; wait for PERIOD/2;
            clk <= '1'; wait for PERIOD/2;
        end loop;
        wait;
    end process;

    stim: process
        variable passes, fails : integer := 0;
        variable r_h0, r_h1, r_v0, r_v1, r_vic : std_logic := 'U';
        variable r_t0, r_t1 : std_logic_vector(1 downto 0);
        variable r_d0, r_d1 : std_logic_vector(7 downto 0);

        procedure check (cond : boolean; msg : string) is
        begin
            if cond then
                passes := passes + 1;
            else
                fails := fails + 1;
                assert false report "FAIL: " & msg severity error;
            end if;
        end check;

        procedure nedge is
        begin
            wait until clk'event and clk = '0';
        end nedge;

        -- capture everything the FSM could see at a falling edge
        procedure sample is
        begin
            r_h0 := hit0;      r_h1 := hit1;
            r_v0 := valid0;    r_v1 := valid1;
            r_vic := victim;
            r_t0 := tag0;      r_t1 := tag1;
            r_d0 := rd_data0;  r_d1 := rd_data1;
        end sample;

        procedure idle_ctrl is
        begin
            block_en <= "0000";
            byte_en  <= "0000000000000000";
            lookup <= '0'; data_wr <= '0'; tv_wr <= '0'; refill <= '0'; rd_done <= '0';
        end idle_ctrl;

        -- n falling edges, then clock-to-output delay
        procedure cycles (n : integer) is
        begin
            for i in 1 to n loop
                nedge;
            end loop;
            wait for TCQ;
        end cycles;

        procedure do_reset is
        begin
            idle_ctrl;
            rst <= '1'; cycles(3);
            rst <= '0'; cycles(3);
        end do_reset;

        -- compare state (N1 to N2): both ways on, sample at N2
        procedure compare (blk, byt : integer; tg : std_logic_vector) is
        begin
            rq_tag   <= tg;
            block_en <= blk_onehot(blk);
            byte_en  <= byte_onehot(blk, byt);
            lookup   <= '1';
            nedge;
            sample;
            wait for TCQ;
        end compare;

        -- compare only, no LRU or data effect
        procedure probe (blk, byt : integer; tg : std_logic_vector) is
        begin
            compare(blk, byt, tg);
            idle_ctrl;
            cycles(1);
        end probe;

        -- read hit: out state, rd_done high for one clock
        procedure read_hit_finish is
        begin
            lookup <= '0'; rd_done <= '1';
            cycles(1);
            idle_ctrl;
            cycles(1);
        end read_hit_finish;

        -- write hit: write state, data strobe high for one clock
        procedure write_hit_finish (d : std_logic_vector) is
        begin
            lookup <= '0'; wr_data <= d; data_wr <= '1';
            cycles(1);
            idle_ctrl;
            cycles(1);
        end write_hit_finish;

        -- write miss: write state with no strobe
        procedure write_miss_finish is
        begin
            lookup <= '0';
            cycles(1);
            idle_ctrl;
            cycles(1);
        end write_miss_finish;

        -- read miss: request, 7 wait clocks, four bytes two clocks apart, read back, out
        procedure read_miss_fill (blk, byt : integer; tg : std_logic_vector) is
        begin
            lookup <= '0';
            block_en <= "0000"; byte_en <= "0000000000000000";    -- decoder off in the request state
            cycles(1);                                            -- N3
            refill <= '1';
            block_en <= blk_onehot(blk); byte_en <= byte_onehot(blk, 3);
            cycles(7);                                            -- N10
            for k in 0 to 3 loop
                byte_en <= byte_onehot(blk, k);
                wr_data <= pat(tg, blk, k);
                data_wr <= '1';
                if k = 0 then
                    tv_wr <= '1';                                 -- tag/valid written once
                else
                    tv_wr <= '0';
                end if;
                cycles(1);                                        -- write bit state
                data_wr <= '0'; tv_wr <= '0';
                cycles(1);                                        -- wait state
            end loop;                                             -- N18
            refill <= '0'; lookup <= '1'; byte_en <= byte_onehot(blk, byt);
            nedge;                                                -- N19
            sample;
            wait for TCQ;
            lookup <= '0'; rd_done <= '1';
            cycles(1);
            idle_ctrl;
            cycles(1);
        end read_miss_fill;

    begin

        -- T0: reset invalidates every entry
        do_reset;
        for b in 0 to 3 loop
            probe(b, 0, "00");
            check(r_v0 = '0' and r_v1 = '0', "T0: valid bits cleared in set " & itoa(b));
            check(r_vic = '0', "T0: victim is way 0 in set " & itoa(b));
        end loop;

        -- T1: cold read miss fills way 0
        compare(2, 1, "01");
        check(r_h0 = '0' and r_h1 = '0', "T1: cold miss");
        check(r_vic = '0', "T1: victim is way 0");
        read_miss_fill(2, 1, "01");
        check(r_h0 = '1' and r_h1 = '0', "T1: refilled way 0 hits");
        check(r_d0 = pat("01", 2, 1), "T1: requested byte read back");
        for k in 0 to 3 loop
            probe(2, k, "01");
            check(r_d0 = pat("01", 2, k), "T1: way 0 byte " & itoa(k));
            check(r_d1 /= pat("01", 2, k), "T1: way 1 byte " & itoa(k) & " not written");
        end loop;
        check(r_t0 = "01" and r_v0 = '1', "T1: way 0 tag and valid stored");
        check(r_v1 = '0', "T1: way 1 still invalid");
        check(r_vic = '1', "T1: victim is way 1 (invalid way first)");

        -- T2: second miss fills way 1, way 0 untouched
        compare(2, 3, "10");
        check(r_h0 = '0' and r_h1 = '0', "T2: miss on tag 10");
        check(r_vic = '1', "T2: victim is way 1");
        read_miss_fill(2, 3, "10");
        check(r_h1 = '1' and r_h0 = '0', "T2: refilled way 1 hits");
        check(r_d1 = pat("10", 2, 3), "T2: requested byte read back");
        probe(2, 1, "01");
        check(r_t0 = "01" and r_t1 = "10", "T2: tags kept per way");
        check(r_d0 = pat("01", 2, 1), "T2: way 0 data untouched by way 1 fill");
        check(r_d1 = pat("10", 2, 1), "T2: way 1 byte 1 stored");
        check(r_vic = '0', "T2: way 0 is LRU after filling way 1");

        -- T3: read hit in way 0 makes way 1 the LRU
        compare(2, 1, "01");
        check(r_h0 = '1' and r_h1 = '0', "T3: hit in way 0");
        check(r_d0 = pat("01", 2, 1), "T3: read hit data");
        read_hit_finish;
        probe(2, 0, "10");
        check(r_vic = '1', "T3: way 1 is LRU after a hit in way 0");

        -- T4: miss with both ways valid replaces the LRU way (way 1)
        compare(2, 0, "11");
        check(r_h0 = '0' and r_h1 = '0', "T4: miss on tag 11");
        check(r_vic = '1', "T4: LRU victim is way 1");
        read_miss_fill(2, 0, "11");
        check(r_h1 = '1' and r_d1 = pat("11", 2, 0), "T4: way 1 refilled");
        probe(2, 0, "00");
        check(r_t0 = "01" and r_t1 = "11", "T4: way 0 kept its tag, way 1 replaced");
        check(r_vic = '0', "T4: way 0 is LRU after refilling way 1");

        -- T5: back-to-back misses alternate between the ways
        compare(2, 2, "00");
        check(r_h0 = '0' and r_h1 = '0', "T5: miss on tag 00");
        check(r_vic = '0', "T5: victim is way 0");
        read_miss_fill(2, 2, "00");
        check(r_h0 = '1' and r_d0 = pat("00", 2, 2), "T5: way 0 refilled");
        compare(2, 2, "01");
        check(r_h0 = '0' and r_h1 = '0', "T5: tag 01 no longer in the cache");
        check(r_vic = '1', "T5: victim is way 1");
        read_miss_fill(2, 2, "01");
        check(r_h1 = '1' and r_d1 = pat("01", 2, 2), "T5: way 1 refilled");
        probe(2, 0, "10");
        check(r_t0 = "00" and r_t1 = "01", "T5: ways alternated");
        check(r_vic = '0', "T5: way 0 is LRU");

        -- T5b: hits in way 1
        compare(2, 2, "01");
        check(r_h1 = '1' and r_h0 = '0', "T5b: hit in way 1");
        read_hit_finish;
        probe(2, 0, "10");
        check(r_vic = '0', "T5b: way 0 is LRU after a hit in way 1");
        compare(2, 3, "01");
        check(r_h1 = '1', "T5b: write hit in way 1");
        write_hit_finish("10100101");
        probe(2, 3, "01");
        check(r_d1 = "10100101", "T5b: write hit updated way 1");
        check(r_d0 = pat("00", 2, 3), "T5b: way 0 same byte untouched");

        -- T6: write hit changes only the hit way's byte and updates LRU
        compare(2, 2, "00");
        check(r_h0 = '1' and r_h1 = '0', "T6: hit in way 0");
        write_hit_finish("01011010");
        probe(2, 2, "00");
        check(r_d0 = "01011010", "T6: write hit updated way 0");
        check(r_d1 = pat("01", 2, 2), "T6: way 1 same byte untouched");
        check(r_vic = '1', "T6: write hit made way 1 the LRU");
        probe(2, 3, "00");
        check(r_d0 = pat("00", 2, 3), "T6: neighbouring byte untouched");

        -- T7: write miss changes nothing
        compare(2, 0, "11");
        check(r_h0 = '0' and r_h1 = '0', "T7: write miss");
        write_miss_finish;
        probe(2, 0, "11");
        check(r_d0 = pat("00", 2, 0) and r_d1 = pat("01", 2, 0), "T7: write miss left the cache alone");
        check(r_vic = '1', "T7: write miss left LRU alone");

        -- T8: sets are independent
        compare(0, 0, "11");
        check(r_h0 = '0' and r_h1 = '0', "T8: miss in set 0");
        check(r_vic = '0', "T8: set 0 victim is way 0");
        read_miss_fill(0, 0, "11");
        check(r_h0 = '1', "T8: set 0 way 0 refilled");
        probe(2, 0, "00");
        check(r_t0 = "00" and r_t1 = "01", "T8: set 2 tags untouched");
        check(r_vic = '1', "T8: set 2 LRU unchanged");
        probe(0, 0, "11");
        check(r_v1 = '0', "T8: set 0 way 1 still invalid");

        -- T9: reset again, stale tags must not hit, first fill goes to way 0
        do_reset;
        for b in 0 to 3 loop
            probe(b, 0, "00");
            check(r_v0 = '0' and r_v1 = '0', "T9: valid bits cleared in set " & itoa(b));
            check(r_h0 = '0' and r_h1 = '0', "T9: stale tag does not hit in set " & itoa(b));
        end loop;
        compare(2, 1, "01");
        check(r_vic = '0', "T9: victim is way 0 after reset");
        read_miss_fill(2, 1, "01");
        check(r_h0 = '1' and r_d0 = pat("01", 2, 1), "T9: refill after reset goes to way 0");

        assert false
            report "testbench finished: " & itoa(passes) & " checks passed, " & itoa(fails) & " failed"
            severity note;
        done <= true;
        wait;
    end process;

end behavior;