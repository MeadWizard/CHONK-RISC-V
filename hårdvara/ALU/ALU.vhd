library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--library work;
--use work.PIPECPU_STD.all;

entity ALU_comp is
	port (
		----- IN -----
		clk : in std_logic;
		regA : in std_logic_vector(15 downto 0);
		regB : in std_logic_vector(15 downto 0);
		digitC : in std_logic_vector(15 downto 0);
		rst : in std_logic;

		control_signals : in std_logic_vector(4 downto 0); -- genererar styrsignaler 
		-- (a och b eller a och c) 
		-- add sub mul eller lsl lsr

		----- UT -----
		Z : out std_logic; -- 1 då resultatet är 0
		N : out std_logic; -- 1 då msb = 1
		V : out std_logic; -- 1 vid overflow
		C : out std_logic; -- 1 vid carry

		D2 : out std_logic_vector(15 downto 0)
	);
end ALU_comp;


architecture Behavioral of ALU_comp is

	signal value1 : unsigned(15 downto 0);
	signal value2 : unsigned(15 downto 0);

	signal temp   : unsigned(15+1 downto 0); -- en extra bit för carry/overflow

	signal result : unsigned (15 downto 0) := X"0000";

	----- konstanter -----
	constant zero : unsigned(15 downto 0) := X"0000";

	constant cNOP : std_logic_vector(3 downto 0) := "0000"; -- NOP
	constant cADD : std_logic_vector(3 downto 0) := "0001"; -- ADD, ADDI
	constant cSUB : std_logic_vector(3 downto 0) := "0010"; -- SUB, SUBI, CMP
	constant cMUL : std_logic_vector(3 downto 0) := "0011"; -- MUL, MULI
	constant cLSR : std_logic_vector(3 downto 0) := "0100"; -- LSR
	constant cLSL : std_logic_vector(3 downto 0) := "1000"; -- LSL		
	constant cAND : std_logic_vector(3 downto 0) := "0101"; -- AND	
	constant cOR  : std_logic_vector(3 downto 0) := "0110"; -- OR	
	constant cNOT : std_logic_vector(3 downto 0) := "0111"; -- NOT

begin

	----- MUX -----
	value1 <= unsigned(regA);

	with control_signals(4) select
    
		value2 	<= unsigned(regB) when '0',
				unsigned(digitC) when '1',
				zero when others;

	----- OPERATIONER ----

	with control_signals(3 downto 0) select

		temp <= ('0' & value1) + ('0' & value2) when cADD,
				('0' & value1) - ('0' & value2) when cSUB,
				'0' & zero when others;

	with control_signals(3 downto 0) select

		result <= temp(15 downto 0) when cADD,
				temp(15 downto 0) when cSUB,
				resize(value1*value2, 16) when cMUL,
				
				value1(14 downto 0) & '0' when cLSL,
				'0' & value1(15 downto 1) when cLSR, 
				value1 and value2 when cAND,
				value1 or value2 when cOR,
				not value1 when cNOT,
				zero when others;
		

	----- FLAGGOR -----

	with control_signals(3 downto 0) select
		C <= temp(15+1) when cADD,
			 temp(15+1) when cSUB,
			 '0' when others;

	V <= '1' when ((value1(15) xor value2(15)) = '0') and ((value1(15) xor temp(15)) = '1') 
			 and (cADD = control_signals(3 downto 0) or cSUB = control_signals(3 downto 0)) 
			 else '0';
	
	N <= '1' when result(15) = '1' else '0';
	
	Z <= '1' when ((result = X"0000") and (control_signals(3 downto 0) /= cNOP)) else '0';
	--Z <= '1' when ((result = X"0000")) else '0';
	
	-- process(clk)
	-- begin
	-- 	if rising_edge(clk) then
	-- 		if rst='1' then
	-- 			Z <= '0';
	-- 		elsif (result = X"0000" and control_signals /= cNOP) then
	-- 			Z <= '1';
	-- 		elsif (result /= X"0000" and control_signals /= cNOP) then
	-- 			Z <= '0';
	-- 		end if;
	-- 	end if;
	-- end process;

	----- D2 ------
	process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				D2 <= std_logic_vector(zero);
			else
				D2 <= std_logic_vector(result);
			end if;
		end if;
	end process;

end architecture;