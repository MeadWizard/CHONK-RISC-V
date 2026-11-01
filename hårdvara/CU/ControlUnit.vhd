library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--library work;
--use work.PIPECPU_STD.ALL;

entity CU_comp is
	port (
		clk : in std_logic;
		IR0 : in unsigned(31 downto 0); -- det som kommer direkt från PM, relevans?
		IR1 : in unsigned(31 downto 0);
		IR2 : in unsigned(31 downto 0);		
		ALU_control_signals : out std_logic_vector(4 downto 0);
		RM_write_enable : out std_logic;
		DM_write_enable : out std_logic;
		DM_ALU_result_signal : out std_logic;
		DM_mux_addr : out std_logic 
	);
end CU_comp;

architecture Behavioral of CU_comp is

	alias IR0_op : unsigned(4 downto 0) is IR0(31 downto 27); 
	alias IR1_op : unsigned(4 downto 0) is IR1(31 downto 27); 
	alias IR2_op : unsigned(4 downto 0) is IR2(31 downto 27); 

	----- ADRESS MODES -----
	constant mode_DIR : std_logic := '0'; -- not immeadiate, take 2 registers
	constant mode_IMM : std_logic := '1'; -- immeadiate, take 1 register and k-value

	----- OPERATION CODES -----
	constant op_NOP : unsigned(3 downto 0) := x"0"; -- NOP
	
	constant op_LD : unsigned(3 downto 0) := x"1"; -- LOAD
	constant op_STO : unsigned(3 downto 0) := x"2"; -- STORE

	constant op_ADD : unsigned(3 downto 0) := x"3"; -- ADD
	constant op_SUB : unsigned(3 downto 0) := x"4"; -- SUB
	constant op_MUL : unsigned(3 downto 0) := x"5"; -- MUL			
	constant op_LSR : unsigned(3 downto 0) := x"6"; -- LSR
	constant op_AND : unsigned(3 downto 0) := x"7"; -- AND
	constant op_OR  : unsigned(3 downto 0) := x"8"; -- OR				
	constant op_NOT : unsigned(3 downto 0) := x"9"; -- NOT

	constant op_CMP : unsigned(3 downto 0) := x"A"; -- CMP
	constant op_BEQ : unsigned(3 downto 0) := x"B"; -- BEQ				
	constant op_BNE : unsigned(3 downto 0) := x"C"; -- BNE
	constant op_BRA : unsigned(3 downto 0) := x"D"; -- BRA
	constant op_BRIE: unsigned(3 downto 0) := x"E"; -- BRIE
	constant op_CLI : unsigned(3 downto 0) := x"F"; -- CLI

	constant op_LD_dir  : unsigned(4 downto 0) := "00001";
	constant op_LD_imm  : unsigned(4 downto 0) := "10001";
	constant op_STO_imm : unsigned(4 downto 0) := "10010";

	----- ALU CONTROL SIGNALS -----
	constant cNOP : std_logic_vector(3 downto 0) := "0000"; -- NOP
	constant cADD : std_logic_vector(3 downto 0) := "0001"; -- ADD, ADDI
	constant cSUB : std_logic_vector(3 downto 0) := "0010"; -- SUB, SUBI, CMP
	constant cMUL : std_logic_vector(3 downto 0) := "0011"; -- MUL, MULI
	constant cLSR : std_logic_vector(3 downto 0) := "0100"; -- LSR		
	constant cAND : std_logic_vector(3 downto 0) := "0101"; -- AND	
	constant cOR  : std_logic_vector(3 downto 0) := "0110"; -- OR	
	constant cNOT : std_logic_vector(3 downto 0) := "0111"; -- NOT

begin

	-- Alu-signaler, dvs: vilka instruktioner säger att vi ska göra någon matematisk operation typ
    with IR1_op(3 downto 0) select
		ALU_control_signals(3 downto 0) <= 	cADD when op_ADD,  
											cSUB when op_SUB,  
											cMUL when op_MUL,  
											cLSR when op_LSR, 	 
											cAND when op_AND,  
											cOR  when op_OR,
											cNOT when op_NOT,  
											cSUB when op_CMP, -- CMP ska göra samma som sub	 
											cADD when op_LD,
											cNOP when others;


	ALU_control_signals(4) <= IR1_op(4);

	-- Skriv-till-rm, dvs: vilka instruktioner säger att vi ska skriva till rm
	with IR2_op(3 downto 0) select
		RM_write_enable <= '1' when op_ADD,  
						   '1' when op_SUB,  
						   '1' when op_MUL,
						   '1' when op_LSR,
						   '1' when op_AND,
						   '1' when op_OR,  
						   '1' when op_NOT,
						   '1' when op_LD,
						   '0' when others;

	-- Skriv-till-dm, dvs: vilka instruktioner säger att vi ska skriva till dm
	-- process(clk)
	-- begin
	-- 	if rising_edge(clk) then
	-- 		if (IR2_op(3 downto 0) = op_STO) then
	-- 			DM_write_enable <= '1';
	-- 		else
	-- 			DM_write_enable <= '0';
	-- 		end if;
	-- 	end if;
	-- end process;
	
	-- dm_we hamnade 2 klockcykler för sent med den klockade processen ovanför, 
	-- nu hamnar den 1 klockcykel för sent
	-- kommer inte ihåg varför vi ändrade denna??
	with IR2_op(3 downto 0) select
		DM_write_enable <= '1' when op_STO,
						   '0' when others;

	with IR2_op(4 downto 0) select
		DM_mux_addr <= '1' when op_STO_imm,
					   '1' when op_LD_imm,
					   '0' when others;

	-- Resultatsignal, dvs: vad väljer vi att skriva in i registerminnet
	with IR2_op(4 downto 0) select
		DM_ALU_result_signal <= '1' when op_LD_dir,  
								'0' when op_LD_imm,
						   		'0' when others;

end architecture;