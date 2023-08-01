library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW01_ash_inst is
  generic ( inst_A_width : POSITIVE := 8;
            inst_SH_width : POSITIVE := 8 );
  port ( inst_A       : in std_logic_vector(inst_A_width-1 downto 0);
         inst_DATA_TC : in std_logic;
         inst_SH      : in std_logic_vector(inst_SH_width-1 downto 0);
         inst_SH_TC   : in std_logic;
         B_inst       : out std_logic_vector(inst_A_width-1 downto 0) );
end DW01_ash_inst;

architecture inst of DW01_ash_inst is
begin

  -- Instance of DW01_ash
  U1 : DW01_ash
    generic map ( A_width => inst_A_width, SH_width => inst_SH_width )
    port map ( A => inst_A, DATA_TC => inst_DATA_TC, SH => inst_SH, 
               SH_TC => inst_SH_TC, B => B_inst );
  end inst;

-- pragma translate_off
configuration DW01_ash_inst_cfg_inst of DW01_ash_inst is
  for inst
  end for; -- inst
end DW01_ash_inst_cfg_inst;
-- pragma translate_on
