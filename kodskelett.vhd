-- VHDL Architecture for entity_name
-- which is part of the hobby project CHONK-RISC-V
-- Created by Ivar Lenner


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY entity_name IS

port (
		X : in bit;  
		Y : out bit 
    );

END ENTITY entity_name;

--- Beskrivning --- 
/*
Beskrivning? Länk till diagram?
*/

ARCHITECTURE architecture_name OF entity_name IS
BEGIN

    -- Kommentar
	Y <= X;

END ARCHITECTURE architecture_name;
