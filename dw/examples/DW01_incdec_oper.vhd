library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity  DW01_incdec_oper is
  generic(wordlength: integer := 8 );
  port(in1     : in STD_LOGIC_VECTOR(wordlength-1 downto 0);
       inc_dec : in STD_LOGIC;
       sum     : out STD_LOGIC_VECTOR(wordlength-1 downto 0) );
end DW01_incdec_oper;

architecture oper of DW01_incdec_oper is
  signal in_signed,sum_signed: SIGNED(wordlength-1 downto 0);
begin

  in_signed <= SIGNED(in1);
  process (in_signed, inc_dec)
  begin
    if (inc_dec = '1') then
      sum_signed <= in_signed - 1;
    else
      sum_signed <= in_signed + 1;
    end if;
  end process;
  sum <= STD_LOGIC_VECTOR(sum_signed);
end oper;

