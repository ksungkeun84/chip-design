library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_sqrt_seq_inst is
  generic (inst_width       : POSITIVE := 8; inst_tc_mode     : INTEGER := 0;
           inst_num_cyc     : INTEGER := 3;  inst_rst_mode    : INTEGER := 0;
           inst_input_mode  : INTEGER := 1;  inst_output_mode : INTEGER := 1;
           inst_early_start : INTEGER := 0 );
  port (inst_clk      : in std_logic;  inst_rst_n : in std_logic;
        inst_hold     : in std_logic;  inst_start : in std_logic;
        inst_a        : in std_logic_vector(inst_width-1 downto 0);
        complete_inst : out std_logic;
        root_inst     : out std_logic_vector((inst_width+1)/2-1 downto 0)  );
end DW_sqrt_seq_inst;

architecture inst of DW_sqrt_seq_inst is
begin
-- Instance of DW_sqrt_seq
  U1 : DW_sqrt_seq
    generic map (width => inst_width,   tc_mode => inst_tc_mode,
                 rst_mode => inst_rst_mode,   input_mode => inst_input_mode,
                 output_mode => inst_output_mode,
                 early_start => inst_early_start   )
    port map (clk => inst_clk,   rst_n => inst_rst_n,
              hold => inst_hold,   start => inst_start,   a => inst_a,
              complete => complete_inst,   root => root_inst   );
end inst;

-- pragma translate_off
configuration DW_sqrt_seq_inst_cfg_inst of DW_sqrt_seq_inst is
  for inst
  end for;
end DW_sqrt_seq_inst_cfg_inst;
-- pragma translate_on
