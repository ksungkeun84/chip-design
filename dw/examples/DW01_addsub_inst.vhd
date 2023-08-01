library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW01_addsub_inst is
  generic ( inst_width : NATURAL := 8 );
  port ( inst_A       : in std_logic_vector(inst_width-1 downto 0);
         inst_B       : in std_logic_vector(inst_width-1 downto 0);
         inst_CI      : in std_logic;
         inst_ADD_SUB : in std_logic;
         SUM_inst     : out std_logic_vector(inst_width-1 downto 0);
         CO_inst      : out std_logic );
end DW01_addsub_inst;

architecture inst of DW01_addsub_inst is
begin

  -- Instance of DW01_addsub
  U1 : DW01_addsub
    generic map ( width => inst_width )
    port map ( A => inst_A, B => inst_B, CI => inst_CI, 
               ADD_SUB => inst_ADD_SUB, SUM => SUM_inst, CO => CO_inst );
end inst;

-- pragma translate_off
configuration DW01_addsub_inst_cfg_inst of DW01_addsub_inst is
  for inst
  end for; -- inst
end DW01_addsub_inst_cfg_inst;
-- pragma translate_on

