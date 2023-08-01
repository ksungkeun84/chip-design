library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_foundation_arith.all;

entity DW02_mac_func is
  generic(wordlength1 : integer:=8; wordlength2: integer := 8);
  port(func_A   : in std_logic_vector(wordlength1-1 downto 0);
       func_B   : in std_logic_vector(wordlength2-1 downto 0);
       func_C   : in std_logic_vector(wordlength1+wordlength2-1 downto 0);
       func_TC  : in std_logic;
       MAC_func : out std_logic_vector(wordlength1+wordlength2-1 downto 0) );
end DW02_mac_func;

architecture func of DW02_mac_func is
begin

  process (func_A,func_B,func_C, func_TC)
  begin
    if func_TC = '1'  then
      MAC_func <= std_logic_vector(DWF_mac(SIGNED(func_A), 
                                   SIGNED(func_B), SIGNED(func_C)) );
    else
      MAC_func <= std_logic_vector(DWF_mac(UNSIGNED(func_A), 
                                   UNSIGNED(func_B), UNSIGNED(func_C)) );
    end if;
  end process;
end func;

