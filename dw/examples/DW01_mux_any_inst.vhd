library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW01_mux_any_inst is
  generic (inst_A_width : POSITIVE := 8;
           inst_SEL_width : POSITIVE := 8;
           inst_MUX_width : POSITIVE := 8);
  port (inst_A : in std_logic_vector(inst_A_width-1 downto 0);
        inst_SEL : in std_logic_vector(inst_SEL_width-1 downto 0);
        MUX_inst : out std_logic_vector(inst_MUX_width-1 downto 0));
end DW01_mux_any_inst;

architecture inst of DW01_mux_any_inst is
begin
  -- Instance of DW01_mux_any
  U1 : DW01_mux_any
    generic map ( A_width => inst_A_width, SEL_width => inst_SEL_width,
                 MUX_width => inst_MUX_width )
    port map ( A => inst_A, SEL => inst_SEL, MUX => MUX_inst );
end inst;

-- pragma translate_off
configuration DW01_mux_any_inst_cfg_inst of DW01_mux_any_inst is
  for inst
  end for; -- inst
end DW01_mux_any_inst_cfg_inst;
-- pragma translate_on
