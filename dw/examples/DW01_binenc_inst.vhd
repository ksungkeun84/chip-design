library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW01_binenc_inst is
  generic (inst_A_width    : POSITIVE := 8;
           inst_ADDR_width : POSITIVE := 4);
  port (inst_A    : in  std_logic_vector(inst_A_width-1 downto 0);
        ADDR_inst : out std_logic_vector(inst_ADDR_width-1 downto 0));
end DW01_binenc_inst;

architecture inst of DW01_binenc_inst is
begin
  -- Instance of DW01_binenc
  U1 : DW01_binenc
    generic map ( A_width => inst_A_width, ADDR_width => inst_ADDR_width )
    port map ( A => inst_A, ADDR => ADDR_inst );
end inst;

-- pragma translate_off
configuration DW01_binenc_inst_cfg_inst of DW01_binenc_inst is
  for inst
  end for; -- inst
end DW01_binenc_inst_cfg_inst;
-- pragma translate_on

