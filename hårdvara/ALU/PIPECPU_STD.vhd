library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- För att importera i annan fil skriv:
--      library work;
--      use work.PIPECPU_STD.ALL;

package PIPECPU_STD is

    constant instruction_size   : integer :=  31; -- används som "n downto 0"
    constant std_word_msb       : integer :=  15; -- används som "n downto 0"
    constant std_reg_adrsize    : integer :=  4;  

end PIPECPU_STD;