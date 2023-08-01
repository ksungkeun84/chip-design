library IEEE, DWARE;
use DWARE.DW_foundation_arith.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity DW02_mult_oper is
  generic(wordlength1, wordlength2: integer := 8);
  port(in1     : in std_logic_vector(wordlength1-1 downto 0);
       in2     : in std_logic_vector(wordlength2-1 downto 0);
       control : in std_logic;
       mult    : out std_logic_vector(wordlength1+wordlength2-1 downto 0) );
end DW02_mult_oper;

architecture func of DW02_mult_oper is
  signal mult_sig : SIGNED(wordlength1+wordlength2-1 downto 0) ;
  signal mult_usig : UNSIGNED(wordlength1+wordlength2-1 downto 0) ;
begin
  mult_sig <= SIGNED(in1) * SIGNED(in2);
  mult_usig <= UNSIGNED(in1) * UNSIGNED(in2);

  process (mult_sig,mult_usig, control)
  begin
    if control = '1' then
      mult <= std_logic_vector(mult_sig);
    else
      mult <= std_logic_vector(mult_usig);
    end if;
  end process;
end func;

