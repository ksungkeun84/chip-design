library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

entity DW_div_sat_func is
  generic (width : positive := 8);
  port (a            : in  std_logic_vector(2*width-1 downto 0);
        b            : in  std_logic_vector(width-1 downto 0);
        quotient_uns : out std_logic_vector(width-1 downto 0);
        quotient_tc  : out std_logic_vector(width-1 downto 0));
end DW_div_sat_func;

architecture func of DW_div_sat_func is
begin
  -- function calls for unsigned/signed quotient
  quotient_uns <= std_logic_vector(
    DWF_div_sat (unsigned(a), unsigned(b), width));
  quotient_tc  <= std_logic_vector(
    DWF_div_sat (signed(a), signed(b), width));
end func;
