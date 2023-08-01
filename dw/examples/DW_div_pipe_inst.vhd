library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_div_pipe_inst is
  generic (inst_a_width    : POSITIVE := 8;  inst_b_width     : POSITIVE := 8;
           inst_tc_mode    : NATURAL := 0;   inst_rem_mode    : NATURAL := 1;
           inst_num_stages : POSITIVE := 2;  inst_stall_mode  : NATURAL := 1;
           inst_rst_mode   : NATURAL := 1;   inst_op_iso_mode : NATURAL := 0 );
  port (inst_clk         : in std_logic;
        inst_rst_n       : in std_logic;
        inst_en          : in std_logic;
        inst_a           : in std_logic_vector(inst_a_width-1 downto 0);
        inst_b           : in std_logic_vector(inst_b_width-1 downto 0);
        quotient_inst    : out std_logic_vector(inst_a_width-1 downto 0);
        remainder_inst   : out std_logic_vector(inst_b_width-1 downto 0);
        divide_by_0_inst : out std_logic );
end DW_div_pipe_inst;

architecture inst of DW_div_pipe_inst is
begin
  -- Instance of DW_div_pipe
  U1 : DW_div_pipe
    generic map (a_width => inst_a_width,   b_width => inst_b_width,
                 tc_mode => inst_tc_mode,   rem_mode => inst_rem_mode,
                 num_stages => inst_num_stages,  stall_mode => inst_stall_mode, 
                 rst_mode => inst_rst_mode,   op_iso_mode => inst_op_iso_mode )
    port map (clk => inst_clk,   rst_n => inst_rst_n,   en => inst_en,
              a => inst_a,   b => inst_b,   
              quotient => quotient_inst,   remainder => remainder_inst,
              divide_by_0 => divide_by_0_inst );
end inst;

-- Configuration for use with VSS simulator
-- pragma translate_off
configuration DW_div_pipe_inst_cfg_inst of DW_div_pipe_inst is
  for inst
  end for; -- inst
end DW_div_pipe_inst_cfg_inst;
-- pragma translate_on
