library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity RM_comp is
	port(
		
		-------- IN --------
		key : in std_logic_vector(7 downto 0); -- indata
		keyboard_interrupt : in std_logic;

		IR1 : in unsigned(31 downto 0); -- read
		IR2 : in unsigned(31 downto 0); -- read
		data_in : in std_logic_vector(15 downto 0); -- read, muxad från DM och D2 (ALU)

		clk, rst : in std_logic;
		write_enable : in std_logic; -- för att kunna synka skrivningen till register, från CU

		-------- OUT -------
		regA_out : out std_logic_vector(15 downto 0);
		regB_out : out std_logic_vector(15 downto 0)
	);
end RM_comp;

architecture func of RM_comp is

	type RM_t is array(0 to 15) of unsigned(15 downto 0);
	
	constant RM_c : RM_t := (
		X"0000",	-- konstant noll
		X"0000",	-- uhghhh
		X"0000",	-- dummy
		X"0000",	-- dummy
		X"0000",	-- dummy
		X"0000", 	-- dummy 
		X"0000",	-- dummy
		X"0000",	-- dummy
		X"0000",	-- dummy
		X"0000",	-- dummy
		X"0000",	-- dummy
		X"0000",	-- dummy
		X"0000",	-- dummy
		X"0000",	-- dummy
		X"0000",	-- dummy
		X"0000",	-- Här läggs ps2 ALLTID
		others => (others => '0')
	);
	
	signal RM : RM_t := RM_c;

begin

	-- Synkad skrivning till register
	process(clk)
	begin
		
		if rising_edge(clk) then
			
			if (rst = '1') then
				RM <= RM_c;

			elsif write_enable = '1' then -- write_enable ska uppdateras i typ CU

				-- ska inte skriva till r15 (reserverad för ps2) eller r0 (konstant 0)
				--if ((to_integer(IR2(18 downto 15)) not 15) and (to_integer(IR2(18 downto 15)) not 0)) then
				
				if (not ((IR2(26 downto 23) = "0000") or (IR2(26 downto 23) = "1111"))) then

					RM(to_integer(IR2(26 downto 23))) <= unsigned(data_in); -- D , får inte skriva till x"F" eller sista registret

				end if;
			
			end if;
			
			if keyboard_interrupt = '1' then

				RM(15) <= X"00" & unsigned(key); -- PS2 inmatning skrivs alltid till r15
			
			end if;
		
		end if;	
	end process;

	-- Läsning av register, två utgångar
	regA_out <= std_logic_vector(RM(to_integer(IR1(22 downto 19)))); -- Beroende på vilken del av intruktion som pekar ut A
	regB_out <= std_logic_vector(RM(to_integer(IR1(18 downto 15)))); -- B


end architecture;
