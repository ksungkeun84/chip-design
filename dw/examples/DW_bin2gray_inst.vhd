library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_bin2gray_inst is
  generic (inst_width : positive := 8);
  port (inst_b : in  std_logic_vector(inst_width-1 downto 0);
        g_inst : out std_logic_vector(inst_width-1 downto 0));
end DW_bin2gray_inst;

architecture inst of DW_bin2gray_inst is
begin
  -- instance of DW_bin2gray
  U1 : DW_bin2gray
    generic map (width => inst_width)
    port map (b => inst_b,
              g => g_inst);
end inst;

-- pragma translate_off
configuration DW_bin2gray_inst_cfg_inst of DW_bin2gray_inst is
  for inst
  end for;
end DW_bin2gray_inst_cfg_inst;
-- pragma translate_on

