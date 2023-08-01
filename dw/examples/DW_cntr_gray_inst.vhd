library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_cntr_gray_inst is
  generic (inst_width : positive := 8);
  port (inst_clk    : in  std_logic;
        inst_rst_n  : in  std_logic;
        inst_init_n : in  std_logic;
        inst_load_n : in  std_logic;
        inst_data   : in  std_logic_vector(inst_width-1 downto 0);
        inst_cen    : in  std_logic;
        count_inst  : out std_logic_vector(inst_width-1 downto 0));
end DW_cntr_gray_inst;

architecture inst of DW_cntr_gray_inst is
begin
  -- instance of DW_cntr_gray
  U1 : DW_cntr_gray
    generic map (width => inst_width)
    port map (clk    => inst_clk,
              rst_n  => inst_rst_n,
              init_n => inst_init_n,
              load_n => inst_load_n,
              data   => inst_data,
              cen    => inst_cen,
              count  => count_inst);
end inst;

-- pragma translate_off
configuration DW_cntr_gray_inst_cfg_inst of DW_cntr_gray_inst is
  for inst
  end for;
end DW_cntr_gray_inst_cfg_inst;
-- pragma translate_on

