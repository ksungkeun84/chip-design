library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity  DW01_sub_oper is
  generic(wordlength: integer := 8);
  port(in1,in2 : in STD_LOGIC_VECTOR(wordlength-1 downto 0);
      diff : out STD_LOGIC_VECTOR(wordlength-1 downto 0));
end DW01_sub_oper;

architecture oper of DW01_sub_oper is
  signal in1_signed, in2_signed, diff_signed: SIGNED(wordlength-1 downto 0);
begin
  in1_signed <= SIGNED(in1);
  in2_signed <= SIGNED(in2);
  -- infer the "-" subtraction operator
  diff_signed <= in1_signed - in2_signed;
  diff <= STD_LOGIC_VECTOR(diff_signed);
end oper;

