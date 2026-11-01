library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RM_tb is
end RM_tb;

architecture sim of RM_tb is

    component RM_comp is
        port(

            -------- IN --------
            key : in std_logic_vector(7 downto 0); -- indata
            keyboard_interrupt : in std_logic;
		
		    IR1 : in unsigned(31 downto 0); -- read
            IR2 : in unsigned(31 downto 0); -- read
            data_in : in unsigned(15 downto 0); -- read, muxad från DM och D2 (ALU)

            clk : in std_logic;
            write_enable : in std_logic; -- för att kunna synka skrivningen till register, från CU

            -------- OUT -------
            regA_out : out unsigned(15 downto 0);
            regB_out : out unsigned(15 downto 0)

        );
    end component;

    signal tb_PS2 : std_logic_vector(7 downto 0);
    signal tb_kbd_interrupt : std_logic;

    signal tb_IR1 : unsigned(31 downto 0);
    signal tb_IR2 : unsigned(31 downto 0);
    signal tb_din : unsigned(15 downto 0);

    signal tb_clk : std_logic;
    signal tb_we : std_logic;

    signal tb_regA_out : unsigned(15 downto 0);
    signal tb_regB_out : unsigned(15 downto 0);

begin

    UUT : RM_comp port map (
        key => tb_PS2,
        keyboard_interrupt => tb_kbd_interrupt,

        IR1 => tb_IR1,
        IR2 => tb_IR2,
        data_in => tb_din,
        
        clk => tb_clk,
        write_enable => tb_we,
        
        regA_out => tb_regA_out,
        regB_out => tb_regB_out
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

        --tb_rst <= '1';
		--wait for 2 ns;
		--tb_rst <= '0';

		----- TEST 1 -----

		report "Test 1" severity note;

        -- testar att skriva till r8
        
        tb_ps2 <= "00000000";
		tb_IR1 <= "00000" & "0110" & "0111" & "0000" & "000000000000000";
		tb_IR2 <= "00000" & "0000" & "0000" & "1000" & "000000000000000";
    	tb_din <= X"2222"; -- på plats 8 
		tb_we <= '1';

    	wait until rising_edge(tb_clk);
    	wait for 1 ns;
		assert (
            tb_regA_out = X"0000" and
            tb_regB_out = X"0000"
    	)
        severity error;

        ----- TEST 2 -----
        
        -- testar att skriva till r6 och läs r8

		report "Test 2" severity note;
        
        tb_ps2 <= "00000000";
		tb_IR1 <= "00000" & "1000" & "1000" & "0000" & "000000000000000";
		tb_IR2 <= "00000" & "0000" & "0000" & "0110" & "000000000000000";
    	tb_din <= X"1111"; -- på plats 6
		tb_we <= '1';

    	wait until rising_edge(tb_clk);
    	wait for 1 ns;
		assert (
            tb_regA_out = X"2222" and
            tb_regB_out = X"2222"
    	)
    	report "Test 2 FAILED."
    	severity error;

        ----- TEST 3 -----

        report "Test 3" severity note;
        -- testa att skriva till r0 och läsa r6

        tb_ps2 <= "00000000"; -- skit i nu
		tb_IR1 <= "00000" & "0110" & "0110" & "0000" & "000000000000000";
		tb_IR2 <= "00000" & "0000" & "0000" & "0000" & "000000000000000";
    	tb_din <= X"1111"; -- på plats 6
		tb_we <= '1';

    	wait until rising_edge(tb_clk);
    	wait for 1 ns;
		assert (
            tb_regA_out = X"1111" and
            tb_regB_out = X"1111"
    	)
    	report "Test 3 FAILED."
    	severity error;

        ------ Test 4 ------

        -- testar att läsa r0, så att det alltid är 0

        report "Test 4" severity note;

        tb_ps2 <= "00000000"; -- skit i nu
		tb_IR1 <= "00000" & "0000" & "0000" & "0000" & "000000000000000";
		tb_IR2 <= "00000" & "0000" & "0000" & "0000" & "000000000000000";
    	tb_din <= X"0000"; 
		tb_we <= '0';

    	wait until rising_edge(tb_clk);
    	wait for 1 ns;
		assert (
            tb_regA_out = X"0000" and
            tb_regB_out = X"0000"
    	)
    	report "Test 4 FAILED."
    	severity error;

        wait; -- wait forever, will finish simulation
    end process;

    -- skriv fler tester för t.ex. att försöka skriva och läsa samtidigt

end architecture;