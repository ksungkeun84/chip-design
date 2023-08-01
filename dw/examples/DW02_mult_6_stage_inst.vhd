library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW02_mult_6_stage_inst is
  generic ( inst_A_width : POSITIVE := 8;
            inst_B_width : POSITIVE := 8 );
  port ( inst_A : in std_logic_vector(inst_A_width-1 downto 0);
         inst_B : in std_logic_vector(inst_B_width-1 downto 0);
         inst_TC : in std_logic;
         inst_CLK : in std_logic;
    PRODUCT_inst : out std_logic_vector(inst_A_width+inst_B_width-1 downto 0)
       );
end DW02_mult_6_stage_inst;

architecture inst of DW02_mult_6_stage_inst is
begin

  -- Instance of DW02_mult_6_stage
  U1 : DW02_mult_6_stage
    generic map ( A_width => inst_A_width, B_width => inst_B_width )
    port map ( A => inst_A,   B => inst_B,   TC => inst_TC, 
               CLK => inst_CLK,   PRODUCT => PRODUCT_inst );
end inst;

-- pragma translate_off
configuration DW02_mult_6_stage_inst_cfg_inst of DW02_mult_6_stage_inst is
  for inst
  end for; -- inst
end DW02_mult_6_stage_inst_cfg_inst;
-- pragma translate_on

