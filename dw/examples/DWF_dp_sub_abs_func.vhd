library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use DWARE.DW_dp_functions.all;
-- DWARE.DW_dp_functions_arith package if IEEE.std_logic_arith is used

entity DWF_dp_sub_abs_test is
  port (a, b, c, d : in  signed(7 downto 0);
        z          : out signed(15 downto 0));
end DWF_dp_sub_abs_test;

architecture rtl of DWF_dp_sub_abs_test is
begin
  z <= DWF_dp_sub_abs (a * b, c) + d;
end rtl;
