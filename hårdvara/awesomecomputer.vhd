library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--library work;
--use work.PIPECPU_STD.ALL;

entity AwesomeComputer is
	port (
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
end AwesomeComputer;

architecture Behavioral of AwesomeComputer is

    ------ KOMPONENTER --------
    component DM_comp is
	port(
        clk, rst : in std_logic; -- clk, reset button (active high)
		-- CPU-sida (läs/skriv)
        cpu_addr_imm : in std_logic_vector(15 downto 0); --omedelbar adress (k)
		cpu_addr_dir : in std_logic_vector(15 downto 0); -- indexerad adress (register)
        mux_addr_signal : in std_logic;
		cpu_din : in std_logic_vector(15 downto 0); -- data från RM
		cpu_we : in std_logic; -- write enable, precis som i RM måste denna hanteras i typ CU
		cpu_dout : out std_logic_vector(15 downto 0);
		-- VGA-sida (endast läs)
		vga_addr : in std_logic_vector(15 downto 0);
		vga_dout : out std_logic_vector(15 downto 0)
		);
    end component;        

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

	component VGA_comp is
	port(
        VM_data  : in std_logic_vector(15 downto 0);
        VM_addr  : out std_logic_vector(15 downto 0);
        clk      : in std_logic; -- clk, reset button (active high)
        clear    : in std_logic;
        vga_RGB  : out std_logic_vector(11 downto 0);
        Hsync    : out std_logic; -- horizontal sync
        Vsync    : out std_logic -- vertical sync
	);
    end component;        

    component KBD_comp is
    port(
        clk, rst : in std_logic; -- clk, reset button (active high)
        PS2KeyboardCLK  : in std_logic; 
        PS2KeyboardData : in std_logic; 
        key : out std_logic_vector(7 downto 0); 
        MAKE_op : out std_logic
    );
    end component;       
    
    signal VGA_RGB : std_logic_vector(11 downto 0); -- Signaler till VGA-skärm

    ---- Gemensam signal
    signal rst : std_logic;

    ---- Mellan DM och CPU
    signal dm_addr_imm : std_logic_vector(15 downto 0);
    signal dm_addr_dir : std_logic_vector(15 downto 0);
    signal DM_mux_addr : std_logic;
    signal dm_we : std_logic; -- write enable, precis som i RM måste denna hanteras i CU
    signal dm_input : std_logic_vector(15 downto 0);
    signal dm_output : std_logic_vector(15 downto 0);

    ---- Mellan VGA och DM
    signal vm_data : std_logic_vector(15 downto 0);
    signal vm_addr : std_logic_vector(15 downto 0);
	 
    ---- Mellan KBD och CPU
    signal keyboard_data : std_logic_vector(7 downto 0);
    signal keyboard_interrupt : std_logic;
      
begin

	U1 : DM_comp port map(
        clk => clk, 
        rst => rst,
        
        --- signaler delade med CPU
        cpu_addr_imm => dm_addr_imm,
        cpu_addr_dir => dm_addr_dir,
        mux_addr_signal => DM_mux_addr,
		cpu_din => dm_input,
		cpu_we => dm_we,
		cpu_dout => dm_output,

        --- signaler delade med VGA
		vga_addr => vm_addr,
		vga_dout => vm_data
    );

    U2 : pipeCPU_comp port map(
        clk => clk, 
        rst => rst,

        --- signaler delade med DM/VM
        dm_addr_imm => dm_addr_imm,
        dm_addr_dir => dm_addr_dir,
        DM_mux_addr => DM_mux_addr,
        memory_input=> dm_input,
        dm_we => dm_we,
        memory_output => dm_output,

        --- signaler delade med KBD
        keyboard_input => keyboard_data,
        keyboard_interrupt => keyboard_interrupt
    );
    
    U3 : VGA_comp port map(
        clk => clk, 
        clear => rst,

        --- mellan
        VM_data => vm_data,
        VM_addr => vm_addr,

        --- utåt
		vga_RGB => vga_RGB,
        Hsync => Hsync,
		Vsync => Vsync
    );

    U4 : KBD_comp port map(
        clk => clk, 
        rst => rst,

        --- mellan
        key => keyboard_data,
        MAKE_op => keyboard_interrupt,

        --- inåt
        PS2KeyboardCLK => PS2Clk, 
        PS2KeyboardData => PS2Data
    );

    rst <= btnc;

    vgaRed <= VGA_RGB(11 downto 8);     -- VGA red
    vgaGreen <= VGA_RGB(7 downto 4);     -- VGA green
    vgaBlue <= VGA_RGB(3 downto 0);     -- VGA blue

end architecture;
