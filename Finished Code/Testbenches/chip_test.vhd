-- Entity: chip_test 
-- Architecture : test 
-- Author: cpatel2
-- Created On: 11/01/05
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.std_logic_arith.all;
use STD.textio.all;
  
entity chip_test is
  
end chip_test;
  
architecture test of chip_test is

  component cache_top  
    port (
      ca    : in  std_logic_vector(5 downto 0);
      cd   : inout  std_logic_vector(7 downto 0);
      rw : in  std_logic;    
      start      : in  std_logic;
      clk        : in  std_logic;
      reset      : in  std_logic;
      md   : in  std_logic_vector(7 downto 0);
      Vdd	 : in  std_logic;
      Gnd        : in  std_logic;
      busy       : out std_logic;
      enable     : out std_logic;
      ma    : out std_logic_vector(5 downto 0));
  end component;


  
  for c1 : cache_top use entity work.cache_top(structural);

  signal Vdd, Gnd: std_logic;
  signal cd, md: std_logic_vector(7 downto 0);
  signal ca, ma: std_logic_vector(5 downto 0);
  signal rw, reset, clk, start, clock, busy, enable: std_logic;

  signal clk_count: integer:=0;

procedure print_output is
   variable out_line: line;

   begin
   write (out_line, string' (" Clock: "));
   write (out_line, clk_count);
   write (out_line, string'(" Start: "));
   write (out_line, start);
   write (out_line, string'(" Cpu Read/Write: "));
   write (out_line, rw);
   write (out_line, string'(" Reset: "));
   write (out_line, reset);
   writeline(output, out_line);

   write (out_line, string' (" CPU address: "));
   write (out_line, ca);
   write (out_line, string'(" CPU data: "));
   write (out_line, cd);
   writeline(output, out_line);
   
   write (out_line, string'(" Memory data: "));
   write (out_line, md);   
   writeline(output, out_line);
   writeline(output, out_line);
      
   write (out_line, string'(" Busy: "));
   write (out_line, busy);
   write (out_line, string'(" Memory  Enable: "));
   write (out_line, enable);
   writeline(output, out_line);

   write (out_line, string'(" Memory  Address: "));
   write (out_line, ma);
   writeline(output, out_line);   

   write (out_line, string'(" ----------------------------------------------"));
   writeline(output, out_line);

   
end print_output;



begin

  Vdd <= '1';
  Gnd <= '0';
  clk <= clock;
  
  c1 : cache_top port map (ca, cd, rw, start, clk, reset, md, Vdd, Gnd, busy, enable, ma);   

  clking : process
  begin
    clock<= '1', '0' after 5 ns;
    wait for 10 ns;
  end process clking;
  
  io_process: process

    file infile  : text is in "C:\Users\Asra\Desktop\example_testbench_for_project\chip_in.txt";
    variable out_line: line;
    variable buf: line;
    variable value: std_logic_vector(7 downto 0);
    variable value0: std_logic_vector(5 downto 0);
    variable value1: std_logic;
    
  begin

    while not (endfile(infile)) loop
      
      wait until rising_edge(clock);
      print_output;

      readline(infile, buf);
      read(buf, value0);
      ca <= value0;

      readline(infile, buf);
      read(buf, value);
      cd <= value;

      readline(infile, buf);
      read(buf, value1);
      rw <= value1;

      readline(infile, buf);
      read(buf, value1);
      start <= value1;      

      readline(infile, buf);
      read(buf, value1);
      reset <= value1;      
      
      wait until falling_edge(clock);

      readline(infile, buf);
      read(buf, value);
      md <= value;
      
      clk_count <= clk_count+1;

      print_output;

    end loop;
    wait;
      
  end process io_process;


end test;
