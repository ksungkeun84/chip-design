library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_arith.all;

entity DW_inc_gray_func is
  generic (func_width : positive := 8);
  port (func_a  : in  std_logic_vector(func_width-1 downto 0);
        func_ci : in  std_logic;
        z_func  : out std_logic_vector(func_width-1 downto 0));
end DW_inc_gray_func;

architecture func of DW_inc_gray_func is
begin
  -- function inference of DW_inc_gray
  z_func <= DWF_inc_gray (func_a, func_ci);
end func;

