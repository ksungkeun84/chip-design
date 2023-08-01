library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW03_lfsr_updn_inst is
  generic ( inst_width : INTEGER := 8 );
  port ( inst_updn    : in std_logic;
         inst_cen     : in std_logic;
         inst_clk     : in std_logic;
         inst_reset   : in std_logic;
         count_inst   : out std_logic_vector(inst_width-1 downto 0);
          tercnt_inst : out std_logic );
end DW03_lfsr_updn_inst;

architecture inst of DW03_lfsr_updn_inst is
begin

  -- Instance of DW03_lfsr_updn
  U1 : DW03_lfsr_updn
    generic map ( width => inst_width )
    port map ( updn => inst_updn, cen => inst_cen, clk => inst_clk, 
               reset => inst_reset, count => count_inst, 
               tercnt => tercnt_inst );
end inst;

-- pragma translate_off
configuration DW03_lfsr_updn_inst_cfg_inst of DW03_lfsr_updn_inst is
  for inst
  end for; -- inst
end DW03_lfsr_updn_inst_cfg_inst;
-- pragma translate_on

