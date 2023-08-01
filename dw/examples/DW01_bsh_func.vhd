library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_foundation_arith.all;

entity DW01_bsh_func is
  generic(func_A_width : integer:=8; func_SH_width : integer :=3);
  port(func_A: in std_logic_vector(func_A_width-1 downto 0);
       func_SH: in std_logic_vector(func_SH_width-1 downto 0);
       B_func_TC: out std_logic_vector(func_A_width-1 downto 0);
       B_func_UNS: out std_logic_vector(func_A_width-1 downto 0));
end DW01_bsh_func;

architecture func of DW01_bsh_func is
begin
  B_func_TC <= std_logic_vector(DWF_bsh(SIGNED(func_A),
                                UNSIGNED(func_SH)));
  B_func_UNS <= std_logic_vector(DWF_bsh(UNSIGNED(func_A),
                                UNSIGNED(func_SH)));
end func;

