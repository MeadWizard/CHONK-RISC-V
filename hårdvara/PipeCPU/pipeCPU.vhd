library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--library work;
--use work.PIPECPU_STD.ALL;

entity pipeCPU_comp is
	port (
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
end pipeCPU_comp;

architecture func of pipeCPU_comp is
	
	signal IR1  : unsigned(31 downto 0);
	alias IR1_op: unsigned(4 downto 0) is IR1(31 downto 27);
	alias IR1_R : unsigned(3 downto 0) is IR1(26 downto 23);
	alias IR1_A : unsigned(3 downto 0) is IR1(22 downto 19);
	alias IR1_B : unsigned(3 downto 0) is IR1(18 downto 15);
	alias IR1_k : unsigned(15 downto 0) is IR1(15 downto 0);

	signal IR2  : unsigned(31 downto 0);
	alias IR2_op: unsigned(4 downto 0) is IR2(31 downto 27);
	alias IR2_R : unsigned(3 downto 0) is IR2(26 downto 23);
	alias IR2_A : unsigned(3 downto 0) is IR2(22 downto 19);
	alias IR2_B : unsigned(3 downto 0) is IR2(18 downto 15);
	alias IR2_k : unsigned(15 downto 0) is IR2(15 downto 0);

	signal PC, PC1, PC2 : unsigned(10 downto 0);

	-- Programminne
	signal PMdata_out : unsigned(31 downto 0);
	signal pm_addr : unsigned(8 downto 0);

	-- Registerminne
	signal RM_data_in : std_logic_vector(15 downto 0); -- read, muxad från DM och D2 (ALU)
	signal RM_write_enable : std_logic; -- för att kunna synka skrivningen till register, från CU
	
	-- ALU
	signal regA_out : std_logic_vector(15 downto 0);
	signal regB_out : std_logic_vector(15 downto 0);
	signal digitC : std_logic_vector(15 downto 0);
	-- Statusregister
	signal flag_Z, flag_N, flag_C, flag_V, flag_I : std_logic := '0';
	signal alu_Z, alu_N, alu_C, alu_V : std_logic;

	-- kontrollenhet
	signal alu_control_signals : std_logic_vector(4 downto 0);
	signal cu_result_signal : std_logic;

	-- pipeCPU hoppvariabel
	signal jump_condition1 : std_logic;
	signal jump_condition2 : std_logic;

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

	-- konstanter
	constant zero : std_logic_vector(15 downto 0) := X"0000";

	constant iNOP : unsigned(4 downto 0) :=   "00000";
	constant iBEQ 	: unsigned(4 downto 0) := "01011"; -- jump instruktionskod
	constant iBNE 	: unsigned(4 downto 0) := "01100"; -- branch if flag z 0 
	constant iBRA 	: unsigned(4 downto 0) := "01101"; -- branch if flag z 1
	constant iBRIE 	: unsigned(4 downto 0) := "01110"; -- branch if flag i 1
	constant iCLI 	: unsigned(4 downto 0) := "01111"; -- 


	-- D2

	signal D2 : std_logic_vector(15 downto 0) := x"0000";

    component PM_comp is
	port(
		addr : in unsigned(8 downto 0); -- = 512 instruktioner
		data_out : out unsigned(31 downto 0) -- 32 bitars instruktioner
	);
    end component;        

	component RM_comp is
	port(
        -------- IN --------
		key : in std_logic_vector(7 downto 0); -- write
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
    end component;        

	component CU_comp is
	port(
		clk : in std_logic;
		IR0 : in unsigned(31 downto 0); -- direkt från PM, relevans?		
		IR1 : in unsigned(31 downto 0);		
		IR2 : in unsigned(31 downto 0);		
		ALU_control_signals : out std_logic_vector(4 downto 0);
		RM_write_enable : out std_logic;
		DM_write_enable : out std_logic;
		DM_ALU_result_signal : out std_logic;
		DM_mux_addr : out std_logic 
	);
    end component;   
	
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

		

begin
  
    U1 : PM_comp port map( -- Mappa minnen till andra signaler
        addr => pm_addr,
		data_out => PMdata_out
    );        

	U2 : RM_comp port map(
        key => keyboard_input, -- write
		keyboard_interrupt => keyboard_interrupt,
		IR1 => IR1, -- read
		IR2 => IR2, -- read
		data_in => RM_data_in, -- read, muxad från DM och D2 (ALU)
		clk => clk,
		rst => rst,
		write_enable => RM_write_enable, -- för att kunna synka skrivningen till register, från CU
		regA_out => regA_out,
		regB_out => regB_out
    );    

	U3 : CU_comp port map(
		clk => clk,
        IR0 => PMdata_out,	
		IR1 => IR1,		
		IR2 => IR2,	
		ALU_control_signals => alu_control_signals, 
		RM_write_enable => RM_write_enable, --------------------------------------
		DM_write_enable => dm_we,
		DM_ALU_result_signal => cu_result_signal,
		DM_mux_addr => DM_mux_addr
    );  
	
	U4 : ALU_comp port map(
		clk => clk,
		regA => regA_out,
		regB => regB_out,
		digitC => digitC,
		rst => rst,
		
		control_signals => alu_control_signals,
		-- genererar styrsignaler 
		-- (a och b eller a och c) 
		-- add sub mul eller lsl lsr
		
		Z => alu_Z, -- 1 då resultatet är 0
		N => alu_N,-- 1 då msb = 1
		V => alu_V, -- 1 vid overflow
		C => alu_C, -- 1 vid carry

		D2 => D2
	);  
	
	----- adress till DM -----
	dm_addr_imm <= std_logic_vector(IR2_k);
	dm_addr_dir <= regB_out;
	memory_input <= regA_out;

	----- digitC-grabber -----
	digitC <= std_logic_vector(IR1_k);

	----- Resultat MUX -----
	with cu_result_signal select
		RM_data_in 	<= memory_output when '1',
					   D2 when '0',
				       zero when others;

	----- Statusregister -----
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				flag_Z <= '0';
				flag_N <='0';
				flag_C <= '0';
				flag_V <= '0';
			elsif (IR1_op(3 downto 0) = op_ADD or
				   IR1_op(3 downto 0) = op_SUB or 
				   IR1_op(3 downto 0) = op_MUL or
				   IR1_op(3 downto 0) = op_LSR or	 
				   IR1_op(3 downto 0) = op_AND or
				   IR1_op(3 downto 0) = op_OR or 
				   IR1_op(3 downto 0) = op_NOT or
				   IR1_op(3 downto 0) = op_CMP) then
					flag_Z <= alu_Z;
					flag_N <= alu_N;
					flag_C <= alu_C;
					flag_V <= alu_V;
			
			end if;
		end if;
	end process;


	
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then 
				flag_I <= '0';
			elsif (keyboard_interrupt = '1') then
				flag_I <= '1';
			elsif (IR1_op = iCLI) then
				flag_I <= '0';
			end if;
		end if;
	end process;

	jump_condition1 <= '1' when ((IR1_op = iBRA) or 
							   (IR1_op = iBEQ and flag_Z = '1') or 
							   (IR1_op = iBNE and flag_Z = '0') or 
	 						   (IR1_op = iBRIE and flag_I = '1')) else '0';

	jump_condition2 <= '1' when ((IR2_op = iBRA) or 
								(IR2_op = iBEQ and flag_Z = '1') or 
								(IR2_op = iBNE and flag_Z = '0') or 
								(IR2_op = iBRIE and flag_I = '1')) else '0';

	

	-------- 2-stegs pipeline (given kod, men behöver ändras) ----------

    process(clk)
	begin -- PC
		if rising_edge(clk) then
			if (rst='1') then
				PC <= (others => '0');
			
			elsif (jump_condition2 = '1') then -- vid hopp, hoppar den till PC2
				PC <= PC2;
			else
				PC <= PC + 1;
		
			end if;
		end if;
	end process;	

	pm_addr <= PC(8 downto 0); -- uppdatera minnesadress

	process(clk)
	begin -- PC1 uppdatering
		if rising_edge(clk) then
			if (rst='1') then
				PC1 <= (others => '0');

			else
				PC1 <= PC; -- sparar PC
			
			end if;
		end if;
	end process;	

	process(clk)
	begin -- PC2 uppdatering
		if rising_edge(clk) then
			if (rst='1') then
				PC2 <= (others => '0');
				
			else
				PC2 <= IR1_k(10 downto 0); -- beräknar ny hoppadress
				--PC2 <= (others => '1');

			end if;
		end if;
	end process;	

	process(clk)
	begin -- uppdatera IR1
		if rising_edge(clk) then
			if (rst='1') then
				IR1 <= (others => '0');

			elsif (jump_condition1 = '1' or jump_condition2 = '1') then 
				IR1 <= (others => '0');
			else
				IR1 <= PMdata_out(31 downto 0);
			
			end if;
		end if;
	end process;

	process(clk)
	begin -- uppdatera IR2
		if rising_edge(clk) then
			if (rst='1') then
				IR2 <= (others => '0');
			
			else
				IR2 <= IR1;
			
			end if;
		end if;
	end process;

end architecture;
