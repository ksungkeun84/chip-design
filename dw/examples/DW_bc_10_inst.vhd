library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_bc_10_inst is
  port (inst_capture_clk : in  std_logic;
        inst_update_clk  : in  std_logic;
        inst_capture_en  : in  std_logic;
        inst_update_en   : in  std_logic;
        inst_shift_dr    : in  std_logic;
        inst_mode        : in  std_logic;
        inst_si          : in  std_logic;
        inst_pin_input   : in  std_logic;
        inst_output_data : in  std_logic;
        data_out_inst    : out std_logic;
        so_inst          : out std_logic );
end DW_bc_10_inst;

architecture inst of DW_bc_10_inst is
begin
  -- Instance of DW_bc_10
  U1 : DW_bc_10
    port map (capture_clk => inst_capture_clk,
              update_clk  => inst_update_clk,
              capture_en  => inst_capture_en,
              update_en   => inst_update_en,
              shift_dr    => inst_shift_dr,
              mode        => inst_mode,
              si          => inst_si,
              pin_input   => inst_pin_input,
              output_data => inst_output_data,
              data_out    => data_out_inst,
              so          => so_inst );
end inst;

-- pragma translate_off
configuration DW_bc_10_inst_cfg_inst of DW_bc_10_inst is
  for inst
  end for; -- inst
end DW_bc_10_inst_cfg_inst;
-- pragma translate_on
