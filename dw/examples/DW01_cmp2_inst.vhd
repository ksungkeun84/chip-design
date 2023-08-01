library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW01_cmp2_inst is
  generic ( inst_width : NATURAL := 8 );
  port ( inst_A : in std_logic_vector(inst_width-1 downto 0);
         inst_B : in std_logic_vector(inst_width-1 downto 0);
         inst_LEQ : in std_logic;
         inst_TC : in std_logic;
         LT_LE_inst : out std_logic;
         GE_GT_inst : out std_logic );
end DW01_cmp2_inst;

architecture inst of DW01_cmp2_inst is
begin

  -- Instance of DW01_cmp2
  U1 : DW01_cmp2
    generic map ( width => inst_width )
    port map ( A => inst_A, B => inst_B, LEQ => inst_LEQ, 
              TC => inst_TC, LT_LE => LT_LE_inst, GE_GT => GE_GT_inst );
end inst;

-- pragma translate_off
configuration DW01_cmp2_inst_cfg_inst of DW01_cmp2_inst is
  for inst
  end for; -- inst
end DW01_cmp2_inst_cfg_inst;
-- pragma translate_on

