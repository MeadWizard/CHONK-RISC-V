--------------------------------------------------------------------------------
-- VGA MOTOR
-- Version 1.1: 2016-02-16, Anders Nilsson
-- Version 1.2: 2023-01-11, Petter Kallstrom. Changelog: Corrected a pipeline mistake.
-- Version 2.0: 2023-09-29, Anders Nilsson. 12-bit VGA.
-- Version 3.0: 2025-04-29,	TSEA83 Group 36. Othello.


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity vga_comp is
	port (
		VM_data  : in std_logic_vector(15 downto 0);
		VM_addr  : out std_logic_vector(15 downto 0);
		clk      : in std_logic;
		clear    : in std_logic;
		vga_RGB  : out std_logic_vector(11 downto 0);
		Hsync    : out std_logic;
		Vsync    : out std_logic
		);
end vga_comp;


-- architecture
architecture Behavioral of vga_comp is
	
	signal Xpixel1, Xpixel2 : unsigned(9 downto 0); -- Horizontal pixel counter, and its pipelined version
	signal Ypixel1, Ypixel2 : unsigned(9 downto 0); -- Vertical pixel counter
	signal ClkDiv : unsigned(1 downto 0);          -- Clock divisor, to generate 25 MHz signal
	signal Clk25  : std_logic;                     -- One pulse width 25 MHz signal
	
	signal blank1, blank2, blank : std_logic; -- blanking signal, with delayed versions
	signal Hsync1, Hsync2 : std_logic;
	signal Vsync1, Vsync2 : std_logic;

	signal vgaRed   : std_logic_vector(3 downto 0);
	signal vgaGreen : std_logic_vector(3 downto 0);
	signal vgaBlue  : std_logic_vector(3 downto 0);
	
	-- Interna signaler för CHAR_ROM
	signal CR_addr  : unsigned(10 downto 0);       -- address for CHAR_ROM
	signal CR_data : std_logic_vector(11 downto 0); -- data from CHAR_ROM.

	-- Character image rom:
	component char_rom is
		port (
			clk      : in std_logic;
			addr     : in unsigned(10 downto 0);
			data     : out std_logic_vector(11 downto 0)
			);
	end component;
	
