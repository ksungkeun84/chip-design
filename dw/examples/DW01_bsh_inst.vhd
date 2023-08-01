library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW01_bsh_inst is
  generic (inst_A_width : POSITIVE := 8;
           inst_SH_width : POSITIVE := 3);
  port (inst_A : in std_logic_vector(inst_A_width-1 downto 0);
        inst_SH : in std_logic_vector(inst_SH_width-1 downto 0);
        B_inst : out std_logic_vector(inst_A_width-1 downto 0));
end DW01_bsh_inst;

architecture inst of DW01_bsh_inst is
begin

  -- Instance of DW01_bsh
  U1 : DW01_bsh
    generic map ( A_width => inst_A_width, SH_width => inst_SH_width )
    port map ( A => inst_A, SH => inst_SH, B => B_inst );
end inst;

-- pragma translate_off
configuration DW01_bsh_inst_cfg_inst of DW01_bsh_inst is
  for inst
  end for; -- inst
end DW01_bsh_inst_cfg_inst;
-- pragma translate_on

