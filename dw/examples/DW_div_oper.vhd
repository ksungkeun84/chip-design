library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

entity DW_div_oper is
  generic ( width : positive := 8);
  port ( a             : in  std_logic_vector(width-1 downto 0);
         b             : in  std_logic_vector(width-1 downto 0);
         quotient_uns  : out std_logic_vector(width-1 downto 0);
         quotient_tc   : out std_logic_vector(width-1 downto 0);
         remainder_uns : out std_logic_vector(width-1 downto 0);
         remainder_tc  : out std_logic_vector(width-1 downto 0);
         modulus_uns   : out std_logic_vector(width-1 downto 0);
         modulus_tc    : out std_logic_vector(width-1 downto 0));
end DW_div_oper;

architecture oper of DW_div_oper is
begin

  -- operators for unsigned/signed quotient, remainder and modulus
  quotient_uns  <= unsigned(a) / unsigned(b);
  quotient_tc   <= signed(a) / signed(b);
  remainder_uns <= unsigned(a) rem unsigned(b);
  remainder_tc  <= signed(a) rem signed(b);
  modulus_uns   <= unsigned(a) mod unsigned(b);
  modulus_tc    <= signed(a) mod signed(b);

end oper;

