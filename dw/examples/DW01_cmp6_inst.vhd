library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW01_cmp6_inst is
  generic ( inst_width : NATURAL := 8 );
  port ( inst_A  : in std_logic_vector(inst_width-1 downto 0);
         inst_B  : in std_logic_vector(inst_width-1 downto 0);
         inst_TC : in std_logic;
         LT_inst : out std_logic;
         GT_inst : out std_logic;
         EQ_inst : out std_logic;
         LE_inst : out std_logic;
         GE_inst : out std_logic;
         NE_inst : out std_logic );
end DW01_cmp6_inst;

architecture inst of DW01_cmp6_inst is
begin

  -- Instance of DW01_cmp6
  U1 : DW01_cmp6
    generic map ( width => inst_width )
    port map ( A => inst_A, B => inst_B, TC => inst_TC, LT => LT_inst, 
               GT => GT_inst, EQ => EQ_inst, LE => LE_inst, 
               GE => GE_inst, NE => NE_inst );
end inst;

-- pragma translate_off
configuration DW01_cmp6_inst_cfg_inst of DW01_cmp6_inst is
  for inst
  end for; -- inst
end DW01_cmp6_inst_cfg_inst;
-- pragma translate_on

