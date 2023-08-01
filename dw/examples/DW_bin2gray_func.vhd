library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_arith.all;

entity DW_bin2gray_func is
  generic (func_width : positive := 8);
  port (func_b : in  std_logic_vector(func_width-1 downto 0);
        g_func : out std_logic_vector(func_width-1 downto 0));
end DW_bin2gray_func;

architecture func of DW_bin2gray_func is
begin
  -- function inference of DW_bin2gray
  g_func <= DWF_bin2gray (func_b);
end func;
