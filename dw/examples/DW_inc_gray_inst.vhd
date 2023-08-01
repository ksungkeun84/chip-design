library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_inc_gray_inst is
  generic (inst_width : positive := 8);
  port (inst_a  : in  std_logic_vector(inst_width-1 downto 0);
        inst_ci : in  std_logic;
        z_inst  : out std_logic_vector(inst_width-1 downto 0));
end DW_inc_gray_inst;

architecture inst of DW_inc_gray_inst is
begin
  -- instance of DW_inc_gray
  U1 : DW_inc_gray
    generic map (width => inst_width)
    port map (a  => inst_a,
              ci => inst_ci,
              z  => z_inst);
end inst;

-- pragma translate_off
configuration DW_inc_gray_inst_cfg_inst of DW_inc_gray_inst is
  for inst
  end for;
end DW_inc_gray_inst_cfg_inst;
-- pragma translate_on