begin

	--------------------------------------------------------------------------------
	-- Följande vhdl-kod är den som är lite annorlunda från lab4

	-- Video ram address composite
	VM_addr <= "00000" & std_logic_vector(to_unsigned(20, 7) * Ypixel1(8 downto 5) + Xpixel1(9 downto 5));
	
	-- Character rom address:
	CR_addr <= unsigned(
	std_logic_vector(VM_data(4 downto 0)) & 
	std_logic_vector(Ypixel2(4 downto 2)) & 
	std_logic_vector(Xpixel2(4 downto 2)));
	
	U0b : char_rom port map (
		clk=>clk, 
		addr=>CR_addr, 
		data=>CR_data
	); -- one clock cycle delay.

	------------------------------------------------------------------------------
	
	
	-- Clock divisor
	-- Divide system clock (100 MHz) by 4
	process(clk)
	begin
		if rising_edge(clk) then
			if clear='1' then
				ClkDiv <= (others => '0');
			else
				ClkDiv <= ClkDiv + 1;
			end if;
		end if;
	end process;
	
	-- 25 MHz clock (one system clock pulse width)
	Clk25 <= '1' when (ClkDiv = 3) else '0';
	
	-- ClkDiv:  | 0 | 1 | 2 | 3 | 0 | 1 | 2 | 3 | 0 | 1 | 2 | 3 |
	-- Clk25:   |___|___|___|---|___|___|___|---|___|___|___|---|
	-- Xpixel1: |<     ...     >|<     ...     >|<     ...     >|
	-- Ypixel1: ...            >|<     ...                       
	-- VM_addr: |<     ...     >|<     ...     >|<     ...     >|  f(*pixel)
	-- VM_data: ...>|<     ...     >|<     ...     >|<     ...     f(addr) @ cc
	-- CR_Addr: ...>|<     ...     >|<     ...     >|<     ...     f(data, *pixel)
	-- CR_data:     ...>|<     ...     >|<     ...     >|< ...     f(tAddr) @ cc
	-- RGB:         ...>|<     ...     >|<     ...     >|< ...     f(tPixel)
	-- blank1:  |___|___|___|___|---|---|---|---|___|___|___|___|
	-- blank2:  |___|___|___|___|___|---|---|---|---|___|___|___|
	-- *sync1:  |---|---|---|---|___|___|___|___|---|---|---|---|
	-- *sync2:  |---|---|---|---|---|___|___|___|___|---|---|---|
	-- *sync:   |---|---|---|---|---|---|___|___|___|___|---|---|
	

	-- Horizontal pixel counter
	-- *******************************
	-- *                             *
	-- *  VHDL for:                  *
	-- *  Xpixel1                    *
	-- *                             *
	-- *****************VR**************

	process(clk)
	begin
		if rising_edge(clk) then

			if clear='1' then
				Xpixel1 <= (others => '0');

			elsif (Xpixel1 = 800) then
				Xpixel1 <= (others => '0');
			
			elsif (Clk25 = '1') then
				Xpixel1 <= Xpixel1 + 1;

			end if;
		end if;
	end process;

        -- Horizontal sync
	-- *******************************
	-- *                             *
	-- *  VHDL for:                  *
	-- *  Hsync1                     *
	-- *                             *
	-- *******************************

	
	process(clk)
	begin
		if rising_edge(clk) then

			if clear='1' then
				Hsync1 <= '0';

			elsif(Xpixel1 >= 656 and Xpixel1 <= 752) then
				Hsync1 <= '1';

			else
				Hsync1 <= '0';

			end if;
		end if;
	end process;

        -- Vertical pixel counter
	-- *******************************
	-- *                             *
	-- *  VHDL for:                  *
	-- *  Ypixel1                    *
	-- *                             *
	-- *******************************

	process(clk)
	begin
		if rising_edge(clk) then

			if clear='1' then
				Ypixel1 <= (others => '0');
		
			elsif (Xpixel1 = 800) then
				Ypixel1 <= Ypixel1 + 1;

				if (Ypixel1 = 521) then
					Ypixel1 <= (others => '0');

				end if;				

			end if;
		end if;

	

	end process;



        -- Vertical Sync
	-- *******************************
	-- *                             *
	-- *  VHDL for:                  *
	-- *  Vsync1                     *
	-- *                             *
	-- *******************************

	process(clk)
	begin
		if rising_edge(clk) then

			if clear='1' then
				Vsync1 <= '0';

			elsif(Ypixel1 >= 490 and Ypixel1 <= 491) then
				Vsync1 <= '1';

			else
				Vsync1 <= '0';

			end if;
		end if;
	end process;

        -- Video blanking signal
	-- *******************************
	-- *                             *
	-- *  VHDL for:                  *
	-- *  Blank1                     *
	-- *                             *
	-- *******************************
        
	process(clk)
	begin
		if rising_edge(clk) then

			if clear='1' then
				Blank1 <= '0';

			elsif(Xpixel1 >= 640 or Ypixel1 >= 480) then
				Blank1 <= '1';
			else
				Blank1 <= '0';

			end if;
		end if;
	end process;

	-- D-vippor steg 1: (håller vga signaler på rätt format och så att saker är synkroniserade)

	process(clk)
	begin
		if rising_edge(clk) then
			blank2 <= blank1;
			Hsync2 <= Hsync1;
			Vsync2 <= Vsync1;
			Xpixel2 <= Xpixel1;
			Ypixel2 <= Ypixel1;
		end if;
	end process;

	-- D-vippor steg 2: (håller vga signaler på rätt format och så att saker är synkroniserade)

	process(clk)
	begin
		if rising_edge(clk) then
			Hsync <= Hsync2;
			Vsync <= Vsync2;
			blank <= blank2;
		end if;
	end process;
	
	-- VGA generation : 4 bit red, 4 bit green ,4 bit blue
	vgaRed(3)   <= CR_data(11) when blank = '0' else '0';
	vgaRed(2)   <= CR_data(10) when blank = '0' else '0';
	vgaRed(1)   <= CR_data(9) when blank = '0' else '0';
	vgaRed(0)   <= CR_data(8) when blank = '0' else '0';
	vgaGreen(3) <= CR_data(7) when blank = '0' else '0';
	vgaGreen(2) <= CR_data(6) when blank = '0' else '0';
	vgaGreen(1) <= CR_data(5) when blank = '0' else '0';
	vgaGreen(0) <= CR_data(4) when blank = '0' else '0';
	vgaBlue(3)  <= CR_data(3) when blank = '0' else '0';
	vgaBlue(2)  <= CR_data(2) when blank = '0' else '0';
	vgaBlue(1)  <= CR_data(1) when blank = '0' else '0';
	vgaBlue(0)  <= CR_data(0) when blank = '0' else '0';

	vga_RGB <= vgaRed & vgaGreen & vgaBlue;
	
end Behavioral;

