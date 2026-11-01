library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--library work;
--use work.PIPECPU_STD.all;

entity awesomecomputer_tb is
end awesomecomputer_tb;

architecture sim of awesomecomputer_tb is

	component awesomecomputer is
		port(
			clk      : in std_logic;                         -- system clock
			btnC     : in std_logic;                         -- reset
			Hsync    : out std_logic;                        -- horizontal sync
			Vsync    : out std_logic;                        -- vertical sync
			vgaRed   : out std_logic_vector(3 downto 0);     -- VGA red
			vgaGreen : out std_logic_vector(3 downto 0);     -- VGA green
			vgaBlue  : out std_logic_vector(3 downto 0);     -- VGA blue
			PS2Clk  : in std_logic;                  -- PS2 clock
			PS2Data : in std_logic                 -- PS2 data
			);
	end component;

	signal clk : std_logic;
	signal rst : std_logic;
    signal kb_clk : std_logic;
    signal kb_data : std_logic;
    signal VGA_R : std_logic_vector(3 downto 0);
	signal VGA_G : std_logic_vector(3 downto 0);
	signal VGA_B : std_logic_vector(3 downto 0);
    signal Hsync : std_logic;
    signal Vsync : std_logic;
	
begin

	U0 : awesomecomputer port map(
		clk => clk,
		btnC => rst,
        PS2Clk => kb_clk,
        PS2Data => kb_data,
        vgaRed => VGA_R,
		vgaGreen => VGA_G,
		vgaBlue => VGA_B,
        Hsync => Hsync,
        Vsync => Vsync
	);
	
	process
	begin 

        kb_clk <= '0';
        kb_data <= '0';

		for i in 0 to 450 loop
			clk <= '0';
			wait for 5 ns;
			clk <= '1';
			wait for 5 ns;
		end loop;
		
		wait; -- wait forever, will finish simulation
	end process;
	
	rst <= '1', '0' after 17 ns;
	
end architecture;
