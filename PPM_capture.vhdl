
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ppm_generate is 
	port( clk : in std_logic;
		  ppm_input : in std_logic;
		  slv_reg10 : out std_logic_vector(31 downto 0);
		  slv_reg11 : out std_logic_vector(31 downto 0);
		  slv_reg12 : out std_logic_vector(31 downto 0);
		  slv_reg13 : out std_logic_vector(31 downto 0);
		  slv_reg14 : out std_logic_vector(31 downto 0);
		  slv_reg15 : out std_logic_vector(31 downto 0);
		  frame_done : out std_logic );		  
end ppm_generate;

architecture ppm_capture_arch of ppm_capture is
	signal timer_counter 			: unsigned(31 downto 0);
	signal timer_counter_plus_one	: unsigned(31 downto 0);
	signal channel_mux_select   			: unsigned(3 downto 0);
	
	signal timer_mux_select, timer_enable : std_logic;
	signal channel_mux_write, frame_done_write, channel_counter_increment, channel_counter_reset : std_logic;
	
	type state_type is (S1a, S1b, S2, S3a, S3b, S4);
	signal PS, NS : state_type;
	
	begin
	
	--FSM sync process
	process(clk, NS)
	begin
		if rising_edge(clk) then
			PS <= NS;
		end if;
	end process;
	
	--FSM async process
	process(PS, ppm_input)
		timer_mux_select 