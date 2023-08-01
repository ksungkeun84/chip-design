library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_foundation_arith.all;

entity DW04_par_gen_func is
  generic(func_width :integer:=8;   func_par_type: INTEGER := 1);
  port(func_data_in : in std_logic_vector(func_width-1 downto 0);
       parity_func  : out std_logic);
end DW04_par_gen_func;

architecture func of DW04_par_gen_func is
begin
  parity_func <= DWF_parity_gen(func_par_type, func_data_in);
end func;

