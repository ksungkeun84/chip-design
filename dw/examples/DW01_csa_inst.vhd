library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW01_csa_inst is
  generic ( inst_width : INTEGER := 8 );
  port ( inst_a     : in std_logic_vector(inst_width-1 downto 0);
         inst_b     : in std_logic_vector(inst_width-1 downto 0);
         inst_c     : in std_logic_vector(inst_width-1 downto 0);
         inst_ci    : in std_logic;
         carry_inst : out std_logic_vector(inst_width-1 downto 0);
         sum_inst   : out std_logic_vector(inst_width-1 downto 0);
         co_inst    : out std_logic );
end DW01_csa_inst;

architecture inst of DW01_csa_inst is
begin

  -- Instance of DW01_csa
  U1 : DW01_csa
    generic map ( width => inst_width )
    port map ( a => inst_a, b => inst_b, c => inst_c, ci => inst_ci, 
               carry => carry_inst, sum => sum_inst, co => co_inst );
end inst;

-- pragma translate_off
configuration DW01_csa_inst_cfg_inst of DW01_csa_inst is
  for inst
  end for; -- inst
end DW01_csa_inst_cfg_inst;
-- pragma translate_on

