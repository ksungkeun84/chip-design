library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_sqrt_pipe_inst is
  generic (inst_width      : POSITIVE := 2; inst_tc_mode     : NATURAL := 0;
           inst_num_stages : POSITIVE := 2; inst_stall_mode  : NATURAL := 1;
           inst_rst_mode   : NATURAL := 1;  inst_op_iso_mode : NATURAL := 0 );
  port (inst_clk   : in std_logic;
        inst_rst_n : in std_logic;
        inst_en    : in std_logic;
        inst_a     : in std_logic_vector(inst_width-1 downto 0);
        root_inst  : out std_logic_vector((inst_width+1)/2-1 downto 0)  );
end DW_sqrt_pipe_inst;

architecture inst of DW_sqrt_pipe_inst is
begin
  -- Instance of DW_sqrt_pipe
  U1 : DW_sqrt_pipe
    generic map (width => inst_width,   tc_mode => inst_tc_mode,
                 num_stages => inst_num_stages,  stall_mode => inst_stall_mode, 
                 rst_mode => inst_rst_mode,   op_iso_mode => inst_op_iso_mode )
    port map (clk => inst_clk,   rst_n => inst_rst_n,   en => inst_en, 
              a => inst_a,  root => root_inst );
end inst;

-- Configuration for use with VSS simulator
-- pragma translate_off
configuration DW_sqrt_pipe_inst_cfg_inst of DW_sqrt_pipe_inst is
  for inst
  end for; -- inst
end DW_sqrt_pipe_inst_cfg_inst;
-- pragma translate_on
