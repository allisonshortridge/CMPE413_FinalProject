library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity hit_miss_test is 
end hit_miss_test;

architecture test of hit_miss_test is
    component hit_miss port (
            tag_req     : in std_logic_vector(1 downto 0);
            tag_stored  : in std_logic_vector(1 downto 0);
            valid       : in std_logic;
            hit         : out std_logic
        );
    end component;

    for hit_miss_1: hit_miss use entity work.hit_miss(structural);

    signal tag_req, tag_stored: std_logic_vector(1 downto 0);
    signal valid, hit: std_logic;
    signal clock: std_logic;
    signal done: std_logic := '0';

begin 
    hit_miss_1: hit_miss port map(tag_req, tag_stored, valid, hit);

clk : process
begin
    --stop the clock after done bit set
    if done = '1' then
        wait;
    end if;

    clock<='0','1' after 5 ns;
    wait for 10 ns;

end process clk;

io_process: process
    variable buff : line;

begin
    for k in 0 to 31 loop
        --allows for all 32 bits to be tested
        tag_req    <= std_logic_vector(to_unsigned(k / 8, 2));
        tag_stored <= std_logic_vector(to_unsigned((k / 2) mod 4, 2));
        if (k mod 2) = 1 then
            valid <= '1';
        else
            valid <= '0';
        end if;

        wait until falling_edge(clock);

        --write results
        write(buff, string'("tag_req="));
        write(buff, tag_req);
        write(buff, string'(" tag_stored="));
        write(buff, tag_stored);
        write(buff, string'(" valid="));
        write(buff, valid);
        write(buff, string'("  ->  hit="));
        write(buff, hit);
        writeline(output, buff);

    end loop;
    done <= '1';
    wait;
end process io_process;


end test;