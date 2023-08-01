library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use DWARE.DW_dp_functions.all;
-- DWARE.DW_dp_functions_arith package if IEEE.std_logic_arith is used

entity DWF_dp_blend_test is
  port (x_pict, y_pict         : in  unsigned(15 downto 0);
        x_text, y_text, z_text : in  unsigned(15 downto 0);
        alpha                  : in  unsigned( 7 downto 0);
        z                      : out unsigned(15 downto 0));
end DWF_dp_blend_test;

architecture rtl of DWF_dp_blend_test is
begin
  z <= DWF_dp_blend (x_pict + x_text, y_pict + y_text, alpha) + z_text;
end rtl;
