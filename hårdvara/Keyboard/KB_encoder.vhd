library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations

-- entity
entity KBD_comp is
	port (
		clk             : in std_logic;   -- system clock 
		rst             : in std_logic;   -- reset signal
		PS2KeyboardCLK  : in std_logic;   -- USB keyboard PS2 clock
		PS2KeyboardData : in std_logic;   -- USB keyboard PS2 data
		key        : out std_logic_vector(7 downto 0); -- key, innehåller tangent
		MAKE_op         : out std_logic);                   -- one-pulsed key-enable, om vi ska skriva, = I-flaggan
end KBD_comp;

-- architecture
architecture behavioral of KBD_comp is
	signal PS2Clk  : std_logic;              -- Synchronized PS2 clock
	signal PS2Data : std_logic;              -- Synchronized PS2 data
	signal PS2Clk_Q1, PS2Clk_Q2 : std_logic; -- PS2 clock one pulse flip flop
	signal PS2Clk_op : std_logic;            -- PS2 clock one pulse 
	
	signal PS2Data_sr : std_logic_vector(10 downto 0);-- PS2 data shift register
	signal key_int : std_logic_vector(7 downto 0); -- internal version of key, tangent
	
	signal PS2BitCounter : unsigned(3 downto 0); -- PS2 bit counter
	signal BC11 : std_logic;                     -- '1' when PS2BitCounter = 11
	
	type state_type is (IDLE, MAKE, BREAK); -- declare state types for PS2
	signal PS2state : state_type;           -- PS2 state
	
begin
	
	-- D-vippor för PS2 klockan och tangenttrycket
	process(clk)
	begin
		if rising_edge(clk) then
			PS2Clk <= PS2KeyboardCLK;
			PS2Data <= PS2KeyboardData;
		end if;
	end process;
	
        
	-- enpulsa PS2 klockan
	
	process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				PS2Clk_Q1 <= '1';
				PS2Clk_Q2 <= '0';
			else
				PS2Clk_Q1 <= PS2Clk;
				PS2Clk_Q2 <= not PS2Clk_Q1;
			end if;
		end if;
	end process;
	
	PS2Clk_op <= (not PS2Clk_Q1) and (not PS2Clk_Q2);
	



	-- skiftregister

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				PS2Data_sr <= "00000000000"; 
			elsif PS2Clk_op = '1' then
				PS2Data_sr <= PS2Data & PS2Data_sr(10 downto 1);
			end if;
		end if;
	end process;


        

    key_int <= PS2Data_sr(8 downto 1); -- To be used internally
	key <= key_int;  -- Not allowed to read from out signal



	-- bit counter

	process(clk)
	begin
	if rising_edge(clk) then
		if rst = '1' then
			PS2BitCounter <= "0000";
			BC11 <= '0';
		elsif PS2Clk_op = '1' then	
			if PS2BitCounter = 10 then
				PS2BitCounter <= "0000";
				BC11 <= '1';
			else
				PS2BitCounter <= PS2BitCounter + 1;
			end if;
		else
			BC11 <= '0';
		end if;
			
	end if;	
	end process;


	-- ps2 state

	process(clk) begin
		if rising_edge(clk) then
			if rst = '1'  then
				PS2state <= IDLE; 
						  
			else
				case PS2state is
				
					when IDLE => if BC11 = '1' AND key_int = "11110000" then PS2state <= BREAK;
								elsif BC11 = '1' then PS2state <= MAKE;
								end if;
					when BREAK => if BC11 = '1' then PS2state <= IDLE;
								end if;
					when MAKE => PS2state <= IDLE;

					when others => 	PS2state <= IDLE;
				
				end case;
			end if;
		end if;
	end process;

        
    MAKE_op <= '1' when PS2state = MAKE else '0';
	
end behavioral;
