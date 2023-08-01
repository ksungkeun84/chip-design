library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_foundation_arith.all;

entity DW01_decode_func is 
  generic(func_width : integer := 5);
  port( func_A:     in  std_logic_vector(func_width-1 downto 0);
        B_func_TC:  out std_logic_vector(2**func_width-1 downto 0);
        B_func_UNS: out std_logic_vector(2**func_width-1 downto 0);
        B_func:     out std_logic_vector(2**func_width-1 downto 0));
end DW01_decode_func;

architecture func of DW01_decode_func is
begin

  B_func_TC  <= std_logic_vector(DWF_decode (signed (func_A)));
  B_func_UNS <= std_logic_vector(DWF_decode (unsigned (func_A)));
  B_func     <= DWF_decode (func_A);
end func;

