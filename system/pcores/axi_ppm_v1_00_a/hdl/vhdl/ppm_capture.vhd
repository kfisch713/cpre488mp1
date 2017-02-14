
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
	signal timer_counter, next_timer_counter	: unsigned(31 downto 0);
	signal timer_counter_plus_one	: unsigned(31 downto 0);
	signal timer_reached_idle_state : std_logic := '0';
	signal timer_mux_select, timer_enable : std_logic;
	
	signal channel_mux_write, frame_done_write, channel_counter_increment, channel_counter_reset : std_logic;
	signal channel_mux_select, next_channel_mux_select 			: unsigned(2 downto 0);

	signal tmp_reg_0, tmp_reg_1, tmp_reg_2, tmp_reg_3, tmp_reg_4, tmp_reg_5 : std_logic_vector(31 downto 0);
	signal next_tmp_reg_0, next_tmp_reg_1, next_tmp_reg_2, next_tmp_reg_3, next_tmp_reg_4, next_tmp_reg_5 : std_logic_vector(31 downto 0);
	
	type state_type is (S1a, S1b, S1c, S2, S3a, S3b, S4);
	signal PS, NS : state_type;
	
	attribute keep : string;
	
	
	attribute keep of channel_mux_select : signal is "true";
	attribute keep of slv_reg10 : signal is "true";
	attribute keep of slv_reg11 : signal is "true";
	attribute keep of slv_reg12 : signal is "true";
	attribute keep of slv_reg13: signal is "true";
	attribute keep of slv_reg14: signal is "true";
	attribute keep of slv_reg15: signal is "true";
	begin
	
	--FSM sync process
	process(clk, NS)
	begin
		if rising_edge(clk) then
			PS <= NS;
			channel_mux_select <= next_channel_mux_select;
			tmp_reg_0 <= next_tmp_reg_0;
			tmp_reg_1 <= next_tmp_reg_1;
			tmp_reg_2 <= next_tmp_reg_2;
			tmp_reg_3 <= next_tmp_reg_3;
			tmp_reg_4 <= next_tmp_reg_4;
			tmp_reg_5 <= next_tmp_reg_5;
			timer_counter <= next_timer_counter;
		end if;
	end process;
	
	--FSM async process
	process(PS, ppm_input, timer_reached_idle_state)
	begin
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
				channel_counter_reset <= '1';
				channel_counter_increment <= '0';
				channel_mux_write <= '0';
				
				frame_done_write <= '0';
				
				NS <= S1b;
				
			when S1b =>
				timer_mux_select <= '0';
				timer_enable <= '1';
				channel_counter_reset <= '0';
				channel_counter_increment <= '0';
				channel_mux_write <= '0';
				
				frame_done_write <= '0';
				
				NS <= S1c;
			when S1c =>
				timer_mux_select <= '1';
				timer_enable <= '0';
				channel_counter_reset <= '0';
				channel_counter_increment <= '0';
				channel_mux_write <= '0';
				
				frame_done_write <= '0';
				
				if (ppm_input = '1') then 
					NS <= S2; 
				else
					NS <= S1c;
				end if;
			when S2 =>
				timer_mux_select <= '1';
				timer_enable <= '1';
				channel_counter_reset <= '0';
				channel_counter_increment <= '0';
				channel_mux_write <= '0';
				
				frame_done_write <= '0';
			
				if (timer_reached_idle_state = '1') then
					NS <= S4; 
				elsif (ppm_input = '1') then
					NS <= S2;
				else 
					NS <= S3a;
				end if;
			when S3a =>
				timer_mux_select <= '1';
				timer_enable <= '0';
				channel_counter_reset <= '0';
				channel_counter_increment <= '0';
				channel_mux_write <= '1';
				
				frame_done_write <= '0';
				
				NS <= S3b;	
			
			when S3b =>
				timer_mux_select <= '1';
				timer_enable <= '0';
				channel_counter_reset <= '0';
				channel_counter_increment <= '1';
				channel_mux_write <= '0';
				
				frame_done_write <= '0';
				
				NS <= S1b;

			when S4 =>
				timer_mux_select <= '1';
				timer_enable <= '0';
				channel_counter_reset <= '0';
				channel_counter_increment <= '0';
				channel_mux_write <= '0';
				
				frame_done_write <= '1';
				
				NS <= S1a;
		end case;
	end process;
	
	with PS select 
		frame_done  <= '1' when S4,
							'0' when others;
								
								
	--1. channel select mux
	process(channel_mux_select, tmp_reg_0, tmp_reg_1, tmp_reg_2, tmp_reg_3, tmp_reg_4, tmp_reg_5, channel_mux_write, timer_counter)
	begin
	
		next_tmp_reg_0 <= tmp_reg_0;
		next_tmp_reg_1 <= tmp_reg_1;
		next_tmp_reg_2 <= tmp_reg_2;
		next_tmp_reg_3 <= tmp_reg_3;
		next_tmp_reg_4 <= tmp_reg_4;
		next_tmp_reg_5 <= tmp_reg_5;
		
		if(channel_mux_write = '1') then 
			if(channel_mux_select = 0) then
				next_tmp_reg_0 <= std_logic_vector(timer_counter);
				
			elsif(channel_mux_select = 1) then
				next_tmp_reg_1 <= std_logic_vector(timer_counter);
				
			elsif (channel_mux_select = 2) then
				next_tmp_reg_2 <= std_logic_vector(timer_counter);
				
			elsif(channel_mux_select = 3) then
				next_tmp_reg_3 <= std_logic_vector(timer_counter);
				
			elsif(channel_mux_select = 4) then
				next_tmp_reg_4 <= std_logic_vector(timer_counter);
				
			elsif(channel_mux_select = 5) then
				next_tmp_reg_5 <= std_logic_vector(timer_counter);
			end if;
		end if;
	end process;
	
	--2. Add 1 to timer
	process(clk, timer_counter)
	begin
		if rising_edge(clk) then
			timer_counter_plus_one <= unsigned(timer_counter) + 1;
		end if;
	end process;
	
	--3. Timer mux select
	process(timer_mux_select, timer_counter_plus_one, timer_enable, timer_counter)
	begin
		
		timer_reached_idle_state <= '0';
		next_timer_counter <= timer_counter;
		
		if(timer_enable = '1') then
			if(timer_mux_select = '1') then
				next_timer_counter <= timer_counter_plus_one;
			else
				next_timer_counter <= (others => '0');
			end if;
			
			if(timer_counter >= 500000) then
				timer_reached_idle_state <= '1';
			else
				timer_reached_idle_state <= '0';
			end if;	
		end if;
		
	end process;
	
	
	--4. Channel counter / the select for the channel mux
	process(channel_counter_increment, channel_counter_reset, channel_mux_select)
	begin
	
		next_channel_mux_select <= channel_mux_select;
	
		if(channel_counter_increment = '1') then
			next_channel_mux_select <= unsigned(channel_mux_select) + 1;
		end if;
		
		if(channel_counter_reset = '1') then
			next_channel_mux_select <= (others => '0');
		end if;
	end process;
	
	--Frame is done. Write the buffers to output.
	process(clk, frame_done_write)
	begin
		if rising_edge(clk) then 
			if(frame_done_write = '1') then
				slv_reg10 <= tmp_reg_0;
				slv_reg11 <= tmp_reg_1;
				slv_reg12 <= tmp_reg_2;
				slv_reg13 <= tmp_reg_3;
				slv_reg14 <= tmp_reg_4;
				slv_reg15 <= tmp_reg_5;
			end if;
		end if;
	end process;
	
end ppm_capture_arch;