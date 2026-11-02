## How to Run Testbenches
#### Output Registers (output_registers_test.vhd)
../launch_cadence_xrun.sh -top output_registers_test and2.vhd inverter.vhd or2.vhd nor2.vhd positive_dlatch.vhd mux.vhd ndflip.vhd output_registers.vhd output_registers_test.vhd -access rwc

#### CPU Data Register (cd_reg_test.vhd)
../launch_cadence_xrun.sh -top cd_reg_test and2.vhd or2.vhd inverter.vhd nor2.vhd positive_dlatch.vhd reg.vhd cd_reg.vhd cd_reg_test.vhd -access rwc

#### CPU Data Output (cd_out_test.vhd)
../launch_cadence_xrun.sh -top cd_out_test tx.vhd inverter.vhd tristate_buffer.vhd cd_out.vhd cd_out_test.vhd -access rwc

#### Memory Address Output (ma_out_test.vhd)
../launch_cadence_xrun.sh -top ma_out_test inverter.vhd tx.vhd tristate_buffer.vhd ma_out.vhd ma_out_test.vhd -access rwc

#### Hit/Miss Logic (hm_test.vhd)
../launch_cadence_xrun.sh -top hit_miss_test and2.vhd inverter.vhd or2.vhd xnor2.vhd hit_miss.vhd hm_test.vhd -access rwc

#### Address Decoder (address_decoder_test.vhd)
../launch_cadence_xrun.sh -top address_decoder_test and2.vhd inverter.vhd or2.vhd mux.vhd 2to4decoder.vhd address_decoder.vhd address_decoder_test.vhd -input sim.run -access +rwc

#### Cache Cell (cache_cell_test.vhd)
../launch_cadence_xrun.sh -top cache_cell_test and2.vhd inverter.vhd tx.vhd positive_dlatch.vhd 1to2decoder.vhd cache_cell.vhd cache_cell_test.vhd -access rwc

#### Least Recently Used (LRU) Unit (lru_test.vhd)
../launch_cadence_xrun.sh -top lru_test inverter.vhd and2.vhd or2.vhd nor2.vhd mux.vhd positive_dlatch.vhd tx.vhd 1to2decoder.vhd ndflip.vhd pdflip.vhd cache_cell.vhd cache_byte.vhd cache_block.vhd cache_way.vhd lru_unit.vhd lru_test.vhd -access rwc

#### Counter (counter_test.vhd)
../launch_cadence_xrun.sh -top counter_test inverter.vhd and2.vhd xor2.vhd or2.vhd nor2.vhd pdflip.vhd counter.vhd counter_test.vhd -access rwc

#### State Machine (fsm_test.vhd)
../launch_cadence_xrun.sh -top fsm_test inverter.vhd and2.vhd or2.vhd nor2.vhd xnor2.vhd xor2.vhd mux.vhd positive_dlatch.vhd ndflip.vhd pdflip.vhd counter.vhd cache_fsm.vhd fsm_test.vhd

#### Cache Top (cache_top_test.vhd)
../launch_cadence_xrun.sh -top cache_top_test and2.vhd inverter.vhd or2.vhd nor2.vhd xnor2.vhd xor.vhd tx.vhd tristate_buffer.vhd positive_dlatch.vhd hit_miss.vhd pdflip.vhd ma_out.vhd mux.vhd mux8.vhd ndflip.vhd counter.vhd reg.vhd cd_reg.vhd 1to2decoder.vhd 2to4decoder.vhd address_decoder.vhd ca_reg.vhd cd_out.vhd output_registers.vhd cache_cell.vhd cache_byte.vhd cache_block.vhd cache_way.vhd lru_unit.vhd cache_fsm.vhd cache_top.vhd cache_top_test.vhd -access rwc