library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_mult_dx_inst is
  generic ( inst_width : NATURAL := 16;
            inst_p1_width : NATURAL := 8 );
  port ( inst_a    : in std_logic_vector(inst_width-1 downto 0);
         inst_b    : in std_logic_vector(inst_width-1 downto 0);
         inst_tc   : in std_logic;
         inst_dplx : in std_logic;
         product_inst : out std_logic_vector(2*inst_width-1 downto 0) );
end DW_mult_dx_inst;

architecture inst of DW_mult_dx_inst is
begin

  -- Instance of DW_mult_dx
  U1 : DW_mult_dx
  generic map ( width => inst_width,
                p1_width => inst_p1_width )
  port map ( a => inst_a,   b => inst_b,   tc => inst_tc,
             dplx => inst_dplx,   product => product_inst );
end inst;

-- pragma translate_off
configuration DW_mult_dx_inst_cfg_inst of DW_mult_dx_inst is
  for inst
  end for; -- inst
end DW_mult_dx_inst_cfg_inst;
-- pragma translate_on

