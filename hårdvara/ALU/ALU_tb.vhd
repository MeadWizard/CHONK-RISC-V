library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--library work;
--use work.PIPECPU_STD.ALL;

entity ALU_tb is
end ALU_tb;

architecture sim of ALU_tb is

	component ALU_comp is
	port(
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
	end component;

	signal tb_clk : std_logic;
	signal tb_regA : std_logic_vector(15 downto 0);
	signal tb_regB : std_logic_vector(15 downto 0);
	signal tb_digitC : std_logic_vector(15 downto 0);
	signal tb_rst : std_logic;
	signal tb_control_signals : std_logic_vector(4 downto 0);
	signal tb_Z : std_logic;
	signal tb_N : std_logic; 
	signal tb_V : std_logic; 
	signal tb_C : std_logic;
	signal tb_D2 : std_logic_vector(15 downto 0);

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

	UUT : ALU_comP port map(
		clk => tb_clk,
		regA => tb_regA,
		regB => tb_regB,
		digitC => tb_digitC,
		rst => tb_rst,
		control_signals => tb_control_signals,
		Z => tb_Z,
		N => tb_N,
		V => tb_V,
		C => tb_C,
		D2 => tb_D2
	);
	
	process
	begin
	for i in 0 to 450 loop
		tb_clk <= '0';
		wait for 5 ns;
		tb_clk <= '1';
		wait for 5 ns;
	end loop;
	end process;

	process
	begin

		tb_rst <= '1';
		wait for 2 ns;
		tb_rst <= '0';

		----- TEST 1 -----

		report "Testing Addition" severity note;
	
		tb_control_signals <= "0" & cADD;
		tb_regA <= X"0006";
    	tb_regB <= X"0003";
		tb_digitC <= X"0001";
    	wait until rising_edge(tb_clk);
    	wait for 1 ns;
		assert (
    	  tb_D2 = X"0009"
    	)
    	report "Addition FAILED."
    	severity error;
	
		tb_control_signals <= "1" & cADD;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"0007"
    	)
    	report "Addition Immediate FAILED."
    	severity error;

		----- TEST 2 -----
		
		report "Testing Subtraction" severity note;

		tb_control_signals <= "0" & cSUB;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"0003"
    	)
    	report "Subtraction FAILED."
    	severity error;
	
		tb_control_signals <= "1" & cSUB;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"0005"
    	)
    	report "Subtraction Immediate FAILED."
    	severity error;

		----- TEST 3 -----

		report "Testing Multiplication" severity note;

		tb_control_signals <= "0" & cMUL;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"0012"
    	)
    	report "Multiplication FAILED."
    	severity error;

		tb_control_signals <= "1" & cMUL;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"0006"
    	)
    	report "Multiplication Immediate FAILED."
    	severity error;

		----- TEST 4 -----

		report "Testing LSL" severity note;
	
		tb_control_signals <= "0" & cLSL;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"000C"
    	)
    	report "Logical Shift Left FAILED."
    	severity error;
	
		tb_control_signals <= "1" & cLSL;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"000C"
    	)
    	report "Logical Shift Left (Immeadiate) FAILED."
    	severity error;

		----- TEST 5 -----

		report "Testing LSR" severity note;
	
		tb_control_signals <= "0" & cLSR;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"0003"
    	)
    	report "Logical Shift Right FAILED."
    	severity error;
	
		tb_control_signals <= "1" & cLSR;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"0003"
    	)
    	report "Logical Shift Right (Immeadiate) FAILED."
    	severity error;

		----- TEST 6 -----

		report "Testing AND" severity note;
	
		tb_control_signals <= "0" & cAND;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"0002"
    	)
    	report "And FAILED."
    	severity error;
	
		tb_control_signals <= "1" & cAND;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"0000"
    	)
    	report "AND (Immeadiate) FAILED."
    	severity error;

		----- TEST 7 -----
	
		report "Testing OR" severity note;

		tb_control_signals <= "0" & cOR;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"0007"
    	)
    	report "Or FAILED."
    	severity error;
	
		tb_control_signals <= "1" & cOR;
    	wait until rising_edge(tb_clk);
		wait for 1 ns;
    	assert (
    	  tb_D2 = X"0007"
    	)
    	report "OR (Immeadiate) FAILED."
    	severity error;
		
		wait; -- wait forever, will finish simulation
	end process;
		
end architecture;
