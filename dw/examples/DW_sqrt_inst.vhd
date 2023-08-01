library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_sqrt_inst is
  generic (radicand_width : positive := 8;
           tc_mode        : natural  := 0);
  port (radicand    : in  std_logic_vector(radicand_width-1 downto 0);
        square_root : out std_logic_vector((radicand_width+1)/2-1 downto 0));
end DW_sqrt_inst;

architecture inst of DW_sqrt_inst is
begin
  -- instance of DW_sqrt
  U1 : DW_sqrt
    generic map (width => radicand_width,   tc_mode => tc_mode)
    port map (a => radicand,   root => square_root);
end inst;

-- pragma translate_off
configuration DW_sqrt_inst_cfg_inst of DW_sqrt_inst is
  for inst
  end for;
end DW_sqrt_inst_cfg_inst;
-- pragma translate_on

