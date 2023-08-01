library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_dpll_sd_inst is
  generic (inst_width : INTEGER := 1;
           inst_divisor : INTEGER := 5;
           inst_gain : INTEGER := 1;
           inst_filter : INTEGER := 2;
           inst_windows : INTEGER := 1);
  port (inst_clk : in std_logic;
        inst_rst_n : in std_logic;
        inst_stall : in std_logic;
        inst_squelch : in std_logic;
        inst_window: in std_logic_vector(bit_width(inst_windows)-1 downto 0);
        inst_data_in : in std_logic_vector(inst_width-1 downto 0);
        clk_out_inst : out std_logic;
        bit_ready_inst : out std_logic;
        data_out_inst : out std_logic_vector(inst_width-1 downto 0) );
end DW_dpll_sd_inst;

architecture inst of DW_dpll_sd_inst is
begin

  -- Instance of DW_dpll_sd
  U1 : DW_dpll_sd
    generic map ( width => inst_width, divisor => inst_divisor, 
                  gain => inst_gain, filter => inst_filter, 
                  windows => inst_windows )
  port map ( clk => inst_clk, rst_n => inst_rst_n, stall => inst_stall,
             squelch => inst_squelch, window => inst_window, 
             data_in => inst_data_in, clk_out => clk_out_inst, 
             bit_ready => bit_ready_inst, data_out => data_out_inst );
end inst;

-- pragma translate_off
configuration DW_dpll_sd_inst_cfg_inst of DW_dpll_sd_inst is
  for inst
  end for; -- inst
end DW_dpll_sd_inst_cfg_inst;
-- pragma translate_on
