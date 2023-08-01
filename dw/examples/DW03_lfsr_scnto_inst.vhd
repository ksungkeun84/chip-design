library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW03_lfsr_scnto_inst is
  generic ( inst_width    : INTEGER := 8;
            inst_count_to : INTEGER := 8);
  port ( inst_data   : in std_logic_vector(inst_width-1 downto 0);
         inst_load   : in std_logic;
         inst_cen    : in std_logic;
         inst_clk    : in std_logic;
         inst_reset  : in std_logic;
         count_inst  : out std_logic_vector(inst_width-1 downto 0);
         tercnt_inst : out std_logic );
end DW03_lfsr_scnto_inst;

architecture inst of DW03_lfsr_scnto_inst is
begin

  -- Instance of DW03_lfsr_scnto
  U1 : DW03_lfsr_scnto
    generic map ( width => inst_width, count_to => inst_count_to )
    port map ( data => inst_data, load => inst_load, 
               cen => inst_cen, clk => inst_clk, reset => inst_reset, 
               count => count_inst, tercnt => tercnt_inst );
end inst;

-- pragma translate_off
configuration DW03_lfsr_scnto_inst_cfg_inst of DW03_lfsr_scnto_inst is
  for inst
  end for; -- inst
end DW03_lfsr_scnto_inst_cfg_inst;
-- pragma translate_on

