-- VHDL Architecture for entity_name
-- which is part of the hobby project CHONK-RISC-V
-- Created by Ivar Lenner


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY entity_name IS

port (
		A : in bit_vector(4 downto 1);  
		Y : out bit 
    );

END ENTITY entity_name;

--- Beskrivning --- 
/*
Beskrivning? Länk till diagram?
*/

ARCHITECTURE architecture_name OF entity_name IS
BEGIN

    -- Behaviour should be a 4-input NOR-gate.

	Y <= A(4) or A(3) or A(2) or A(1);

END ARCHITECTURE architecture_name;
