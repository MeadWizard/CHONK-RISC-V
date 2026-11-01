--------------------------------------------------------------------------------
-- CHAR_ROM
-- Version 2.0: 2023-01-12, Petter Kallstrom. ROM part of VGA_MOTOR.
-- Description:
-- * This is just a single-port ROM, that contains the images of all characters
-- Version 3.0: 2023-09-29, Anders Nilsson. 12-bit ROM. 
-- Version 4.0: 2025-04-15, TSEA83 Grupp 36, OTHELLO.

-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity char_rom is
	port (
		clk      : in std_logic;
		addr     : in unsigned(10 downto 0);
		data     : out std_logic_vector(11 downto 0));
		
end char_rom;


-- architecture
architecture Behavioral of char_rom is
	type rom_t is array (0 to 2047) of std_logic_vector(11 downto 0);
	signal rom_data : rom_t;
	signal formatted_addr : unsigned(10 downto 0);

begin

	formatted_addr <= addr(10 downto 0);

	-- Read from the ROM:
	process(clk)
	begin
		if rising_edge(clk) then
			data <= rom_data(to_integer(formatted_addr));
		end if;
	end process;
	
	-- detta är alltså ett minne på 3 kilobyte eller 3072 byte mer exakt
	-- array 2048 av 12 bitarskoder = 32 karaktärer som består av 64 pixelvärden som är 12 bitarskoderna

	rom_data <= (
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- bakgrundsbricka -- 0
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"0F0",x"0F0",x"000",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"000",x"000",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"000",x"000",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"000",x"0F0",x"0F0",x"000",x"0F0",x"000",
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"DDD",  -- tom spelplansbricka -- 1
		x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"DDD",
		x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"DDD",
		x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"DDD",
		x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"DDD",
		x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"DDD",
		x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"0F0",x"DDD",
		x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"DDD",  -- spelplansbricka vit -- 2
		x"000",x"0F0",x"0F0",x"FFF",x"FFF",x"0F0",x"0F0",x"DDD",
		x"000",x"0F0",x"FFF",x"FFF",x"FFF",x"FFF",x"0F0",x"DDD",
		x"000",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"EEE",x"DDD",
		x"000",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"EEE",x"DDD",
		x"000",x"0F0",x"FFF",x"FFF",x"FFF",x"EEE",x"0F0",x"DDD",
		x"000",x"0F0",x"0F0",x"EEE",x"EEE",x"0F0",x"0F0",x"DDD",
		x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"DDD",  -- spelplansbricka svart -- 3
		x"000",x"0F0",x"0F0",x"111",x"111",x"0F0",x"0F0",x"DDD",
		x"000",x"0F0",x"111",x"111",x"111",x"111",x"0F0",x"DDD",
		x"000",x"111",x"111",x"111",x"111",x"111",x"000",x"DDD",
		x"000",x"111",x"111",x"111",x"111",x"111",x"000",x"DDD",
		x"000",x"0F0",x"111",x"111",x"111",x"000",x"0F0",x"DDD",
		x"000",x"0F0",x"0F0",x"000",x"000",x"0F0",x"0F0",x"DDD",
		x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"DDD",  -- markör -- 4
		x"000",x"0F0",x"0F0",x"090",x"090",x"0F0",x"0F0",x"DDD",
		x"000",x"0F0",x"090",x"090",x"090",x"090",x"0F0",x"DDD",
		x"000",x"090",x"090",x"090",x"090",x"090",x"090",x"DDD",
		x"000",x"090",x"090",x"090",x"090",x"090",x"090",x"DDD",
		x"000",x"0F0",x"090",x"090",x"090",x"090",x"0F0",x"DDD",
		x"000",x"0F0",x"0F0",x"090",x"090",x"0F0",x"0F0",x"DDD",
		x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",x"DDD",
		
		-------------------------------------------------------------
		-- Nästkommande tecken är något man kan implementera om man 
		-- tex vill kunna ha texten " Vit: 27    Svart: 23"
		-------------------------------------------------------------
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- V -- 5 "VIT:"
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"F00",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"0F0",x"F00",x"F00",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- I -- 6
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"F00",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"F00",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"000",x"0F0",x"F00",x"F00",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- T -- 7
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"F00",x"F00",x"F00",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"F00",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"F00",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"000",x"0F0",x"F00",x"F00",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- : -- 8
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"0F0",x"F00",x"000",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"000",x"000",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"000",x"000",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"000",x"0F0",x"0F0",x"000",x"0F0",x"000",
		x"000",x"000",x"0F0",x"0F0",x"F00",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- S -- 9 "SVART:"
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"F00",x"F00",x"F00",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"F00",x"F00",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"000",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"F00",x"F00",x"F00",x"F00",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- A -- 10
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"F00",x"F00",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"F00",x"0F0",x"0F0",x"F00",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- R -- 11
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"F00",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"F00",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"F00",x"0F0",x"0F0",x"F00",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- N -- 12
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"0F0",x"F00",x"F00",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",

		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- 0 -- 13
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"0F0",x"F00",x"F00",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- 1 -- 14
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"F00",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"F00",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"000",x"0F0",x"F00",x"F00",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- 2 -- 15
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"000",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"000",x"F00",x"0F0",x"000",x"0F0",x"000",
		x"000",x"000",x"F00",x"F00",x"F00",x"F00",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- 3 -- 16
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"000",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"0F0",x"F00",x"F00",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- 4 -- 17
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"0F0",x"F00",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"F00",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"F00",x"F00",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"000",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"F00",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- 5 -- 18
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"F00",x"F00",x"F00",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"F00",x"F00",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"000",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"F00",x"F00",x"F00",x"F00",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- 6 -- 19
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"F00",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"0F0",x"F00",x"F00",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- 7 -- 20
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"F00",x"F00",x"F00",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"000",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"000",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"000",x"F00",x"0F0",x"000",x"0F0",x"000",
		x"000",x"000",x"0F0",x"F00",x"0F0",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- 8 -- 21
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"F00",x"F00",x"0F0",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"0F0",x"F00",x"F00",x"0F0",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",  -- 9 -- 22
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"0F0",x"000",x"000",
		x"000",x"0F0",x"000",x"F00",x"F00",x"000",x"0F0",x"000",
		x"000",x"0F0",x"F00",x"000",x"000",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"0F0",x"F00",x"F00",x"F00",x"0F0",x"000",
		x"000",x"0F0",x"000",x"0F0",x"0F0",x"F00",x"0F0",x"000",
		x"000",x"000",x"0F0",x"0F0",x"0F0",x"F00",x"000",x"000",
		x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",
		
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",  -- 
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",  -- 
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",  -- 
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",  -- 
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",  -- 
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",  -- 
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",  -- 
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",  -- 
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",
		
		x"FFF",x"FFF",x"000",x"000",x"000",x"FFF",x"FFF",x"FFF",  -- amongus
		x"FFF",x"000",x"F00",x"F00",x"F00",x"000",x"FFF",x"FFF",
		x"FFF",x"000",x"000",x"000",x"F00",x"000",x"000",x"FFF",
		x"000",x"00F",x"00F",x"00F",x"000",x"F00",x"000",x"FFF",
		x"FFF",x"000",x"000",x"000",x"F00",x"F00",x"000",x"FFF",
		x"FFF",x"000",x"F00",x"F00",x"F00",x"000",x"000",x"FFF",
		x"FFF",x"000",x"F00",x"000",x"F00",x"000",x"FFF",x"FFF",
		x"FFF",x"000",x"000",x"000",x"000",x"000",x"FFF",x"FFF"

	);

