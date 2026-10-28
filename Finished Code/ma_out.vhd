library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity ma_out is
    port (
        addr_in   : in std_logic_vector(7 downto 0);
        en  : in std_logic;
        y   : out std_logic_vector(7 downto 0)
    );
end ma_out;

architecture structural of ma_out is
    component tristate_buffer
        port (
        input1  :   in std_logic;
        en      :   in std_logic;
        output  :   out std_logic
        );
        end component;
    
    --basic gate instantiation
    for tri_1, tri_2, tri_3, tri_4, tri_5, tri_6, tri_7, tri_8: tristate_buffer use entity work.tristate_buffer(structural);

begin
    tri_1 : tristate_buffer port map (addr_in(0), en, y(0));
    tri_2 : tristate_buffer port map (addr_in(1), en, y(1));
    tri_3 : tristate_buffer port map (addr_in(2), en, y(2));
    tri_4 : tristate_buffer port map (addr_in(3), en, y(3));
    tri_5 : tristate_buffer port map (addr_in(4), en, y(4));
    tri_6 : tristate_buffer port map (addr_in(5), en, y(5));
    tri_7 : tristate_buffer port map (addr_in(6), en, y(6));
    tri_8 : tristate_buffer port map (addr_in(7), en, y(7));
end structural;