
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ppm_capture is 
	port( clk : in std_logic;
		  ppm_input : in std_logic;
		  slv_reg10 : out std_logic_vector(31 downto 0);
		  slv_reg11 : out std_logic_vector(31 downto 0);
		  slv_reg12 : out std_logic_vector(31 downto 0);
		  slv_reg13 : out std_logic_vector(31 downto 0);
		  slv_reg14 : out std_logic_vector(31 downto 0);
		  slv_reg15 : out std_logic_vector(31 downto 0);
		  frame_done : out std_logic );		  
end ppm_capture;

architecture ppm_capture_arch of ppm_capture is
	signal timer_counter 			: unsigned(31 downto 0);
	signal timer_counter_plus_one	: unsigned(31 downto 0);
	signal timer_mux_select, timer_enable : std_logic;
	
	signal channel_mux_write, frame_done_write, channel_counter_increment, channel_counter_reset : std_logic;
	signal channel_mux_select   			: unsigned(3 downto 0);

	signal tmp_reg_0, tmp_reg_1, tmp_reg_2, tmp_reg_3, tmp_reg_4, tmp_reg_5 : std_logic_vector(31 downto 0);
	
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
		timer_mux_select <= '0';
		timer_enable <= '0';
		channel_counter_increment <= '0';
		channel_counter_reset <= '0';
		channel_mux_write <= '0';
		frame_done_write <= '0';
		
		case PS is 
			when S1a =>
				timer_mux_select <= '0';
				timer_enable <= '1';
				chann_counter_reset <= '1';
				channel_counter_increment <= '0';
				channel_mux_write <= '0';
				
				frame_done_write <= '0';
				
				NS <= S1b;
			when S1b =>
				timer_mux_select <= '1';
				timer_enable <= '0';
				channel_counter_reset <= '0';
				channel_counter_increment <= '0';
				channel_mux_write <= '0';
				
				frame_done_write <= '0';
				
				if (ppm_input = '1') then 
					NS <= S2; 
				else
					NS <= S1b;
				end if;
			when S2 =>
				timer_mux_select <= '1';
				timer_enable <= '1';
				channel_counter_reset <= '0';
				channel_counter_increment <= '0';
				channel_mux_write <= '0';
				
				
			
				if (ppm_input = '1' and channel_mux_select = 5) then
					NS <= S4; 
				else if (ppm_input = '1') then
					NS <= S2;
				else 
					NS <= S3a;
				end if;
			when S3a =>
				timer_mux_select <= '1';
				timer_enable <= '0';
				channel_counter_reset <= '0';
				channel_mux_write <= '1';
				
				NS <= S3b;	
			
			when S3b =>
				channel_mux_write <= '0';
				channel_counter_increment <= '1';
				
				PS <= S1a;



			when S4 =>
				frame_done_write <= '1';
				
				NS <= S1a;
		end case;
	end process;
	
	with PS select 
		frame_done_write  <= '1' when S4,
								<= '0' when others;
								
								
	--1. channel select mux
	process(channel_mux_select, tmp_reg_0, tmp_reg_1, tmp_reg_2, tmp_reg_3, tmp_reg_4, tmp_reg_5)
	begin
		if(channel_mux_select = 0) then
			tmp_reg_0 <= timer_counter;
			
		elsif(channel_mux_select = 1) then
			tmp_reg_1 <= timer_counter;
			
		elsif (channel_mux_select = 2) then
			tmp_reg_2 <= timer_counter;
			
		elsif(channel_mux_select = 3) then
			tmp_reg_3 <= timer_counter;
			
		elsif(channel_mux_select = 4) then
			tmp_reg_4 <= timer_counter;
			
		elsif(channel_mux_select = 5) then
			tmp_reg_5 <= timer_counter;
		end if;
	end process;
	
	--2. Add 1 to timer
	process(clk, timer_counter)
	begin
		if rising_edge(clk) then
			timer_counter_plus_one <= unsigned(timer_counter) + 1;
		end if;
	end process;
	
	
	


















		