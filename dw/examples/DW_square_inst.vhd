library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_foundation_comp.all;

entity DW_square_inst is
  generic ( inst_width : NATURAL := 8 );
  port ( inst_a      : in std_logic_vector(inst_width-1 downto 0);
         inst_tc     : in std_logic;
         square_inst : out std_logic_vector((2*inst_width)-1 downto 0) );
end DW_square_inst;

architecture inst of DW_square_inst is
begin

  -- Instance of DW_square
  U1 : DW_square
    generic map ( width => inst_width )
    port map ( a => inst_a,   tc => inst_tc,   square => square_inst );
end inst;

-- pragma translate_off
configuration DW_square_inst_cfg_inst of DW_square_inst is
  for inst
  end for; -- inst
end DW_square_inst_cfg_inst;
-- pragma translate_on

