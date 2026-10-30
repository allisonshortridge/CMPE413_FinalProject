library STD;
library IEEE;
use IEEE.std_logic_1164.all;

--state flops clocked on falling edge of clk.
--memory timed by counter.vhd, which counts RISING edges of clk.
--
--states:
--idle                stored inverted: reset (all flops -> 0) means IDLE
--compare             tag/valid compare (hit) is evaluated here
--read                read the requested byte after a refill
--write               cache write (hit only) for a CPU write
--read miss request   ENABLE and MA output enabled for one clock
--write bit           write one refill byte (data, plus tag/valid on byte 0)
--wait for next bit   wait for memory (7 clocks first, 1 clock between bytes)
--out                 BUSY low, CD output enabled for one clock
--
--read hit: idle->comp, comp->out (2 clocks)
--write hit/miss: idle->comp, comp->write, write->idle (3 clocks)
--read miss: idle->comp, comp->req, req->wait, byte k written at N(10+2k), N18 ->read, N19 ->out    (19 clocks)
--
--counter.vhd functionality:
--counter is held in reset (cnt_rst = 1) in every state except s_wait and s_wbit
--cleared by rising edge inside s_req, starts counting at N3
--memory data ready at counter = 7, 9, 11, 13, 15
--15 goes to s_read.
--
--RESET is synchronous 
--hold reset high through one falling edge and one rising edge of clk

entity cache_fsm is
    port (
        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        rw : in std_logic;                       
        hit : in std_logic;                       --hit/miss (1 = hit, 0 = miss)
        busy : out std_logic;
        load_in : out std_logic;                      --input registers follow their inputs
        out_load : out std_logic;                      --output register captures the selected byte
        out_oe : out std_logic;                      --drive the byte onto CD
        enable : out std_logic;                      --ENABLE pin to memory
        ma_oe : out std_logic;                      --drive MA
        dec_en : out std_logic;                      --address_decoder chip_en
        refill : out std_logic;                      --1: byte offset from byte_cnt, write data from MD
        byte_cnt : out std_logic_vector(1 downto 0);   --byte being refilled
        data_wr : out std_logic;                      --data cell write, BEFORE rising-edge retiming
        tv_wr : out std_logic                       --tag + valid write, BEFORE rising-edge retiming
    );
end cache_fsm;

