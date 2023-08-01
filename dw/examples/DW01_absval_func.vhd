library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_foundation_arith.all;

entity DW01_absval_func is
  generic(width: integer:= 8);
  port( func_A : in std_logic_vector(width-1 downto 0);
        ABSVAL_func : out  std_logic_vector(width-1 downto 0) );
end DW01_absval_func;

architecture func of DW01_absval_func is
begin

  ABSVAL_func <= std_logic_vector(DWF_absval(SIGNED(func_A)));
end func;

