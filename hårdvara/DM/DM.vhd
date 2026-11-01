library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--library work;
--use work.PIPECPU_STD.ALL;

entity DM_comp is
	port(
		clk, rst : in std_logic; -- clk, reset button (active high)
		-- CPU-sida (läs/skriv)
        cpu_addr_imm : in std_logic_vector(15 downto 0); --omedelbar adress (k)
		cpu_addr_dir : in std_logic_vector(15 downto 0); -- indexerad adress (register)
		mux_addr_signal : in std_logic;
		cpu_din : in std_logic_vector(15 downto 0); -- data från RM (in i Z2) (register)
		cpu_we : in std_logic; -- write enable, precis som i RM måste denna hanteras i typ CU
		cpu_dout : out std_logic_vector(15 downto 0);

		-- VGA-sida (endast läs)
		vga_addr : in std_logic_vector(15 downto 0);
		vga_dout : out std_logic_vector(15 downto 0)
	);
end DM_comp;

architecture Behavioral of DM_comp is

	type DM_t is array(0 to 511) of std_logic_vector(15 downto 0);

	constant DM_c : DM_t := (
		
		-- 3 + 8 + 4
		
		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",	X"0000", X"0000",	 
		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",	 

		X"0000", X"0000", X"0000", X"0005",	X"0006", X"0007", X"0008", X"0000", X"0000", X"0000",	 
		X"0009", X"0005", X"000A", X"000B", X"0007", X"0008", X"0000", X"0000", X"0000", X"0000",	 

		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",	X"0000", X"0000",	 
		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",
		
		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0001", X"0001",	X"0001", X"0001",	 
		X"0001", X"0001", X"0001", X"0001", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 

		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0001", X"0001",	X"0001", X"0001",	 
		X"0001", X"0001", X"0001", X"0001", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 

		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0001", X"0001",	X"0001", X"0001",	 
		X"0001", X"0001", X"0001", X"0001", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 

		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0001", X"0001",	X"0001", X"0002",	 
		X"0003", X"0001", X"0001", X"0001", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 

		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0001", X"0001",	X"0001", X"0003",	 
		X"0002", X"0001", X"0001", X"0001", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 

		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0001", X"0001",	X"0001", X"0001",	 
		X"0001", X"0001", X"0001", X"0001", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 

		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0001", X"0001",	X"0001", X"0001",	 
		X"0001", X"0001", X"0001", X"0001", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 

		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0001", X"0001",	X"0001", X"0001",	 
		X"0001", X"0001", X"0001", X"0001", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", 

		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",	X"0000", X"0000",	 
		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",	 
		
		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",	X"0000", X"0000",	 
		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",	 

		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",	X"0000", X"0000",	 
		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",	 

		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",	X"0000", X"0000",	 
		X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000", X"0000",	 

		-- reservera 300 rader för skärmen varav 64 rader är för spelbrädet
		-- de 300 raderna är det man kan tänka sig är videominnet
		
		others => X"0001"
		--others => (others => '0')
	);
	
	signal cpu_addr : std_logic_vector(15 downto 0);
	
	signal DM : DM_t := DM_c;

	signal Z2 : std_logic_vector (15 downto 0); -- ska uppdateras synkront med data från RM

	signal Z2b : std_logic_vector (15 downto 0); -- ska uppdateras synkront med data från RM

begin

	--------------- CPU --------------

	-- Läs data till Z2
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				Z2b <= (others => '0');
			else
				Z2b <= cpu_addr_dir;
			end if;
		end if;
	end process;

	with mux_addr_signal select
		cpu_addr <= cpu_addr_imm when '1',
					Z2b when others;

	-- Läs data till Z2
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				Z2 <= (others => '0');
			else
				Z2 <= cpu_din;
			end if;
		end if;
	end process;

	--Skriv till DM
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				DM <= DM_C;
			elsif cpu_we = '1' then
				DM(to_integer(unsigned(cpu_addr(8 downto 0)))) <= Z2;
			end if;
		end if;
	end process;

	--DM(to_integer(unsigned(cpu_addr(8 downto 0)))) <= Z2 when cpu_we = '1'; -- ???
														  

	--Läs till CPU
	cpu_dout <= DM(to_integer(unsigned(cpu_addr(8 downto 0)))); -- antal bitar?, muxen efter ej inkluderad

	--------------- VGA --------------

	vga_dout <= DM(to_integer(unsigned(vga_addr(8 downto 0))));
	
	-- ha med Z2, ska va klockad, innehåller det som ska läggas in i DM
	-- ControlUnit pekar ut vart det ska skrivas i DM?
	-- XY-to-index loopar konstant igenom innehållet, vi vill göra det när vi ska skicka till VGA skärmen
	-- skickar ut vart vi vill läsa för VGA delens skulls
	-- XY skriver vi i vga-motorn!

end architecture;