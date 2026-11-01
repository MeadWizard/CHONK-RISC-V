--------------------------------------------------------------------------------
-- VGA lab testbench
-- Anders Nilsson
-- 26-feb-2020
-- Version 1.0


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                          -- and various arithmetic operations
entity vga_tb is
end entity;

architecture func of vga_tb is
	
	component vga_comp
		port (
			VM_data  : in std_logic_vector(15 downto 0);
			VM_addr  : out std_logic_vector(15 downto 0);
			clk      : in std_logic;
			clear    : in std_logic;
			vga_RGB  : out std_logic_vector(11 downto 0);
			Hsync    : out std_logic;
			Vsync    : out std_logic
			);
	end component;

	signal clk : std_logic;
	signal clear : std_logic;
	signal data  : std_logic_vector(15 downto 0);
	signal addr  : std_logic_vector(15 downto 0);
	signal vga_RGB  : std_logic_vector(11 downto 0);
	signal Hsync    : std_logic;
	signal Vsync    : std_logic;

	constant clk_period : time := 10 ns;

begin

	uut: vga_comp port map(
		clk => clk,
		clear => clear,
		VM_data => data,
		VM_addr => addr,
		vga_RGB => vga_RGB,
		Hsync => Hsync,
		Vsync => Vsync
	);

	clk_process : process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	clear <= '1', '0' after 25 ns;
	
end architecture;

