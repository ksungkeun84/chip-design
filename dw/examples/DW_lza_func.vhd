library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation.all;
-- If using numeric_std data types of std_logic_arith, uncomment the 
-- following line:
-- use DWARE.DW_Foundation_arith.all;

entity DW_lza_func is
  generic (
    func_width : POSITIVE := 8
    );
  port (
    func_a : in std_logic_vector(func_width-1 downto 0);
    func_b : in std_logic_vector(func_width-1 downto 0);
    count_func : out std_logic_vector(bit_width(func_width)-1 downto 0)
    );
  end DW_lza_func;

architecture func of DW_lza_func is
begin
  -- Inferred function of DW_lza
  count_func <= DWF_lza(func_a,func_b);
end func;

-- pragma translate_off
configuration DW_lza_func_cfg_func of DW_lza_func is
for func
end for; -- func
end DW_lza_func_cfg_func;
-- pragma translate_on
