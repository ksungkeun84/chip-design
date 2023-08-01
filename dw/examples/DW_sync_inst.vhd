library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_sync_inst is
      generic (
            inst_width : INTEGER := 8;
            inst_f_sync_type : INTEGER := 2;
            inst_tst_mode : INTEGER := 0;
            inst_verif_en : INTEGER := 1
            );
      port (
            inst_clk_d : in std_logic;
            inst_rst_d_n : in std_logic;
            inst_init_d_n : in std_logic;
            inst_data_s : in std_logic_vector (inst_width-1 downto 0);
            inst_test : in std_logic;
            data_d_inst : out std_logic_vector (inst_width-1 downto 0)
            );
    end DW_sync_inst;

architecture inst of DW_sync_inst is
begin

    -- Instance of DW_sync
    U1 : DW_sync
        generic map ( width => inst_width, f_sync_type => inst_f_sync_type, 
	tst_mode => inst_tst_mode, verif_en => inst_verif_en )
	port map ( clk_d => inst_clk_d, rst_d_n => inst_rst_d_n, 
		init_d_n => inst_init_d_n, 
		data_s => inst_data_s, test => inst_test, data_d => data_d_inst );
end inst;

-- Configuration for use with a VHDL simulator
-- pragma translate_off
library DW03;
configuration DW_sync_inst_cfg_inst of DW_sync_inst is
  for inst
    -- NOTE: If desiring to model missampling, uncomment the following
    -- line.  Doing so, however, will cause inconsequential errors
    -- when analyzing or reading this configuration before synthesis.
    -- for U1 : DW_sync use configuration DW03.DW_sync_cfg_sim_ms; end for;
  end for; -- inst
end DW_sync_inst_cfg_inst;
-- pragma translate_on
