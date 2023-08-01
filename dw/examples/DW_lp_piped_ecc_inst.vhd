library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp.all;

entity DW_lp_piped_ecc_inst is
      generic (
	    inst_data_width : POSITIVE := 16;
	    inst_chk_width : POSITIVE := 6;
            inst_rw_mode : NATURAL  := 1;
            inst_op_iso_mode : NATURAL  := 0;
            inst_id_width : POSITIVE := 1;
            inst_in_reg : NATURAL  := 0;
            inst_stages : POSITIVE := 3;
            inst_out_reg : NATURAL  := 0;
            inst_no_pm : NATURAL  := 1;
            inst_rst_mode : NATURAL  := 0
	    );
      port (
            inst_clk : in std_logic;
            inst_rst_n : in std_logic;
            inst_datain : in std_logic_vector(inst_data_width-1 downto 0);
            inst_chkin : in std_logic_vector(inst_chk_width-1 downto 0);
            err_detect_inst : out std_logic;
            err_multiple_inst : out std_logic;
            dataout_inst : out std_logic_vector(inst_data_width-1 downto 0);
            chkout_inst : out std_logic_vector(inst_chk_width-1 downto 0);
            syndout_inst : out std_logic_vector(inst_chk_width-1 downto 0);
            inst_launch : in std_logic;
            inst_launch_id : in std_logic_vector(inst_id_width-1 downto 0);
            pipe_full_inst : out std_logic;
            pipe_ovf_inst : out std_logic;
            inst_accept_n : in std_logic;
            arrive_inst : out std_logic;
            arrive_id_inst : out std_logic_vector(inst_id_width-1 downto 0);
            push_out_n_inst : out std_logic;
            pipe_census_inst : out std_logic_vector(1 downto 0)
	    );
    end DW_lp_piped_ecc_inst;


architecture inst of DW_lp_piped_ecc_inst is

begin

    -- Instance of DW_lp_piped_ecc
    U1 : DW_lp_piped_ecc
	generic map  ( data_width => inst_data_width, 
	               chk_width => inst_chk_width, 
                       rw_mode => inst_rw_mode,
	               op_iso_mode => inst_op_iso_mode,
	               id_width => inst_id_width,
	               in_reg => inst_in_reg, 
	               stages => inst_stages, 
	               out_reg => inst_out_reg, 
	               no_pm => inst_no_pm, 
	               rst_mode => inst_rst_mode )

	port map ( clk => inst_clk, 
                   rst_n => inst_rst_n, 
                   datain => inst_datain, 
                   chkin => inst_chkin, 
                   err_detect => err_detect_inst, 
                   err_multiple => err_multiple_inst, 
                   dataout => dataout_inst,
                   chkout => chkout_inst,
                   syndout => syndout_inst,
                   launch => inst_launch, 
                   launch_id => inst_launch_id, 
                   pipe_full => pipe_full_inst, 
                   pipe_ovf => pipe_ovf_inst, 
                   accept_n => inst_accept_n, 
                   arrive => arrive_inst, 
                   arrive_id => arrive_id_inst, 
                   push_out_n => push_out_n_inst, 
                   pipe_census => pipe_census_inst );
end inst;

-- Configuration for use with a VHDL simulator
-- pragma translate_off
library DW04;
configuration DW_lp_piped_ecc_inst_cfg_inst of DW_lp_piped_ecc_inst is
  for inst
  end for; -- inst
end DW_lp_piped_ecc_inst_cfg_inst;
-- pragma translate_on
