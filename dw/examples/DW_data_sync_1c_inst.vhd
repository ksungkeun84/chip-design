library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_data_sync_1c_inst is
      generic (
            inst_width : INTEGER := 8;
            inst_f_sync_type : INTEGER := 2;
            inst_filt_size : INTEGER := 1;
            inst_tst_mode : INTEGER := 0;
            inst_verif_en : INTEGER := 2
            );
      port (
            inst_clk_d : in std_logic;
            inst_rst_d_n : in std_logic;
            inst_init_d_n : in std_logic;
            inst_data_s : in std_logic_vector(inst_width-1 downto 0);
            inst_filt_d : in std_logic_vector(inst_filt_size-1 downto 0);
            inst_test : in std_logic;
            data_avail_d_inst : out std_logic;
            data_d_inst : out std_logic_vector(inst_width-1 downto 0);
            max_skew_d_inst : out std_logic_vector(inst_filt_size downto 0)
            );
    end DW_data_sync_1c_inst;


architecture inst of DW_data_sync_1c_inst is
begin

    -- Instance of DW_data_sync_1c
    U1 : DW_data_sync_1c
	generic map ( width => inst_width, f_sync_type => inst_f_sync_type, 
			filt_size => inst_filt_size, tst_mode => inst_tst_mode,
			verif_en => inst_verif_en )
	port map ( clk_d => inst_clk_d, rst_d_n => inst_rst_d_n, 
			init_d_n => inst_init_d_n,data_s => inst_data_s, 
			filt_d => inst_filt_d,test => inst_test, 
			data_avail_d => data_avail_d_inst, data_d => data_d_inst, 
			max_skew_d => max_skew_d_inst );
end inst;

-- Configuration for use with a VHDL simulator
-- pragma translate_off
library DW03;
configuration DW_data_sync_1c_inst_cfg_inst of DW_data_sync_1c_inst is
  for inst
    -- NOTE: If desiring to model missampling, uncomment the following
    -- line.  Doing so, however, will cause inconsequential errors
    -- when analyzing or reading this configuration before synthesis.
    -- for U1 : DW_data_sync_1c use configuration DW03.DW_data_sync_1c_cfg_sim_ms;  end for;
  end for; -- inst
end DW_data_sync_1c_inst_cfg_inst;
-- pragma translate_on