architecture structural of cache_fsm is
    component inverter
        port (
        input : in std_logic;
        output : out std_logic
        );
        end component;

    component and2
        port (
        input1 : in std_logic;
        input2 : in std_logic;
        output : out std_logic
        );
        end component;

    component or2
        port (
        input1 : in std_logic;
        input2 : in std_logic;
        output : out std_logic
        );
        end component;

    component nor2
        port (
        input1 : in std_logic;
        input2 : in std_logic;
        output : out std_logic
        );
        end component;

    component xnor2
        port (
        input1 : in std_logic;
        input2 : in std_logic;
        output : out std_logic
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

    component ndflip
        port (
        d : in std_logic;
        clk : in std_logic;
        rst : in std_logic;
        q : out std_logic
        );
        end component;

    component counter
        port (
        clk : in std_logic;
        rst : in std_logic;
        q : out std_logic_vector(3 downto 0)
        );
        end component;

    --declaration of individual gates
    for inv_1, inv_2, inv_3, inv_4, inv_5, inv_6, inv_7, inv_8, inv_9, inv_10: inverter use entity work.inverter(structural);
    for and_1, and_2, and_3, and_4, and_5, and_6, and_7, and_8, and_9, and_10, and_11, and_12,
        and_13, and_14, and_15, and_16, and_17: and2 use entity work.and2(structural);
    for or_1, or_2, or_3, or_4, or_5, or_6, or_7, or_8, or_9, or_10, or_11, or_12, or_13, or_14: or2 use entity work.or2(structural);
    for nor_1, nor_2: nor2 use entity work.nor2(structural);
    for xnor_1, xnor_2: xnor2 use entity work.xnor2(structural);
    for mux_1: mux use entity work.mux(structural);

    --flip flop states
    for ff_idle, ff_comp, ff_read, ff_write, ff_req, ff_wbit, ff_wait, ff_out,
        ff_b0, ff_b1, ff_hit_q: ndflip use entity work.ndflip(structural);
    for counter_1: counter use entity work.counter(structural);
    signal s_nidle, s_idle, s_comp, s_write, s_req, s_wbit, s_wait, s_read, s_out: std_logic;
    signal nstart, nrw, nhit: std_logic; --inverted inputs
    signal idle_hold, idle_a, idle_next, d_nidle: std_logic; --logic for idle state
    signal d_comp: std_logic;
    signal comp_rd, rd_hit, d_out, d_req, d_write: std_logic;
    signal wait_done, wait_hold, enter_wait, d_wait, go_wbit, go_read: std_logic; --logic for next state
    signal counting, cnt_rst: std_logic;
    signal q2q1, q3q0, q_ge7, ge7odd, all15, nge7odd, nall15: std_logic;
    signal b0, b1: std_logic; --byte count bits
    signal x_b0, t_b0, d_b0, carry_b, x_b1, t_b1, d_b1: std_logic;
    signal hit_q, d_hq: std_logic;
    signal out_load_i, refill_i, dec_a, wr_hit, b_zero: std_logic; --output logic
    signal cnt: std_logic_vector(3 downto 0);

begin

    --inverted inputs. s_idle comes from s_nidle (reset gives IDLE)
    inv_1: inverter port map(s_nidle, s_idle);
    inv_2: inverter port map(start, nstart);
    inv_3: inverter port map(rw, nrw);
    inv_4: inverter port map(hit, nhit);

    --IDLE: start = 0, path from WRITE and OUT
    and_1: and2 port map(s_idle, nstart, idle_hold);
    or_1: or2 port map(idle_hold, s_write, idle_a);
    or_2: or2 port map(idle_a, s_out, idle_next);
    inv_5: inverter port map(idle_next, d_nidle);

    --COMPARE: from IDLE when start = 1
    and_2: and2 port map(s_idle, start, d_comp);

    --OUT: after READ if read hit
    and_3: and2 port map(s_comp, rw, comp_rd);
    and_4: and2 port map(comp_rd, hit, rd_hit);
    or_3: or2 port map(rd_hit, s_read, d_out);

    -- READ MISS REQUEST: read and not hit
    and_5: and2 port map(comp_rd, nhit, d_req);

    --WRITE: hit or miss
    and_6: and2 port map(s_comp, nrw, d_write);

    --WAIT: (counter.vhd). wait for memory to propgate, 7 cycles
    --stops once all data has been propogated
    or_4: or2 port map(s_wait, s_wbit, counting);
    inv_6: inverter port map(counting, cnt_rst);
    counter_1: counter port map(clk, cnt_rst, cnt);
    and_7: and2 port map(cnt(2), cnt(1), q2q1);
    and_8: and2 port map(cnt(3), cnt(0), q3q0);
    or_5: or2 port map(cnt(3), q2q1, q_ge7);
    and_9: and2 port map(cnt(0), q_ge7, ge7odd);
    and_10: and2 port map(q2q1, q3q0, all15);
    inv_7: inverter port map(ge7odd, nge7odd); --keep track of if past 7th cycle
    inv_8: inverter port map(all15, nall15);

    --WAIT NEXT BIT: from REQ, from WRITE BIT
    and_11: and2 port map(s_wait, ge7odd, wait_done);
    and_12: and2 port map(s_wait, nge7odd, wait_hold);
    or_6: or2 port map(s_req, s_wbit, enter_wait);
    or_7: or2 port map(enter_wait, wait_hold, d_wait);

    --WRITE BIT: counter is not 15
    and_13: and2 port map(wait_done, nall15, go_wbit);

    --READ: wait is done and the counter is 15 (all 4 bytes written)
    and_14: and2 port map(wait_done, all15, go_read);

    --byte counter. counts up when WRITE BIT entered
    xnor_1: xnor2 port map(b0, go_wbit, x_b0);
    inv_9: inverter port map(x_b0, t_b0);
    or_8: or2 port map(t_b0, s_req, d_b0);
    and_15: and2 port map(go_wbit, b0, carry_b);
    xnor_2: xnor2 port map(b1, carry_b, x_b1);
    inv_10: inverter port map(x_b1, t_b1);
    or_9: or2 port map(t_b1, s_req, d_b1);

    --hit_q: hit saved at the end of COMPARE
    mux_1: mux port map(hit_q, hit, s_comp, d_hq);

    --state flip flops
    ff_idle: ndflip port map(d_nidle, clk, reset, s_nidle);
    ff_comp: ndflip port map(d_comp, clk, reset, s_comp);
    ff_read: ndflip port map(go_read, clk, reset, s_read);
    ff_write: ndflip port map(d_write, clk, reset, s_write);
    ff_req: ndflip port map(d_req, clk, reset, s_req);
    ff_wbit: ndflip port map(go_wbit, clk, reset, s_wbit);
    ff_wait: ndflip port map(d_wait, clk, reset, s_wait);
    ff_out: ndflip port map(d_out, clk, reset, s_out);

    --byte counter and hit_q flip flops
    ff_b0: ndflip port map(d_b0, clk, reset, b0);
    ff_b1: ndflip port map(d_b1, clk, reset, b1);
    ff_hit_q: ndflip port map(d_hq, clk, reset, hit_q);

    --outputs
    nor_1: nor2 port map(s_idle, s_out, busy); --sets busy to 1 if not in idle state
    or_10: or2 port map(s_comp, s_read, out_load_i); --load for output register
    or_11: or2 port map(out_load_i, s_write, dec_a); --decoder operation 
    or_12: or2 port map(s_wbit, s_wait, refill_i); --refill path
    or_13: or2 port map(dec_a, refill_i, dec_en); --enable decoder
    and_16: and2 port map(s_write, hit_q, wr_hit); --signals to write 1 byte
    or_14: or2 port map(s_wbit, wr_hit, data_wr); --data_wr detmination
    nor_2: nor2 port map(b1, b0, b_zero); --first byte of refill, tag and valid bit will be written
    and_17: and2 port map(s_wbit, b_zero, tv_wr); --writes tag and valid bit

    --output signals
    load_in <= s_idle;
    out_oe <= s_out;
    mem_enable <= s_req;
    ma_oe <= s_req; 
    byte_cnt <= b1 & b0;
    out_load <= out_load_i;
    refill <= refill_i;

end structural;