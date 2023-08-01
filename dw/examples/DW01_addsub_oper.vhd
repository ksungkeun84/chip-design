library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity  DW01_addsub_oper is
  generic(wordlength: integer := 8);
  port(in1, in2 : in STD_LOGIC_VECTOR(wordlength-1 downto 0);
       ctl      : in STD_LOGIC;
       sum      : out STD_LOGIC_VECTOR(wordlength-1 downto 0));
end DW01_addsub_oper;

architecture oper of DW01_addsub_oper is
  signal in1_signed, in2_signed, sum_signed: SIGNED(wordlength-1 downto 0);
begin
  in1_signed <= SIGNED(in1);
  in2_signed <= SIGNED(in2);
  process (in1_signed, in2_signed, ctl)
  begin
    if (ctl = '0') then
      sum_signed <= in1_signed + in2_signed;
    else
      sum_signed <= in1_signed - in2_signed;
    end if;
  end process;
  sum <= STD_LOGIC_VECTOR(sum_signed);
end oper;

