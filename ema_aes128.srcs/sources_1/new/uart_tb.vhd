----------------------------------------------------------------------------------
-- Company: SISLAB, UET-VNU, Vietnam
-- Engineer: Manh-Hiep DAO
-- 
-- Create Date: 12/29/2020 04:52:49 PM
-- Design Name: UART Testbench
-- Module Name: uart_tb - Behavioral
-- Project Name: ElectroMagnetic Evaluation for AES
-- Target Devices: BASYS-3 FPGA Evaluation Board 
-- Tool Versions: Xilinx Vivado 2015.4
-- Description: This testbench is used for function validating for UART Component
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;
--library std_developerskit;
--use std_developerskit.std_iopak.all;
library std;
use std.textio.all;
use std.env.all;

entity uart_tb is
end uart_tb;

architecture Behavioral of uart_tb is
   component top is
    generic (
        baud            : positive:= 9600;
        clock_frequency : positive:= 100000000
    );
    port (  
        clock           : in std_logic;
        reset           : in std_logic;
		tx_tick         : out std_logic;          -- I/O for evaluation
        rx_tick         : out std_logic;          -- I/O for evaluation
        rx_bit_tick     : out std_logic;          -- I/O for evaluation   	
        rx              : in std_logic;
        tx              : out std_logic
    );
    end component;
    
    -- Signals --
    signal clock, reset: std_logic := '0';
--    signal data_stream_in_stb, data_stream_in_ack, data_stream_out_stb: std_logic;
    signal rx, tx: std_logic:= '1';
    signal rx_tick, tx_tick, rx_bit_tick : std_logic;
    signal key, pt, cp  :   std_logic_vector(127 downto 0);
--    signal data_stream_in, data_stream_out: std_logic_vector(7 downto 0);
    -- Types Array of 8-bits registers
