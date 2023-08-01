library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_foundation_arith.all;

entity DW02_sum_func is
  generic(func_num_inputs, func_input_width: INTEGER :=8);
  port(func_INPUT   : in std_logic_vector(func_num_inputs * 
                                          func_input_width-1 downto 0);
       SUM_func_UNS : out std_logic_vector(func_input_width-1 downto 0);
       SUM_func_TC  : out std_logic_vector(func_input_width-1 downto 0) );
end DW02_sum_func;

architecture func of DW02_sum_func is
begin
  SUM_func_UNS <= std_logic_vector(DWF_sum(UNSIGNED(func_INPUT),
                                           func_num_inputs));
  SUM_func_TC  <= std_logic_vector(DWF_sum(SIGNED(func_INPUT),
                                           func_num_inputs));
end func;

