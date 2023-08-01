library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW02_sum_inst is
  generic ( inst_num_inputs  : NATURAL := 8;
            inst_input_width : NATURAL := 8 );
  port ( inst_INPUT : in std_logic_vector(inst_num_inputs*
                                          inst_input_width-1 downto 0);
         SUM_inst   : out std_logic_vector(inst_input_width-1 downto 0) );
end DW02_sum_inst;

architecture inst of DW02_sum_inst is
begin
  -- Instance of DW02_sum
  U1 : DW02_sum
    generic map ( num_inputs => inst_num_inputs, 
                  input_width => inst_input_width )
  port map ( INPUT => inst_INPUT,   SUM => SUM_inst );
end inst;

-- pragma translate_off
configuration DW02_sum_inst_cfg_inst of DW02_sum_inst is
  for inst
  end for; -- inst
end DW02_sum_inst_cfg_inst;
-- pragma translate_on