--    type memory is array (0 to 15) of std_logic_vector(7 downto 0);
--    signal temp: memory := (others => (others =>'0'));
    signal reg  :std_logic_vector (7 downto 0);
    -- Constant value definition --
    constant baud: integer:= 9600;
    constant clock_frequency: integer := 100000000;
    -- Clock period definition --
    constant clock_period : time := 10 ns;
    -- Function Converse Hex String to Std_logic_vector --
    function to_std_logic_vector( s : string )
        return std_logic_vector is
            variable r : std_logic_vector( s'length * 4 - 1 downto 0) ;
        begin
            for i in 1 to s'high loop
                case s(i) is
                    when '0' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "0000";
                    when '1' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "0001";
                    when '2' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "0010";
                    when '3' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "0011";
                    when '4' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "0100";
                   when '5' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "0101";                                                                                                
                    when '6' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "0110";
                    when '7' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "0111";
                    when '8' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "1000";
                    when '9' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "1001";
                    when 'A' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "1010";
                    when 'B' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "1011";
                    when 'C' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "1100";
                    when 'D' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "1101";
                    when 'E' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "1110";
                    when 'F' => 
                        r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "1111";   
                    when others => r(((s'length-i+1)*4-1) downto ((s'length-i+1)*4-4)) := "XXXX";  
                end case;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
            end loop;
            return std_logic_vector(r);
        end function;
begin
    -- Instantiate the Design Under Test (UUT)
    dut: top
    generic map (baud, clock_frequency)
    port map(clock, reset, tx_tick, rx_tick, rx_bit_tick,  rx, tx);

    -- Clock process definitions
	clock_process :process
	begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
	end process;
	
	-- Stimulus process
    stim_proc: process
    file infile1           : text open read_mode is "E:\01-WORK\Git\ema_aes\ema_aes.srcs\sim_1\new\ecb_tbl.txt";
    
    variable inline        : line;
    variable outline       : line;

    variable itr_numline   : string(1 to 2);
    variable key_line      : string(1 to 4);
    variable pt_line       : string(1 to 3);
    variable ct_line       : string(1 to 3);
    variable iteration_num : integer;
    variable hex_key_str   : string(1 to 32);
    variable hex_key_str_logic: std_logic_vector (127 downto 0);
--    variable hex_key       : string(1 to 2);
    variable pt_str        : string(1 to 32);
    variable hex_pt_str_logic: std_logic_vector (127 downto 0);
    variable ct_str        : string(1 to 32);
    variable exp_cipher    : std_logic_vector(127 downto 0);
    variable data_check    : std_logic_vector(127 downto 0);
    
    variable number_of_test : integer := 0;
    variable number_of_success : integer := 0;
    variable number_of_failure : integer := 0;
    
    variable key_reg: std_logic_vector(127 downto 0);
    variable pt_reg : std_logic_vector(127 downto 0);
--    variable reg    : std_logic_vector(7 downto 0);
    
    begin
       -- hold reset state for 100 ns.
        reset        <= '1';
        wait for 100 ns;    
        reset        <= '0';
        --begin testing
        write(outline, string'("Tables Known Answer Tests"));
        writeline(output, outline);
        write(outline, string'("-------------------------"));
        wait until (clock'event and clock ='1');
        rx <= '1';
        writeline(output, outline);
           while(not endfile(infile1)) loop
        wait until rising_edge(clock);
        wait until rising_edge(clock);
          readline(infile1, inline);
          read(inline, itr_numline);
          read(inline, iteration_num);
          readline(infile1, inline);
          read(inline, key_line);
          read(inline, hex_key_str);
          hex_key_str_logic    := to_std_logic_vector(hex_key_str);
          readline(infile1, inline);
          read(inline, pt_line);
          read(inline, pt_str);
          hex_pt_str_logic     := to_std_logic_vector(pt_str);
          readline(infile1, inline);
          read(inline, ct_line);
          read(inline, ct_str);
          wait for 2 ns;
--          wait until (rx_bit_tick = '1');
            for j in 1 to 16 loop
                reg <= hex_key_str_logic((127-8*(j-1)) downto (128-8*j));
                rx  <='0';
                wait until rx_tick = '1';
                wait until rx_tick = '1';
                wait until rx_tick = '1';
                wait until rx_tick = '1';
                wait until rx_tick = '1';
                wait until rx_tick = '1';
                wait until rx_tick = '1';
--                wait until rx_tick = '1';
--                wait until (rx_bit_tick = '1'); 
                rx <= reg(0);
--                wait until (rx_bit_tick = '1');              
                wait until (rx_bit_tick = '1');
                     rx <= reg(1);
                wait until (rx_bit_tick = '1');
                     rx <= reg(2);    
                wait until (rx_bit_tick = '1');
                     rx <= reg(3);
                wait until (rx_bit_tick = '1');
                     rx <= reg(4);
                wait until (rx_bit_tick = '1');
                     rx <= reg(5);
                wait until (rx_bit_tick = '1');
                     rx <= reg(6);             
                wait until (rx_bit_tick = '1');
                     rx <= reg(7);
                wait until (rx_bit_tick = '1');
                rx <= '1';
                
                wait until (rx_bit_tick = '1');
                rx <= '0';
          
          end loop;
          
          for j in 1 to 16 loop
              reg <= hex_pt_str_logic((127-8*(j-1)) downto (128-8*j));
              rx  <='0';
              wait until rx_tick = '1';
              wait until rx_tick = '1';
              wait until rx_tick = '1';
              wait until rx_tick = '1';
              wait until rx_tick = '1';
              wait until rx_tick = '1';
              wait until rx_tick = '1';
    --                wait until rx_tick = '1';
    --                wait until (rx_bit_tick = '1'); 
              rx <= reg(0);
    --                wait until (rx_bit_tick = '1');              
              wait until (rx_bit_tick = '1');
                   rx <= reg(1);
              wait until (rx_bit_tick = '1');
                   rx <= reg(2);    
              wait until (rx_bit_tick = '1');
                   rx <= reg(3);
              wait until (rx_bit_tick = '1');
                   rx <= reg(4);
              wait until (rx_bit_tick = '1');
                   rx <= reg(5);
              wait until (rx_bit_tick = '1');
                   rx <= reg(6);             
              wait until (rx_bit_tick = '1');
                   rx <= reg(7);
              wait until (rx_bit_tick = '1');
              rx <= '1';
              
              wait until (rx_bit_tick = '1');
              rx <= '0';
        
            end loop;
          writeline(output, outline);
          number_of_test := number_of_test + 1;    
        end loop;
   wait for clock_period*48;
   wait;
   end process;
    
end Behavioral;