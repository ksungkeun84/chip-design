library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_foundation_comp.all;

entity DW_8b10b_unbal_inst is
  generic (inst_k28_5_only : integer := 0 );
  port (inst_k_char  : in std_logic;
        inst_data_in : in std_logic_vector(7 downto 0);
        unbal_inst   : out std_logic );
end DW_8b10b_unbal_inst;

architecture inst of DW_8b10b_unbal_inst is
begin

  -- Instance of DW_8b10b_unbal
  U1 : DW_8b10b_unbal
    generic map (k28_5_only => inst_k28_5_only )
    port map (k_char => inst_k_char,   data_in => inst_data_in,
              unbal => unbal_inst );
end inst;

-- Configuration for use with VSS simulator
-- pragma translate_off
configuration DW_8b10b_unbal_inst_cfg_inst of DW_8b10b_unbal_inst is
  for inst
  end for; -- inst
end DW_8b10b_unbal_inst_cfg_inst;
-- pragma translate_on

