library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW02_mac_inst is
  generic ( inst_A_width : NATURAL := 8;
            inst_B_width : NATURAL := 8 );
  port (inst_A  : in std_logic_vector(inst_A_width-1 downto 0);
        inst_B  : in std_logic_vector(inst_B_width-1 downto 0);
        inst_C  : in std_logic_vector(inst_A_width+inst_B_width-1 downto 0);
        inst_TC : in std_logic;
      MAC_inst: out std_logic_vector(inst_A_width+inst_B_width-1 downto 0) );
end DW02_mac_inst;

architecture inst of DW02_mac_inst is
begin

  -- Instance of DW02_mac
  U1 : DW02_mac
    generic map ( A_width => inst_A_width, B_width => inst_B_width )
    port map ( A => inst_A, B => inst_B, C => inst_C, 
               TC => inst_TC, MAC => MAC_inst );
end inst;

-- pragma translate_off
configuration DW02_mac_inst_cfg_inst of DW02_mac_inst is
  for inst
  end for; -- inst
end DW02_mac_inst_cfg_inst;
-- pragma translate_on

