library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity DW01_cmp2_oper is
  generic(wordlength: integer:=8);
  port(in1, in2    : in STD_LOGIC_VECTOR(wordlength-1 downto 0);
       instruction : in STD_LOGIC;
       comparison  : out boolean);
end DW01_cmp2_oper;

architecture oper of DW01_cmp2_oper is
  signal in1_signed, in2_signed: SIGNED(wordlength-1 downto 0);
begin
  in1_signed <= SIGNED(in1);
  in2_signed <= SIGNED(in2);
  -- infer the non-equality comparison operators
  process (in1_signed, in2_signed, instruction)
  begin
    if (instruction = '0') then
      comparison <= in1_signed > in2_signed;
    else
      comparison <= in1_signed >= in2_signed;
    end if;
  end process;
end oper;
