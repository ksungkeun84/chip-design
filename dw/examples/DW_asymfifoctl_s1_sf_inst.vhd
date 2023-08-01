library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_asymfifoctl_s1_sf_inst is
  generic (inst_data_in_width  : INTEGER := 8;
           inst_data_out_width : INTEGER := 16;
           inst_depth          : INTEGER := 8;
           inst_ae_level       : INTEGER := 4;
           inst_af_level       : INTEGER := 4;
           inst_err_mode       : INTEGER := 1;
           inst_rst_mode       : INTEGER := 1;
           inst_byte_order     : INTEGER := 0 );
  port (inst_clk          : in std_logic;
        inst_rst_n        : in std_logic;
        inst_push_req_n   : in std_logic;
        inst_flush_n      : in std_logic;
        inst_pop_req_n    : in std_logic;
        inst_diag_n       : in std_logic;
        inst_data_in : in std_logic_vector(inst_data_in_width-1 downto 0);
        inst_rd_data : in std_logic_vector(maximum(inst_data_in_width,
                                           inst_data_out_width)-1 downto 0);
        we_n_inst         : out std_logic;
        empty_inst        : out std_logic;
        almost_empty_inst : out std_logic;
        half_full_inst    : out std_logic;
        almost_full_inst  : out std_logic;
        full_inst         : out std_logic;
        ram_full_inst     : out std_logic;
        error_inst        : out std_logic;
        part_wd_inst : out std_logic;
        wr_data_inst : out std_logic_vector(maximum(inst_data_in_width,
                                            inst_data_out_width)-1 downto 0);
       wr_addr_inst : out std_logic_vector(bit_width(inst_depth)-1 downto 0);
       rd_addr_inst : out std_logic_vector(bit_width(inst_depth)-1 downto 0);
       data_out_inst : out std_logic_vector(inst_data_out_width-1 downto 0)        );
end DW_asymfifoctl_s1_sf_inst;

architecture inst of DW_asymfifoctl_s1_sf_inst is
begin

  -- Instance of DW_asymfifoctl_s1_sf
  U1 : DW_asymfifoctl_s1_sf
    generic map (data_in_width => inst_data_in_width, 
                 data_out_width => inst_data_out_width,  depth => inst_depth,
                 ae_level => inst_ae_level,   af_level => inst_af_level,
                 err_mode => inst_err_mode,   rst_mode => inst_rst_mode,
                 byte_order => inst_byte_order )
    port map (clk => inst_clk,   rst_n => inst_rst_n, 
              push_req_n => inst_push_req_n,   flush_n => inst_flush_n,
              pop_req_n => inst_pop_req_n,   diag_n => inst_diag_n, 
              data_in => inst_data_in,   rd_data => inst_rd_data, 
              we_n => we_n_inst,   empty => empty_inst, 
              almost_empty => almost_empty_inst, 
              half_full => half_full_inst,   almost_full => almost_full_inst,
              full => full_inst,   ram_full => ram_full_inst, 
              error => error_inst,   part_wd => part_wd_inst, 
              wr_data => wr_data_inst,   wr_addr => wr_addr_inst, 
              rd_addr => rd_addr_inst,   data_out => data_out_inst );
end inst;

-- pragma translate_off
configuration DW_asymfifoctl_s1_sf_inst_cfg_inst 
 of DW_asymfifoctl_s1_sf_inst is
  for inst
  end for; -- inst
end DW_asymfifoctl_s1_sf_inst_cfg_inst;
-- pragma translate_on

