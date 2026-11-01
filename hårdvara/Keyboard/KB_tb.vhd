-- library IEEE;
-- use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
-- use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
--                                         -- and various arithmetic operations

-- entity KB_tb is
-- end entity;

-- architecture sim of KB_tb is

-- 	component KBD_ENC is
-- 		port (
-- 			clk             : in std_logic;   -- system clock 
-- 			rst             : in std_logic;   -- reset signal
-- 			PS2KeyboardCLK  : in std_logic;   -- USB keyboard PS2 clock
-- 			PS2KeyboardData : in std_logic;   -- USB keyboard PS2 data
-- 			key        : out std_logic_vector(7 downto 0); -- key, innehåller tangent
-- 			MAKE_op         : out std_logic
-- 		);                   -- one-pulsed key-enable, om vi ska skriva
-- 	end component;

-- 	signal tb_clk : std_logic;
-- 	signal tb_rst : std_logic;
-- 	signal tb_data : std_logic;
-- 	signal tb_PS2clk : std_logic;
-- 	signal tb_key : std_logic_vector(7 downto 0);
-- 	signal tb_makeop : std_logic;
-- 	signal tb_test : std_logic_vector(10 downto 0);

-- begin
-- 	UUT : KBD_ENC port map(
-- 		clk => tb_clk,
-- 		rst => tb_rst,
-- 		PS2KeyboardCLK => tb_PS2clk,
-- 		PS2KeyboardData => tb_data,
-- 		key => tb_key,
-- 		MAKE_op => tb_makeop

-- 	);

-- 	---- Klocka ----
-- 	process
-- 	begin
-- 	for i in 0 to 450 loop
-- 		tb_clk <= '0';
-- 		wait for 5 ns;
-- 		tb_clk <= '1';
-- 		wait for 5 ns;
-- 	end loop;
-- 	end process;

-- 	process
-- 	begin
-- 		---- Reset ----
-- 		tb_rst <= '1';
-- 		wait for 2 ns;
-- 		tb_rst <= '0';

-- 		----- Test 1 -----
-- 		tb_test <= "00011100001";

-- 		-- skicka data
-- 		for i in 0 to 10 loop
-- 			tb_data <= '1';
-- 			tb_PS2clk <= '0';
-- 			wait for 40 ns;
-- 			tb_PS2clk <= '1';
-- 			wait for 40 ns;
-- 		end loop;

-- 		-- skicka data
-- 		for i in 0 to 10 loop
-- 			tb_data <= tb_test(i);
-- 			tb_PS2clk <= '0';
-- 			wait for 40 ns;
-- 			tb_PS2clk <= '1';
-- 			wait for 40 ns;
-- 		end loop;

-- 		--wait for 500 ns;
		
-- 		tb_data <= '1';
-- 		tb_PS2clk <= '0';
-- 		wait for 40 ns;
-- 		tb_PS2clk <= '1';
-- 		wait for 40 ns;

-- 		-- läs svaret
-- 		wait until rising_edge(tb_clk);
-- 		wait for 1 ns;
-- 		assert (
-- 			tb_key = X"1C" and tb_makeop = '1'
-- 		)
-- 		report "Keyboard FAILED."
-- 		severity error;

-- 		------ Test 2 ----- 
-- 		--...

-- 		wait;

-- 	end process;
-- end architecture;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity KB_tb is
end entity;

architecture sim of KB_tb is

	component KBD_ENC is
		port (
			clk             : in std_logic;
			rst             : in std_logic;
			PS2KeyboardCLK  : in std_logic;
			PS2KeyboardData : in std_logic;
			key             : out std_logic_vector(7 downto 0);
			MAKE_op         : out std_logic
		);
	end component;

	signal tb_clk : std_logic := '0';
	signal tb_rst : std_logic := '0';
	signal tb_data : std_logic := '1';
	signal tb_PS2clk : std_logic := '1';
	signal tb_key : std_logic_vector(7 downto 0);
	signal tb_makeop : std_logic;
	signal tb_test : std_logic_vector(10 downto 0);  -- 11 bitar: start + 8 data + parity + stop

begin

	-- Instansiera din enhet
	UUT : KBD_ENC port map(
		clk => tb_clk,
		rst => tb_rst,
		PS2KeyboardCLK => tb_PS2clk,
		PS2KeyboardData => tb_data,
		key => tb_key,
		MAKE_op => tb_makeop
	);

	---- Klockgenerator för systemklocka ----
	clk_proc : process
	begin
		while true loop
			tb_clk <= '0';
			wait for 5 ns;
			tb_clk <= '1';
			wait for 5 ns;
		end loop;
	end process;

	---- Stimuli process ----
	stim_proc : process
	begin
		-- Reset-systemet
		tb_rst <= '1';
		wait for 20 ns;  -- längre reset
		tb_rst <= '0';
		wait for 20 ns;

		----- Test 1 -----
		-- PS2-paket för scancode 1C (A-tangent)
		-- 0 startbit + 0011100 (1C) + parity 0 + stop 1
		tb_test <= "00000111001"; -- E1

		-- Skicka 11 bitar
		for i in 0 to 10 loop
			tb_data <= tb_test(i);
			wait for 10 ns;      -- ge tid för data att stabilisera
			tb_PS2clk <= '0';    -- fallande flank (data läses in)
			wait for 40 ns;
			tb_PS2clk <= '1';    -- klocka hög igen
			wait for 40 ns;
		end loop;

		-- Vänta lite efter ordet är skickat
		wait for 200 ns;

		-- Läs av svaret från din UUT
		wait until rising_edge(tb_clk);
		--wait for 10 ns;
		assert (
			key = X"1C"
		)
		report "Keyboard FAILED."
		severity error;

		report "Kolla så att make_op är enpulsad och att den kommer vid rätt tillfälle!!!"

		-- Avsluta simulering (eller fortsätt med fler testfall)
		wait;
	end process;

end architecture;
