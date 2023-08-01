library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation.all;
-- If using library std_logic_arith, comment line above and 
--  uncomment line below
-- use DWARE.DW_Foundation_arith.all;


entity DW_lsd_func is

  generic (
    func_a_width : POSITIVE := 8);
  
  port (
    func_a   : in  std_logic_vector(func_a_width-1 downto 0);
    enc_func : out std_logic_vector(bit_width(func_a_width)-1 downto 0);
    dec_func : out std_logic_vector(func_a_width-1 downto 0));

end DW_lsd_func;


architecture func of DW_lsd_func is

begin

    -- function inference of DW_lsd
    enc_func <= DWF_lsd_enc (func_a);
    dec_func <= DWF_lsd (func_a);

end func;


-- pragma translate_off
configuration DW_lsd_func_cfg_func of DW_lsd_func is
  for func
  end for;
end DW_lsd_func_cfg_func;
-- pragma translate_on

