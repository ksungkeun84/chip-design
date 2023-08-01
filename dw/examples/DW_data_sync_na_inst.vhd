library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_data_sync_na_inst is
      generic (
	    inst_width : INTEGER := 8;
	    inst_f_sync_type : INTEGER := 2;
	    inst_tst_mode : INTEGER := 0;
	    inst_verif_en : INTEGER := 2
	    );
      port (
	    inst_clk_s : in std_logic;
	    inst_rst_s_n : in std_logic;
	    inst_init_s_n : in std_logic;
	    inst_send_s : in std_logic;
	    inst_data_s : in std_logic_vector(inst_width-1 downto 0);
	    inst_clk_d : in std_logic;
	    inst_rst_d_n : in std_logic;
	    inst_init_d_n : in std_logic;
	    inst_test : in std_logic;
	    data_avail_d_inst : out std_logic;
	    data_d_inst : out std_logic_vector(inst_width-1 downto 0)
	    );
    end DW_data_sync_na_inst;


architecture inst of DW_data_sync_na_inst is
begin

    -- Instance of DW_data_sync_na
    U1 : DW_data_sync_na
	generic map ( width => inst_width, f_sync_type => inst_f_sync_type, 
		    tst_mode => inst_tst_mode, verif_en => inst_verif_en )
port map ( clk_s => inst_clk_s, rst_s_n => inst_rst_s_n, init_s_n => 
			inst_init_s_n,
	send_s => inst_send_s, data_s => inst_data_s, clk_d => inst_clk_d, 
	rst_d_n => inst_rst_d_n, init_d_n => inst_init_d_n, test => inst_test, 
	data_avail_d => data_avail_d_inst, data_d => data_d_inst );


end inst;

-- Configuration for use with a VHDL simulator
-- pragma translate_off
library DW03;
configuration DW_data_sync_na_inst_cfg_inst of DW_data_sync_na_inst is
  for inst
    -- NOTE: If desiring to model missampling, uncomment the following
    -- line.  Doing so, however, will cause inconsequential errors
    -- when analyzing or reading this configuration before synthesis.
    -- for U1 : DW_data_sync_na use configuration DW03.DW_data_sync_na_cfg_sim_ms;  end for;
  end for; -- inst
end DW_data_sync_na_inst_cfg_inst;
-- pragma translate_on
