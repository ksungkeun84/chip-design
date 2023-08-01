library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use DWARE.DW_dp_functions.all;
-- DWARE.DW_dp_functions_arith package if IEEE.std_logic_arith is used

entity DWF_dp_simd_add_test is
  port (op1, op2  : in  signed(31 downto 0);
        config_no : in  std_logic_vector(1 downto 0);
        sum       : out signed(31 downto 0));
end DWF_dp_simd_add_test;

architecture rtl of DWF_dp_simd_add_test is
begin
  sum <= DWF_dp_simd_add (a => op1, b => op2, 
                          no_confs => 3, conf => config_no);
end rtl;
