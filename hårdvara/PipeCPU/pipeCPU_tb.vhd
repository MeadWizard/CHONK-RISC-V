library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--library work;
--use work.PIPECPU_STD.all;

entity pipeCPU_tb is
end pipeCPU_tb;

architecture sim of pipeCPU_tb is

	component pipeCPU_comp is
		port(
			
			clk : in std_logic;
			rst : in std_logic;     -- reset button, active high
			
			--- signaler till och från DM/VM
			dm_addr_imm : out std_logic_vector(15 downto 0);
			dm_addr_dir : out std_logic_vector(15 downto 0);
			DM_mux_addr : out std_logic; 
			memory_input : out std_logic_vector(15 downto 0);
			dm_we : out std_logic;
			memory_output : in std_logic_vector(15 downto 0);
			
			--- signaler från med KBD
			keyboard_input : in std_logic_vector(7 downto 0);
			keyboard_interrupt : in std_logic

			
			);
	end component;

	--- Insignaler
	signal clk : std_logic;
	signal rst : std_logic;
	signal memory_output : std_logic_vector(15 downto 0);
	signal keyboard_input : std_logic_vector(7 downto 0);
	signal keyboard_interrupt : std_logic;

	--- Utsignaler
	signal dm_addr_imm : std_logic_vector(15 downto 0);
	signal dm_addr_dir : std_logic_vector(15 downto 0);
	signal DM_mux_addr : std_logic; 
	signal memory_input : std_logic_vector(15 downto 0);
	signal dm_we : std_logic;
	
begin

	UUT : pipeCPU_comp port map(
		clk => clk, 
        rst => rst,

        --- signaler delade med DM/VM
        dm_addr_imm => dm_addr_imm,
        dm_addr_dir => dm_addr_dir,
        DM_mux_addr => DM_mux_addr,
        memory_input => memory_input,
        dm_we => dm_we,
        memory_output => memory_output,

        --- signaler delade med KBD
        keyboard_input => keyboard_input,
        keyboard_interrupt => keyboard_interrupt
	);
	
	process
	begin
	
		for i in 0 to 450 loop
			clk <= '0';
			wait for 5 ns;
			clk <= '1';
			wait for 5 ns;
		end loop;
		
		wait; -- wait forever, will finish simulation
	end process;
	
	rst <= '1', '0' after 17 ns;
	keyboard_input <= X"CF", X"23" after 30 ns;
	keyboard_interrupt <= '0', '1' after 30 ns, '0' after 60 ns;

end architecture;
