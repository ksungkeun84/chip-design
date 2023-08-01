library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_reset_sync_inst is
      generic (
	    inst_f_sync_type : INTEGER := 2;
            inst_r_sync_type : NATURAL := 2;
            inst_clk_d_faster: NATURAL := 1;
            inst_reg_in_prog : NATURAL := 1;
	    inst_tst_mode : INTEGER := 0;
	    inst_verif_en : INTEGER := 1
	    );
      port (
	    inst_clk_s : in std_logic;
	    inst_rst_s_n : in std_logic;
	    inst_init_s_n : in std_logic;
	    inst_clr_s : in std_logic;
	    clr_sync_s_inst : out std_logic;
	    clr_in_prog_s_inst : out std_logic;
	    clr_cmplt_s_inst : out std_logic;

	    inst_clk_d : in std_logic;
	    inst_rst_d_n : in std_logic;
	    inst_init_d_n : in std_logic;
	    inst_clr_d : in std_logic;
            clr_in_prog_d_inst : out std_logic;
            clr_sync_d_inst : out std_logic;
            clr_cmplt_d_inst : out std_logic;

	    inst_test : in std_logic
	    );
    end DW_reset_sync_inst;


architecture inst of DW_reset_sync_inst is
begin

    -- Instance of DW_reset_sync
    U1 : DW_reset_sync
	generic map ( f_sync_type => inst_f_sync_type, r_sync_type => inst_r_sync_type, clk_d_faster => inst_clk_d_faster,
                      reg_in_prog => inst_reg_in_prog, tst_mode => inst_tst_mode, verif_en => inst_verif_en )
	port map ( clk_s => inst_clk_s, rst_s_n => inst_rst_s_n, init_s_n => inst_init_s_n, clr_s => inst_clr_s, 
                   clr_sync_s => clr_sync_s_inst, clr_in_prog_s => clr_in_prog_s_inst, clr_cmplt_s => clr_cmplt_s_inst,
		   clk_d => inst_clk_d, rst_d_n => inst_rst_d_n, init_d_n => inst_init_d_n, clr_d => inst_clr_d, 
		   clr_in_prog_d => clr_in_prog_d_inst, clr_sync_d => clr_sync_d_inst, clr_cmplt_d => clr_cmplt_d_inst,
	           test => inst_test );


end inst;

-- Configuration for use with a VHDL simulator
-- pragma translate_off
library DW03;
configuration DW_reset_sync_inst_cfg_inst of DW_reset_sync_inst is
  for inst
    -- NOTE: If desiring to model missampling, uncomment the following
    -- line.  Doing so, however, will cause inconsequential errors
    -- when analyzing or reading this configuration before synthesis.
    -- for U1 : DW_reset_sync use configuration DW03.DW_reset_sync_cfg_sim_ms;  end for;
  end for; -- inst
end DW_reset_sync_inst_cfg_inst;
-- pragma translate_on
