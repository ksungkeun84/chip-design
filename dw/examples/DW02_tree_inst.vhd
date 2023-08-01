library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW02_tree_inst is
      generic (
	    inst_num_inputs : POSITIVE := 8;
	    inst_input_width : POSITIVE := 8;
	    inst_verif_en : INTEGER := 1); -- level 1 is the most aggressive
                                           -- verification mode for simulation
      port (
	    inst_INPUT : in std_logic_vector(inst_num_inputs*
                                             inst_input_width-1 downto 0);
	    OUT0_inst : out std_logic_vector(inst_input_width-1 downto 0);
	    OUT1_inst : out std_logic_vector(inst_input_width-1 downto 0));
    end DW02_tree_inst;


architecture inst of DW02_tree_inst is
begin
    -- Instance of DW02_tree
    U1 : DW02_tree
	generic map ( num_inputs => inst_num_inputs, 
                      input_width => inst_input_width, 
                      verif_en => inst_verif_en )
	port map ( INPUT => inst_INPUT, OUT0 => OUT0_inst, OUT1 => OUT1_inst );
end inst;

-- pragma translate_off
configuration DW02_tree_inst_cfg_inst of DW02_tree_inst is
for inst
end for; -- inst
end DW02_tree_inst_cfg_inst;
-- pragma translate_on
