library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_gray2bin_inst is
  generic (inst_width : positive := 8);
  port (inst_g : in  std_logic_vector(inst_width-1 downto 0);
        b_inst : out std_logic_vector(inst_width-1 downto 0));
end DW_gray2bin_inst;

architecture inst of DW_gray2bin_inst is
begin
  -- instance of DW_gray2bin
  U1 : DW_gray2bin
    generic map (width => inst_width)
    port map (g => inst_g,
              b => b_inst);
end inst;

-- pragma translate_off
configuration DW_gray2bin_inst_cfg_inst of DW_gray2bin_inst is
  for inst
  end for;
end DW_gray2bin_inst_cfg_inst;
-- pragma translate_on