end Behavioral;

		--x"FFF",x"FFF",x"000",x"000",x"000",x"FFF",x"FFF",x"FFF",      -- amongus
		--x"FFF",x"000",x"F00",x"F00",x"F00",x"000",x"FFF",x"FFF",
		--x"FFF",x"000",x"000",x"000",x"F00",x"000",x"000",x"FFF",
		--x"000",x"00F",x"00F",x"00F",x"000",x"F00",x"000",x"FFF",
		--x"FFF",x"000",x"000",x"000",x"F00",x"F00",x"000",x"FFF",
		--x"FFF",x"000",x"F00",x"F00",x"F00",x"000",x"000",x"FFF",
		--x"FFF",x"000",x"F00",x"000",x"F00",x"000",x"FFF",x"FFF",
		--x"FFF",x"000",x"000",x"000",x"000",x"000",x"FFF",x"FFF"

		--x"FFF",x"FFF",x"CC0",x"CC0",x"CC0",x"CC0",x"FFF",x"FFF",      -- PACMAN CURSOR
		--x"FFF",x"CC0",x"CC0",x"CC0",x"CC0",x"CC0",x"CC0",x"FFF",
		--x"CC0",x"CC0",x"CC0",x"FFF",x"F00",x"CC0",x"CC0",x"CC0",
		--x"CC0",x"CC0",x"CC0",x"FFF",x"FFF",x"CC0",x"CC0",x"FFF",
		--x"CC0",x"CC0",x"CC0",x"CC0",x"CC0",x"CC0",x"FFF",x"FFF",
		--x"CC0",x"CC0",x"CC0",x"CC0",x"CC0",x"CC0",x"CC0",x"CC0",
		--x"FFF",x"CC0",x"CC0",x"CC0",x"CC0",x"CC0",x"CC0",x"FFF",
		--x"FFF",x"FFF",x"CC0",x"CC0",x"CC0",x"CC0",x"FFF",x"FFF"
