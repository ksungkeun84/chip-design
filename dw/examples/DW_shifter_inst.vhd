library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_shifter_inst is
  generic ( inst_data_width : POSITIVE := 8;
            inst_sh_width   : POSITIVE := 3;
            inst_inv_mode   : INTEGER := 0 );
  port ( inst_data_in  : in std_logic_vector(inst_data_width-1 downto 0);
         inst_data_tc  : in std_logic;
         inst_sh       : in std_logic_vector(inst_sh_width-1 downto 0);
         inst_sh_tc    : in std_logic;
         inst_sh_mode  : in std_logic;
         data_out_inst : out std_logic_vector(inst_data_width-1 downto 0) );
end DW_shifter_inst;

architecture inst of DW_shifter_inst is
begin
  -- Instance of DW_shifter
  U1 : DW_shifter
    generic map ( data_width => inst_data_width,   sh_width => inst_sh_width,
                  inv_mode => inst_inv_mode)
    port map ( data_in => inst_data_in,   data_tc => inst_data_tc, 
               sh => inst_sh,   sh_tc => inst_sh_tc, 
               sh_mode => inst_sh_mode,   data_out => data_out_inst );
end inst;

-- pragma translate_off
configuration DW_shifter_inst_cfg_inst of DW_shifter_inst is
  for inst
  end for; -- inst
end DW_shifter_inst_cfg_inst;
-- pragma translate_on

