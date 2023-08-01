library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW01_dec_inst is
  generic ( inst_width : NATURAL := 8 );
  port ( inst_A   : in std_logic_vector(inst_width-1 downto 0);
         SUM_inst : out std_logic_vector(inst_width-1 downto 0) );
end DW01_dec_inst;

architecture inst of DW01_dec_inst is
begin

  -- Instance of DW01_dec
  U1 : DW01_dec
    generic map ( width => inst_width )
    port map ( A => inst_A, SUM => SUM_inst );
end inst;

-- pragma translate_off
configuration DW01_dec_inst_cfg_inst of DW01_dec_inst is
  for inst
  end for; -- inst
end DW01_dec_inst_cfg_inst;
-- pragma translate_on

