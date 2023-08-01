library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_asymdata_inbuf_inst is
      generic (
	    inst_in_width : INTEGER := 8;
	    inst_out_width : INTEGER := 16;
	    inst_err_mode : INTEGER := 0;
	    inst_byte_order : INTEGER := 0;
	    inst_flush_value : INTEGER := 0
	    );
      port (
	    inst_clk_push : in std_logic;
	    inst_rst_push_n : in std_logic;
	    inst_init_push_n : in std_logic;
	    inst_push_req_n : in std_logic;
	    inst_data_in : in std_logic_vector(inst_in_width-1 downto 0);
	    inst_flush_n : in std_logic;
	    inst_fifo_full : in std_logic;
	    push_wd_n_inst : out std_logic;
	    data_out_inst : out std_logic_vector(inst_out_width-1 downto 0);
	    inbuf_full_inst : out std_logic;
	    part_wd_inst : out std_logic;
	    push_error_inst : out std_logic
	    );
    end DW_asymdata_inbuf_inst;


architecture inst of DW_asymdata_inbuf_inst is

begin

    -- Instance of DW_asymdata_inbuf
    U1 : DW_asymdata_inbuf
	generic map ( in_width => inst_in_width, out_width => inst_out_width, err_mode => inst_err_mode, byte_order => inst_byte_order, flush_value => inst_flush_value )
	port map ( clk_push => inst_clk_push, rst_push_n => inst_rst_push_n, init_push_n => inst_init_push_n, push_req_n => inst_push_req_n, data_in => inst_data_in, flush_n => inst_flush_n, fifo_full => inst_fifo_full, push_wd_n => push_wd_n_inst, data_out => data_out_inst, inbuf_full => inbuf_full_inst, part_wd => part_wd_inst, push_error => push_error_inst );


end inst;

-- Configuration for use with a VHDL simulator
-- pragma translate_off
library DW03;
configuration DW_asymdata_inbuf_inst_cfg_inst of DW_asymdata_inbuf_inst is
  for inst
  end for; -- inst
end DW_asymdata_inbuf_inst_cfg_inst;
-- pragma translate_on

