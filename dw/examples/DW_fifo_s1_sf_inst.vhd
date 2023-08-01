library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_fifo_s1_sf_inst is
  generic (inst_width    : INTEGER := 8;
           inst_depth    : INTEGER := 4;
           inst_ae_level : INTEGER := 1;
           inst_af_level : INTEGER := 1;
           inst_err_mode : INTEGER := 0;
           inst_rst_mode : INTEGER := 0  );
  port (inst_clk          : in std_logic;
        inst_rst_n        : in std_logic;
        inst_push_req_n   : in std_logic;
        inst_pop_req_n    : in std_logic;
        inst_diag_n       : in std_logic;
        inst_data_in      : in std_logic_vector(inst_width-1 downto 0);
        empty_inst        : out std_logic;
        almost_empty_inst : out std_logic;
        half_full_inst    : out std_logic;
        almost_full_inst  : out std_logic;
        full_inst         : out std_logic;
        error_inst        : out std_logic;
        data_out_inst     : out std_logic_vector(inst_width-1 downto 0) );
end DW_fifo_s1_sf_inst;

architecture inst of DW_fifo_s1_sf_inst is
begin

  -- Instance of DW_fifo_s1_sf
  U1 : DW_fifo_s1_sf
    generic map ( width => inst_width,   depth => inst_depth, 
                 ae_level => inst_ae_level,   af_level => inst_af_level,
                 err_mode => inst_err_mode,   rst_mode => inst_rst_mode )
    port map ( clk => inst_clk,   rst_n => inst_rst_n, 
               push_req_n => inst_push_req_n,   pop_req_n => inst_pop_req_n,
               diag_n => inst_diag_n,   data_in => inst_data_in, 
               empty => empty_inst,   almost_empty => almost_empty_inst,
               half_full => half_full_inst,  almost_full => almost_full_inst,
               full => full_inst,   error => error_inst, 
               data_out => data_out_inst );
end inst;

-- pragma translate_off
configuration DW_fifo_s1_sf_inst_cfg_inst of DW_fifo_s1_sf_inst is
  for inst
  end for; -- inst
end DW_fifo_s1_sf_inst_cfg_inst;
-- pragma translate_on

