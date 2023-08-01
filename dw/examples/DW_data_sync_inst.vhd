library IEEE,DWARE,dw03;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_data_sync_inst is
      generic (
	    inst_width : NATURAL := 8;
	    inst_pend_mode : NATURAL := 0;
	    inst_ack_delay : NATURAL := 1;
	    inst_f_sync_type : NATURAL := 2;
	    inst_r_sync_type : NATURAL := 2;
	    inst_tst_mode : NATURAL := 0;
	    inst_verif_en : NATURAL := 1;
	    inst_send_mode : NATURAL := 0
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
	    empty_s_inst : out std_logic;
	    full_s_inst : out std_logic;
	    done_s_inst : out std_logic;
	    data_avail_d_inst : out std_logic;
	    data_d_inst : out std_logic_vector(inst_width-1 downto 0)
	    );
    end DW_data_sync_inst;


architecture inst of DW_data_sync_inst is

begin

    -- Instance of DW_data_sync
    U1 : DW_data_sync
	generic map ( width => inst_width, 
	              pend_mode => inst_pend_mode, 
		      ack_delay => inst_ack_delay, 
		      f_sync_type => inst_f_sync_type, 
		      r_sync_type => inst_r_sync_type, 
		      tst_mode => inst_tst_mode, 
		      verif_en => inst_verif_en, 
		      send_mode => inst_send_mode )
	port map ( clk_s => inst_clk_s, 
	           rst_s_n => inst_rst_s_n, 
		   init_s_n => inst_init_s_n, 
		   send_s => inst_send_s, 
		   data_s => inst_data_s, 
		   clk_d => inst_clk_d, 
		   rst_d_n => inst_rst_d_n, 
		   init_d_n => inst_init_d_n, 
		   test => inst_test, 
		   empty_s => empty_s_inst, 
		   full_s => full_s_inst, 
		   done_s => done_s_inst, 
		   data_avail_d => data_avail_d_inst, 
		   data_d => data_d_inst );


end inst;
-- pragma translate_off
library DW03;
configuration DW_data_sync_inst_cfg_inst of DW_data_sync_inst is
  for inst
  end for; -- inst
end DW_data_sync_inst_cfg_inst;
-- pragma translate_on
