
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ppm_generate is 
	port( clk : in std_logic;
		  slv_reg20 : in std_logic_vector(31 downto 0);
		  slv_reg21 : in std_logic_vector(31 downto 0);
		  slv_reg22 : in std_logic_vector(31 downto 0);
		  slv_reg23 : in std_logic_vector(31 downto 0);
		  slv_reg24 : in std_logic_vector(31 downto 0);
		  slv_reg25 : in std_logic_vector(31 downto 0);
		  flag 		: out unsigned(31 downto 0);
		  ppm_output : out std_logic );
end ppm_generate;

architecture ppm_generate_arch of ppm_generate is
	signal slv_reg_data			: unsigned(31 downto 0);
	signal slv_reg_data_minus1  : unsigned(31 downto 0);
	signal low_counter_data		: unsigned(31 downto 0);
	signal channel_mux_output	: std_logic_vector(31 downto 0);
	signal low_counter_data_minus1 : unsigned(31 downto 0);
	signal timer_20_ms 			: unsigned(31 downto 0) := to_unsigned(0, 32);
	
	
	signal channel_select_reset, slv_reg_select, low_counter_select, channel_select_write_enable : std_logic;
	signal ppm_to_low, ppm_to_high : std_logic;
	signal channel_select : unsigned(2 downto 1);
	
	type state_type is (S1a, S1b, S2a, S2b, S2c, S3);
	signal PS, NS : state_type;
	
	

	begin
	
	--FSM sync process
	process(clk, NS)
	begin
		if rising_edge(clk) then
			timer_20_ms <= timer_20_ms + 1;
			PS <= NS;
			
			--flag <= to_unsigned(1, 32);

			if (timer_20_ms >= 2000000) then 
				timer_20_ms <= (others => '0');
				PS <= S1a;
			end if; 
		end if;
	end process;
	
	--FSM async process
	process(PS, ppm_to_low, ppm_to_high, channel_select_write_enable)
	begin
		channel_select_reset <= '0';
		channel_select_write_enable <= '0';
		slv_reg_select <= '0';
		low_counter_select <= '0';

		case PS is
			when S1a =>
				channel_select_reset <= '1';
				channel_select_write_enable <= '0';
				slv_reg_select <= '0';
				low_counter_select <= '0';
				
				NS <= S1b;
				
			when S1b =>
				channel_select_reset <= '1';
				channel_select_write_enable <= '0';
				slv_reg_select <= '0';
				low_counter_select <= '1';
				
				if (ppm_to_high = '1') then 
					NS <= S2a; 
				else
					NS <= S1b;
				end if;
			
			when S2a =>
				channel_select_reset <= '0';
				channel_select_write_enable <= '1';
				slv_reg_select <= '0';
				low_counter_select <= '0';
				
				NS <= S2b;
				
			when S2b =>
				channel_select_reset <= '0';
				channel_select_write_enable <= '0';
				slv_reg_select <= '1';
				low_counter_select <= '0';
				
				if (ppm_to_low = '1') then
					NS <= S2c;
				else
					NS <= S2b;
				end if;
			
			when S2c =>
				channel_select_reset <= '0';
				channel_select_write_enable <= '0';
				slv_reg_select <= '0';
				low_counter_select <= '1';
				
				if (channel_select = "101" and ppm_to_high = '1') then
					NS <= S3;
				elsif (ppm_to_high = '1') then
					NS <= S2a;
				else 
					NS <= S2c;
				end if;
				
			when S3 =>
				channel_select_reset <= '0';
				channel_select_write_enable <= '0';
				slv_reg_select <= '0';
				low_counter_select <= '1';
			
		end case;			
	end process;
	
	with PS select
		ppm_output <= '0' when S1a,
					  '0' when S1b,
					  '0' when S2a,
					  '1' when S2b,
					  '0' when S2c,
					  '1' when S3,
					  '0' when others;
	
	--1. channel select mux
	process(channel_select, slv_reg20, slv_reg21, slv_reg22, slv_reg23, slv_reg24, slv_reg25)
	begin
		if(channel_select = 0) then
			channel_mux_output <= slv_reg20;
			
		elsif(channel_select = 1) then
			channel_mux_output <= slv_reg21;
			
		elsif (channel_select = 2) then
			channel_mux_output <= slv_reg22;
			
		elsif(channel_select = 3) then
			channel_mux_output <= slv_reg23;
			
		elsif(channel_select = 4) then
			channel_mux_output <= slv_reg24;
			
		elsif(channel_select = 5) then
			channel_mux_output <= slv_reg25;
		end if;
	end process;
		
			
	--2. Compare slv_reg_data to zero
	process(slv_reg_data)
	begin
		if (unsigned(slv_reg_data) = 0) then 
			ppm_to_low <= '1';
		else
			ppm_to_low <= '0';
		end if;
	end process;
	
	--3. Subtract 1 from low_counter_data
	process(clk, low_counter_data)
	begin
		if rising_edge(clk) then
			low_counter_data_minus1 <= unsigned(low_counter_data) - 1;
		end if;
	end process;
	
	--4. Compare low_counter_data to zero
	process(low_counter_data)
	begin
		if(unsigned(low_counter_data) = 0) then	
			ppm_to_high <= '1';
		else
			ppm_to_high <= '0';
		end if;
	end process;
	
	--5. Channel select
	process(clk, channel_select_reset, channel_select_write_enable)
	begin
		flag <= to_unsigned(2, 32);
	
		if (channel_select_write_enable = '1') then
			channel_select <= unsigned(channel_select) + 1;
			
		else
			channel_select <= channel_select;
		end if;
		
		-- reseting takes priority over incermenting 
		if (channel_select_reset = '1') then
			channel_select <= (others => '0');
		end if;
	end process;
	
	--6. Subtract 1 from slv_reg_data
	process(clk, slv_reg_data)
	begin
		if rising_edge(clk) then
			slv_reg_data_minus1 <= unsigned(slv_reg_data) - 1;
		end if;
	end process;
	
	--7. Slave_reg_data mux
	process(slv_reg_select, channel_mux_output, slv_reg_data_minus1)
	begin
		if (slv_reg_select = '1') then
			slv_reg_data <= slv_reg_data_minus1;
		else
			slv_reg_data <= unsigned(channel_mux_output);
		end if;
	end process;
	
	--8. low_counter_mux
	process(clk, low_counter_select, low_counter_data_minus1)
	begin
		if(low_counter_select = '1') then
			low_counter_data <= low_counter_data_minus1;
		else
			low_counter_data <= to_unsigned(400000, 32);
		end if;
	end process;
	
	
end ppm_generate_arch;