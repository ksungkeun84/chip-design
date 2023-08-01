library IEEE,DWARE,DW06;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_arith.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_asymfifo_s2_sf_inst is
  generic (inst_data_in_width  : INTEGER := 24;
           inst_data_out_width : INTEGER := 8;
           inst_depth          : INTEGER := 8;
           inst_push_ae_lvl    : INTEGER := 2;
           inst_push_af_lvl    : INTEGER := 2;
           inst_pop_ae_lvl     : INTEGER := 2;
           inst_pop_af_lvl     : INTEGER := 2;
           inst_err_mode       : INTEGER := 0;
           inst_push_sync      : INTEGER := 2;
           inst_pop_sync       : INTEGER := 2;
           inst_rst_mode       : INTEGER := 1;
           inst_byte_order     : INTEGER := 0 );
  port (inst_clk_push   : in std_logic;
        inst_clk_pop    : in std_logic;
        inst_rst_n      : in std_logic;
        inst_push_req_n : in std_logic;
        inst_flush_n    : in std_logic;
        inst_pop_req_n  : in std_logic;
        inst_data_in    : in std_logic_vector(inst_data_in_width-1 downto 0);
        push_empty_inst : out std_logic;
        push_ae_inst    : out std_logic;
        push_hf_inst    : out std_logic;
        push_af_inst    : out std_logic;
        push_full_inst  : out std_logic;
        ram_full_inst   : out std_logic;
        part_wd_inst    : out std_logic;
        push_error_inst : out std_logic;
        pop_empty_inst  : out std_logic;
        pop_ae_inst     : out std_logic;
        pop_hf_inst     : out std_logic;
        pop_af_inst     : out std_logic;
        pop_full_inst   : out std_logic;
        pop_error_inst  : out std_logic;
        data_out_inst  : out std_logic_vector(inst_data_out_width-1 downto 0)
       );
end DW_asymfifo_s2_sf_inst;

architecture inst of DW_asymfifo_s2_sf_inst is
begin

  -- Instance of DW_asymfifo_s2_sf
  U1 : DW_asymfifo_s2_sf
    generic map (data_in_width => inst_data_in_width,
                 data_out_width => inst_data_out_width,
                 depth => inst_depth,
                 push_ae_lvl => inst_push_ae_lvl,
                 push_af_lvl => inst_push_af_lvl,
                 pop_ae_lvl => inst_pop_ae_lvl,
                 pop_af_lvl => inst_pop_af_lvl,   err_mode => inst_err_mode,
                 push_sync => inst_push_sync,   pop_sync => inst_pop_sync,
                 rst_mode => inst_rst_mode,   byte_order => inst_byte_order )
  port map (clk_push => inst_clk_push,   clk_pop => inst_clk_pop,
            rst_n => inst_rst_n,   push_req_n => inst_push_req_n,
            flush_n => inst_flush_n,   pop_req_n => inst_pop_req_n,
            data_in => inst_data_in,   push_empty => push_empty_inst,
            push_ae => push_ae_inst,   push_hf => push_hf_inst,
            push_af => push_af_inst,   push_full => push_full_inst,
            ram_full => ram_full_inst,   part_wd => part_wd_inst,
            push_error => push_error_inst,   pop_empty => pop_empty_inst,
            pop_ae => pop_ae_inst,   pop_hf => pop_hf_inst,
            pop_af => pop_af_inst,   pop_full => pop_full_inst,
            pop_error => pop_error_inst,   data_out => data_out_inst );
end inst;

-- pragma translate_off
configuration DW_asymfifo_s2_sf_inst_cfg_inst of DW_asymfifo_s2_sf_inst is
  for inst
  end for; -- inst
end DW_asymfifo_s2_sf_inst_cfg_inst;
-- pragma translate_on

