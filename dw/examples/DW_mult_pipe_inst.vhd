library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_mult_pipe_inst is
  generic (inst_a_width    : POSITIVE := 8; inst_b_width     : POSITIVE := 8;
           inst_num_stages : POSITIVE := 2; inst_stall_mode  : NATURAL := 1;
           inst_rst_mode   : NATURAL := 1;  inst_op_iso_mode : NATURAL := 0 );
  port (inst_clk : in std_logic;   inst_rst_n : in std_logic;
        inst_en  : in std_logic;   inst_tc    : in std_logic;
        inst_a   : in std_logic_vector(inst_a_width-1 downto 0);
        inst_b   : in std_logic_vector(inst_b_width-1 downto 0);
        product_inst : out 
                    std_logic_vector(inst_a_width+inst_b_width-1 downto 0)
        );
end DW_mult_pipe_inst;

architecture inst of DW_mult_pipe_inst is
begin
  -- Instance of DW_mult_pipe
  U1 : DW_mult_pipe
    generic map (a_width => inst_a_width,   b_width => inst_b_width,
                 num_stages => inst_num_stages,   stall_mode => inst_stall_mode, 
                 rst_mode => inst_rst_mode,   op_iso_mode => inst_op_iso_mode )
  port map (clk => inst_clk,   rst_n => inst_rst_n,   en => inst_en,
            tc => inst_tc,   a => inst_a,   b => inst_b,
            product => product_inst );
end inst;

-- Configuration for use with VSS simulator
-- pragma translate_off
configuration DW_mult_pipe_inst_cfg_inst of DW_mult_pipe_inst is
  for inst
  end for; -- inst
end DW_mult_pipe_inst_cfg_inst;
-- pragma translate_on
