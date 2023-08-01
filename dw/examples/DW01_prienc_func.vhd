library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_foundation_arith.all;

entity DW01_prienc_func is
  generic(func_A_width : integer := 8;func_INDEX_width : integer := 4);
  port(func_A: in std_logic_vector(func_A_width-1 downto 0);
       INDEX_func,INDEX_func_TC,INDEX_func_UNS: out         std_logic_vector(func_INDEX_width-1 downto 0));
end DW01_prienc_func;

architecture func of DW01_prienc_func is
begin

  INDEX_func <= DWF_prienc(func_A,func_INDEX_width);
  INDEX_func_TC <= std_logic_vector(DWF_prienc(signed(func_A),
                                               func_INDEX_width));
  INDEX_func_UNS <= std_logic_vector(DWF_prienc(unsigned(func_A),
                                                func_INDEX_width));

end func;

