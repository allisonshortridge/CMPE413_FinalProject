library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity tristate_buffer is
    port (
        input1  :   in std_logic;
        en      :   in std_logic;
        output  :   out std_logic
    );
end tristate_buffer;

architecture structural of tristate_buffer is

-- inverter
component inverter
  port (
    input    : in  std_logic;
    output   : out std_logic);
end component;

-- transmission gate
component tx
    port ( 
        sel   : in std_logic;
        selnot: in std_logic;
        input : in std_logic;
        output : out std_logic
    );
end component;

for inverter_1, inverter_2, inverter_3: inverter use entity work.inverter(structural);
for tx_1: tx use entity work.tx(structural);

signal not_in, notnot_in, not_en: std_logic;

begin
    inverter_1: inverter port map(input1, not_in);
    inverter_2: inverter port map(not_in, notnot_in);

    inverter_3: inverter port map(en, not_en);

    tx_1: tx port map(en, not_en, notnot_in, output);

end structural;