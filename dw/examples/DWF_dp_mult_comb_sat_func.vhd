library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use DWARE.DW_dp_functions.all;
-- DWARE.DW_dp_functions_arith package if IEEE.std_logic_arith is used

entity DWF_dp_mult_comb_sat_test is
  port (a, b, c    : in  unsigned(7 downto 0);
        a_tc, b_tc : in  std_logic;
        z          : out unsigned(7 downto 0));
end DWF_dp_mult_comb_sat_test;

architecture rtl of DWF_dp_mult_comb_sat_test is
begin
  z <= DWF_dp_mult_comb_sat (a, a_tc, b, b_tc, 8) + c;
end rtl;
