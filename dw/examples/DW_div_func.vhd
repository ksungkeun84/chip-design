library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

entity DW_div_func is
  generic ( width : positive := 8);
  port ( a             : in  std_logic_vector(width-1 downto 0);
         b             : in  std_logic_vector(width-1 downto 0);
         quotient_uns  : out std_logic_vector(width-1 downto 0);
         quotient_tc   : out std_logic_vector(width-1 downto 0);
         remainder_uns : out std_logic_vector(width-1 downto 0);
         remainder_tc  : out std_logic_vector(width-1 downto 0);
         modulus_uns   : out std_logic_vector(width-1 downto 0);
         modulus_tc    : out std_logic_vector(width-1 downto 0));
end DW_div_func;

architecture func of DW_div_func is
begin
  -- function calls for unsigned/signed quotient, remainder and modulus
  quotient_uns  <= std_logic_vector(DWF_div (unsigned(a), unsigned(b)));
  quotient_tc   <= std_logic_vector(DWF_div (signed(a), signed(b)));
  remainder_uns <= std_logic_vector(DWF_rem (unsigned(a), unsigned(b)));
  remainder_tc  <= std_logic_vector(DWF_rem (signed(a), signed(b)));
  modulus_uns   <= std_logic_vector(DWF_mod (unsigned(a), unsigned(b)));
  modulus_tc    <= std_logic_vector(DWF_mod (signed(a), signed(b)));
end func;
