library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW03_reg_s_pl_inst is
  generic ( inst_width : POSITIVE := 8;
            inst_reset_value : INTEGER := 0 );
  port ( inst_d       : in std_logic_vector(inst_width-1 downto 0);
         inst_clk     : in std_logic;
         inst_reset_N : in std_logic;
         inst_enable  : in std_logic;
         q_inst       : out std_logic_vector(inst_width-1 downto 0) );
end DW03_reg_s_pl_inst;
architecture inst of DW03_reg_s_pl_inst is
begin

  -- Instance of DW03_reg_s_pl
  U1 : DW03_reg_s_pl
    generic map ( width => inst_width,  reset_value => inst_reset_value )
    port map ( d => inst_d,  clk => inst_clk,  reset_N => inst_reset_N, 
              enable => inst_enable,  q => q_inst );
end inst;

-- pragma translate_off
configuration DW03_reg_s_pl_inst_cfg_inst of DW03_reg_s_pl_inst is
  for inst
  end for; -- inst
end DW03_reg_s_pl_inst_cfg_inst;
-- pragma translate_on

