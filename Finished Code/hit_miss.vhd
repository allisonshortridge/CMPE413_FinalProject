library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity hit_miss is
    port (
        tag_req     : in std_logic_vector(1 downto 0);
        tag_stored  : in std_logic_vector(1 downto 0);
        valid       : in std_logic;
        hit         : out std_logic
    );
end hit_miss;

architecture structural of hit_miss is
    component xnor2
        port (
        input1  :   in std_logic;
        input2  :   in std_logic;
        output  :   out std_logic
        );
        end component;

    component and2
        port (
        input1  :   in std_logic;
        input2  :   in std_logic;
        output  :   out std_logic
        );
        end component;

    --basic gate instantiation
    for xnor_1, xnor_2: xnor2 use entity work.xnor2(structural);
    for and_1, and_2: and2 use entity work.and2(structural);

    --intermediate signals
    signal eq_0, eq_1, tag_match: std_logic;

begin
    xnor_1 : xnor2 port map (tag_req(0), tag_stored(0), eq_0);
    xnor_2 : xnor2 port map (tag_req(1), tag_stored(1), eq_1);

    and_1 : and2 port map (eq_0, eq_1, tag_match);
    and_2 : and2 port map (tag_match, valid, hit);
end structural;