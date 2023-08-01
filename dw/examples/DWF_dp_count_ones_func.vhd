library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use DWARE.DW_dp_functions.all;
-- DWARE.DW_dp_functions_arith package if IEEE.std_logic_arith is used

entity DWF_dp_count_ones_test is
  port (a : in  unsigned(7 downto 0);
        b : in  unsigned(3 downto 0);
        z : out std_logic);
end DWF_dp_count_ones_test;

architecture rtl of DWF_dp_count_ones_test is
begin
  z <= '1' when (DWF_dp_count_ones (a) >= b) else '0';
end rtl;
