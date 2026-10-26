-- for cache cell

    -- uses 4 2-input NOR gates and an inverter

library STD;
library IEEE;
use IEEE.std_logic_1164.all;


-- positive level sensitive dlatch
entity pos_dlatch is
    port (
        d   : in  std_logic;
        en : in  std_logic;
        q   : out std_logic;
        qbar: out std_logic
    );
end pos_dlatch;

architecture structural of pos_dlatch is

-- 2-input NOR gate
component nor2
    port (

    );
end component

-- inverter
component inverter
  port (
    input    : in  std_logic;
    output   : out std_logic);
end component;

for nor2_1, nor2_2, nor2_3, nor2_4: nor2 use entity work.nor2(structural);
for inverter_1: inverter use entity work.inverter(structural);

signal not_d, d_nor_en_out, notd_nor_en_out, q_temp, qbar_temp:std_logic;

begin
    -- inversion of d input
    inverter_1: inverter port map(d, not_d);

    -- logic for q output
    nor2_1: nor2 port map(d, en, d_nor_en_out);
    nor2_2: nor2 port map(d_nor_en_out, qbar_temp, q_temp);

    -- logic for qbar output
    nor2_3: nor2 port map(not_d, en, notd_nor_en_out);
    nor2_4: nor2 port map(notd_nor_en_out, q_temp, qbar_temp);

    q<=q_temp;
    qbar<=qbar_temp;

end structural