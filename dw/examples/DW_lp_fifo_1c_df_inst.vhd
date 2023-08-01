library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp.all;

entity DW_lp_fifo_1c_df_inst is
      generic (
	    inst_width : POSITIVE := 8;
	    inst_depth : POSITIVE := 8;
	    inst_mem_mode : NATURAL := 3;
	    inst_arch_type : NATURAL := 1;
	    inst_af_from_top : NATURAL := 1;
	    inst_ram_re_ext : NATURAL := 0;
	    inst_err_mode : NATURAL := 0;
	    inst_rst_mode : NATURAL := 0
	    );
      port (
	    inst_clk : in std_logic;
	    inst_rst_n : in std_logic;
	    inst_init_n : in std_logic;
	    inst_ae_level : in std_logic_vector(3 downto 0);
	    inst_af_level : in std_logic_vector(3 downto 0);
	    inst_level_change : in std_logic;
	    inst_push_n : in std_logic;
	    inst_data_in : in std_logic_vector(inst_width-1 downto 0);
	    inst_pop_n : in std_logic;
	    data_out_inst : out std_logic_vector(inst_width-1 downto 0);
	    word_cnt_inst : out std_logic_vector(3 downto 0);
	    empty_inst : out std_logic;
	    almost_empty_inst : out std_logic;
	    half_full_inst : out std_logic;
	    almost_full_inst : out std_logic;
	    full_inst : out std_logic;
	    error_inst : out std_logic
	    );
    end DW_lp_fifo_1c_df_inst;

architecture inst of DW_lp_fifo_1c_df_inst is

begin
    -- Instance of DW_lp_fifo_1c_df
    U1 : DW_lp_fifo_1c_df
	generic map ( width => inst_width, 
                      depth => inst_depth, 
                      mem_mode => inst_mem_mode, 
                      arch_type => inst_arch_type, 
                      af_from_top => inst_af_from_top, 
                      ram_re_ext => inst_ram_re_ext, 
                      err_mode => inst_err_mode,
                      rst_mode => inst_rst_mode 
                    )
	port map ( clk => inst_clk, 
                   rst_n => inst_rst_n, 
                   init_n => inst_init_n, 
                   ae_level => inst_ae_level, 
                   af_level => inst_af_level, 
                   level_change => inst_level_change, 
                   push_n => inst_push_n, 
                   data_in => inst_data_in, 
                   pop_n => inst_pop_n, 
                   data_out => data_out_inst, 
                   word_cnt => word_cnt_inst, 
                   empty => empty_inst, 
                   almost_empty => almost_empty_inst, 
                   half_full => half_full_inst, 
                   almost_full => almost_full_inst, 
                   full => full_inst, 
                   error => error_inst 
                 );


end inst;

-- Configuration for use with a VHDL simulator
-- pragma translate_off
library DW03;
configuration DW_lp_fifo_1c_df_inst_cfg_inst of DW_lp_fifo_1c_df_inst is
  for inst
  end for; -- inst
end DW_lp_fifo_1c_df_inst_cfg_inst;
-- pragma translate_on
