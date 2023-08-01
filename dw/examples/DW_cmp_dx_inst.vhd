library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_foundation_comp.all;

entity DW_cmp_dx_inst is
  generic ( inst_width    : NATURAL := 24;
            inst_p1_width : NATURAL := 16 );
  port ( inst_a    : in std_logic_vector(inst_width-1 downto 0);
         inst_b    : in std_logic_vector(inst_width-1 downto 0);
         inst_tc   : in std_logic;
         inst_dplx : in std_logic;
         lt1_inst  : out std_logic;
         eq1_inst  : out std_logic;
         gt1_inst  : out std_logic;
         lt2_inst  : out std_logic;
         eq2_inst  : out std_logic;
         gt2_inst  : out std_logic );
end DW_cmp_dx_inst;

architecture inst of DW_cmp_dx_inst is
begin

  -- Instance of DW_cmp_dx
  U1 : DW_cmp_dx
    generic map ( width => inst_width, p1_width => inst_p1_width )
    port map ( a => inst_a, b => inst_b, tc => inst_tc, dplx => inst_dplx,
               lt1 => lt1_inst, eq1 => eq1_inst, gt1 => gt1_inst,
               lt2 => lt2_inst, eq2 => eq2_inst, gt2 => gt2_inst );
end inst;

-- pragma translate_off
configuration DW_cmp_dx_inst_cfg_inst of DW_cmp_dx_inst is
  for inst
  end for; -- inst
end DW_cmp_dx_inst_cfg_inst;
-- pragma translate_on

