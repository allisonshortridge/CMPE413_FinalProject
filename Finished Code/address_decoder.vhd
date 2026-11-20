library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity address_decoder is
    port (
        address     :   in std_logic_vector(3 downto 0);
        chip_en     :   in std_logic;
        refill      :   in std_logic;                       -- FSM: take byte offset from byte_cnt
        byte_cnt    :   in std_logic_vector(1 downto 0);    -- FSM: byte being refilled
        block_en    :   inout std_logic_vector(3 downto 0);
        byte_en     :   inout std_logic_vector(15 downto 0)
    );
end address_decoder;

architecture structural of address_decoder is

component decoder2to4
    port (
        A1    : in std_logic;
        A0    : in std_logic;
        E     : in std_logic;
        Y3    : out std_logic;
        Y2    : out std_logic;
        Y1    : out std_logic;
        Y0    : out std_logic
    );
end component;

component mux
    port (
        input1  : in std_logic;
        input2  : in std_logic;
        sel     : in std_logic;
        y       : out std_logic
    );
end component;


component and2
    port (
        input1  : in std_logic;
        input2  : in std_logic;
        output  : out std_logic
    );
end component;

for block_decoder, byte_dec0, byte_dec1, byte_dec2, byte_dec3: decoder2to4 use entity work.decoder2to4(structural);

for off_mux1, off_mux0: mux use entity work.mux(structural);

signal off : std_logic_vector(1 downto 0);

begin
    
    -- byte offset: requested byte normally, byte_cnt while refilling
    off_mux1: mux port map(address(1), byte_cnt(1), refill, off(1));
    off_mux0: mux port map(address(0), byte_cnt(0), refill, off(0));

    -- decode which block is being accessed
    block_decoder: decoder2to4 port map(address(3), address(2), chip_en, block_en(3), block_en(2), block_en(1), block_en(0));

    byte_dec0: decoder2to4 port map(off(1), off(0), block_en(0), byte_en(3), byte_en(2), byte_en(1), byte_en(0));
    byte_dec1: decoder2to4 port map(off(1), off(0), block_en(1), byte_en(7), byte_en(6), byte_en(5), byte_en(4));
    byte_dec2: decoder2to4 port map(off(1), off(0), block_en(2), byte_en(11), byte_en(10), byte_en(9), byte_en(8));
    byte_dec3: decoder2to4 port map(off(1), off(0), block_en(3), byte_en(15), byte_en(14), byte_en(13), byte_en(12));

end structural;
