library IEEE,DWARE,dw03;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_pulse_sync_inst is
      generic (
	    inst_reg_event : NATURAL := 1;
	    inst_f_sync_type : NATURAL := 2;
	    inst_tst_mode : NATURAL := 0;
	    inst_verif_en : NATURAL := 1;
	    inst_pulse_mode : NATURAL := 1
	    );
      port (
	    inst_clk_s : in std_logic;
	    inst_rst_s_n : in std_logic;
	    inst_init_s_n : in std_logic;
	    inst_event_s : in std_logic;
	    inst_clk_d : in std_logic;
	    inst_rst_d_n : in std_logic;
	    inst_init_d_n : in std_logic;
	    inst_test : in std_logic;
	    event_d_inst : out std_logic
	    );
    end DW_pulse_sync_inst;


architecture inst of DW_pulse_sync_inst is

begin

    -- Instance of DW_pulse_sync
    U1 : DW_pulse_sync
	generic map ( reg_event => inst_reg_event, 
	              f_sync_type => inst_f_sync_type, 
		      tst_mode => inst_tst_mode, 
		      verif_en => inst_verif_en, 
		      pulse_mode => inst_pulse_mode )
	port map ( clk_s => inst_clk_s, 
	           rst_s_n => inst_rst_s_n, 
		   init_s_n => inst_init_s_n, 
		   event_s => inst_event_s, 
		   clk_d => inst_clk_d, 
		   rst_d_n => inst_rst_d_n, 
		   init_d_n => inst_init_d_n, 
		   test => inst_test, 
		   event_d => event_d_inst );


end inst;
-- pragma translate_off
library DW03;
configuration DW_pulse_sync_inst_cfg_inst of DW_pulse_sync_inst is
  for inst
  end for; -- inst
end DW_pulse_sync_inst_cfg_inst;
-- pragma translate_on
