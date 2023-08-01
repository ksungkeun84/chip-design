library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity  DW01_inc_oper is
  generic(wordlength: integer := 8);
  port(in1 : in STD_LOGIC_VECTOR(wordlength-1 downto 0);
       sum : out STD_LOGIC_VECTOR(wordlength-1 downto 0));
end DW01_inc_oper;

architecture oper of DW01_inc_oper is
  signal in_signed,sum_signed: SIGNED(wordlength-1 downto 0);
begin
  in_signed <= SIGNED(in1);

  -- infer the "+" addition operator
  sum_signed <= in_signed + 1;
  sum <= STD_LOGIC_VECTOR(sum_signed);
end oper;

