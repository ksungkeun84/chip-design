library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_data_qsync_hl_inst is
      generic (
	    inst_width : NATURAL := 8;
	    inst_clk_ratio : NATURAL := 2;
	    inst_tst_mode : NATURAL := 0
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
	    data_avail_d_inst : out std_logic;
	    data_d_inst : out std_logic_vector(inst_width-1 downto 0);
	    inst_test : in std_logic
	    );
    end DW_data_qsync_hl_inst;


architecture inst of DW_data_qsync_hl_inst is

begin

    -- Instance of DW_data_qsync_hl
    U1 : DW_data_qsync_hl
	generic map ( width => inst_width,
                      clk_ratio => inst_clk_ratio,
                      tst_mode => inst_tst_mode )
	port map ( clk_s => inst_clk_s,
                   rst_s_n => inst_rst_s_n,
                   init_s_n => inst_init_s_n,
                   send_s => inst_send_s,
                   data_s => inst_data_s,
                   clk_d => inst_clk_d,
                   rst_d_n => inst_rst_d_n,
                   init_d_n => inst_init_d_n,
                   data_avail_d => data_avail_d_inst,
                   data_d => data_d_inst,
                   test => inst_test );


end inst;
