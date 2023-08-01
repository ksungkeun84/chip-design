library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_arith.all;

entity DW_gray2bin_func is
  generic (func_width : positive := 8);
  port (func_g : in  std_logic_vector(func_width-1 downto 0);
        b_func : out std_logic_vector(func_width-1 downto 0));
end DW_gray2bin_func;

architecture func of DW_gray2bin_func is
begin
  -- function inference of DW_gray2bin
  b_func <= DWF_gray2bin (func_g);
end func;

