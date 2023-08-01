library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_asymdata_outbuf_inst is
      generic (
	    inst_in_width : INTEGER := 16;
	    inst_out_width : INTEGER := 8;
	    inst_err_mode : INTEGER := 0;
	    inst_byte_order : INTEGER := 0
	    );
      port (
	    inst_clk_pop : in std_logic;
	    inst_rst_pop_n : in std_logic;
	    inst_init_pop_n : in std_logic;
	    inst_pop_req_n : in std_logic;
	    inst_data_in : in std_logic_vector(inst_in_width-1 downto 0);
	    inst_fifo_empty : in std_logic;
	    pop_wd_n_inst : out std_logic;
	    data_out_inst : out std_logic_vector(inst_out_width-1 downto 0);
	    part_wd_inst : out std_logic;
	    pop_error_inst : out std_logic
	    );
    end DW_asymdata_outbuf_inst;


architecture inst of DW_asymdata_outbuf_inst is
begin

    -- Instance of DW_asymdata_outbuf
    U1 : DW_asymdata_outbuf
	generic map ( in_width => inst_in_width, out_width => inst_out_width, err_mode => inst_err_mode, byte_order => inst_byte_order )
	port map ( clk_pop => inst_clk_pop, rst_pop_n => inst_rst_pop_n, init_pop_n => inst_init_pop_n, pop_req_n => inst_pop_req_n, data_in => inst_data_in, fifo_empty => inst_fifo_empty, pop_wd_n => pop_wd_n_inst, data_out => data_out_inst, part_wd => part_wd_inst, pop_error => pop_error_inst );


end inst;

-- Configuration for use with a VHDL simulator
-- pragma translate_off
library DW03;
configuration DW_asymdata_outbuf_inst_cfg_inst of DW_asymdata_outbuf_inst is
  for inst
  end for; -- inst
end DW_asymdata_outbuf_inst_cfg_inst;
-- pragma translate_on

