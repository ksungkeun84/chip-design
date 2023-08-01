library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_arith.all;

entity DW_square_func is
  generic ( func_width : NATURAL := 8 );
  port ( func_a      : in std_logic_vector(func_width-1 downto 0);
         func_tc     : in std_logic;
         square_func : out std_logic_vector((2*func_width)-1 downto 0) );
end DW_square_func;

architecture func of DW_square_func is
begin

  -- Functional inference of DW_square
  process (func_a, func_tc)
  begin
    if (func_tc = '0') then
      square_func <= std_logic_vector(DWF_square(unsigned(func_a)) );
    else
      square_func <= std_logic_vector(DWF_square(signed(func_a)) );
    end if;
  end process;
end func;

