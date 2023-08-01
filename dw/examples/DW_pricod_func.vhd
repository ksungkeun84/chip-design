library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation.all;
-- If using numeric types from std_logic_arith package,
-- comment the preceding line and uncomment the following line:
-- use DWARE.DW_Foundation_arith.all;

entity DW_pricod_func is

  generic (
    func_a_width : POSITIVE := 8);
  
  port (
    func_a   : in  std_logic_vector(func_a_width-1 downto 0);
    cod_func : out std_logic_vector(func_a_width-1 downto 0));

end DW_pricod_func;


architecture func of DW_pricod_func is

begin

  -- Function inference of DW_pricod
  cod_func <= DWF_pricod (func_a);

end func;


-- pragma translate_off
configuration DW_pricod_func_cfg_func of DW_pricod_func is
  for func
  end for;
end DW_pricod_func_cfg_func;
-- pragma translate_on

