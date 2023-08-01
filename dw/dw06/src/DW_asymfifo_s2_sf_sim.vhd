--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1998 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Jay Zhu 		10/01/98
--
-- VERSION:   VHDL simulation model
--
-- DesignWare_version: 466602b3
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Asymmetric Synchronous, dual clcok with Static Flags
--           (FIFO) with static programmable almost empty and almost
--           full flags.
--
--           This FIFO designed to interface to synchronous
--           true dual port RAMs.
--
--		Parameters:	Valid Values
--		==========	============
--		data_in_width	[ 1 to 2048]
--		data_out_width	[ 1 to 2048]
--                  Note: data_in_width and data_out_width must be
--                        in integer multiple relationship: either
--                              data_in_width = K * data_out_width
--                        or    data_out_width = K * data_in_width
--		depth		[ 4 to 1024 ]
--              push_ae_lvl     [ 1 to depth-1 ]
--              push_af_lvl     [ 1 to depth-1 ]
--              pop_ae_lvl      [ 1 to depth-1 ]
--              pop_af_lvl      [ 1 to depth-1 ]
--              err_mode        [ 0 = dynamic error flag,
--                                1 = sticky error flag ] 
--              push_sync       [ 1 = single synchronized, 
--                                2 = double synchronized
--                                3 = triple synchronized ]
--              pop_sync        [ 1 = single synchronized,
--                                2 = double synchronized
--                                3 = triple synchronized ]
--		rst_mode	[ 0 = asynchronous reset RAM & ctlr,
--				  1 = synchronous reset RAM & ctlr,
--				  2 = asynchronous reset ctlr only,
--				  3 = synchronous reset ctlr only ]
--		byte_order	[ 0 = the first byte is in MSBs
--				  1 = the first byte is in LSBs ]
--		
--		Input Ports:	Size	Description
--		===========	====	===========
--		clk_push	1 bit	Push I/F Input Clock
--		clk_pop		1 bit	Pop I/F Input Clock
--		rst_n		1 bit	Active Low Reset
--		push_req_n	1 bit	Active Low Push Request
--              flush_n         1 bit   Flush the partial word into
--                                      the full word memory.  For
--                                      data_in_width<data_out_width
--                                      only
--		pop_req_n	1 bit	Active Low Pop Request
--		data_in		I bits	Push Data input
--
--		Output Ports	Size	Description
--		============	====	===========
--		push_empty	1 bit	Push I/F Empty Flag
--		push_ae		1 bit	Push I/F Almost Empty Flag
--		push_hf		1 bit	Push I/F Half Full Flag
--		push_af		1 bit	Push I/F Almost Full Flag
--		push_full	1 bit	Push I/F Full Flag
--		ram_full	1 bit	Full Flag for RAM
--              part_wd         1 bit   Partial word read flag.  For
--                                      data_in_width<data_out_width
--                                      only
--		push_error	1 bit	Push I/F Error Flag
--		pop_empty	1 bit	Pop I/F Empty Flag
--		pop_ae		1 bit	Pop I/F Almost Empty Flag
--		pop_hf		1 bit	Pop I/F Half Full Flag
--		pop_af		1 bit	Pop I/F Almost Full Flag
--		pop_full	1 bit	Pop I/F Full Flag
--		pop_error	1 bit	Pop I/F Error Flag
--		data_out	O bits	Pop Data output
--
--                Note: the value of I is parameter data_in_width
--		  Note: the value of O is parameter data_out_width
--
--
-- MODIFIED:
--  
--	03/29/18  RJK   Updated max data_in_width and data_out_width as
--	                appropriate (STAR 9001317257) as well as the mx depth
--
----------------------------------------------------------------------
--
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_arith.all;
use DWARE.DW_Foundation_comp_arith.all;
architecture sim of DW_asymfifo_s2_sf is
	
function calc_e_depth( depth : in INTEGER ) return INTEGER is
begin
	if( (2**(bit_width(depth))) = depth ) then
	  return( depth );
	else
	  return( depth + 2 - (depth mod 2) );
	end if;
end calc_e_depth;
constant ram_width : INTEGER := maximum(data_in_width, data_out_width);
constant effective_depth : INTEGER := calc_e_depth( depth );
constant ctl_rst_mode : INTEGER := rst_mode mod 2;
constant mem_rst_mode : INTEGER := (rst_mode + 2) / 3;
signal mem_rst_n, we_n, tie_low : std_logic;
signal rd_addr : std_logic_vector( bit_width( depth )-1 downto 0 );
signal wr_addr : std_logic_vector( bit_width( depth )-1 downto 0 );
signal wr_data : std_logic_vector(ram_width-1 downto 0);
signal rd_data : std_logic_vector(ram_width-1 downto 0);
    begin
-- pragma translate_off

   
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    

   
    if ( (data_in_width < 1) OR (data_in_width > 2048 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter data_in_width (legal range: 1 to 2048 )"
        severity warning;
    end if;
   
    if ( (data_out_width < 1) OR (data_out_width > 2048 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter data_out_width (legal range: 1 to 2048 )"
        severity warning;
    end if;
   
    if ( (depth < 4) OR (depth > 1024) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter depth (legal range: 4 to 1024)"
        severity warning;
    end if;
   
    if ( (push_ae_lvl < 1) OR (push_ae_lvl > depth-1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter push_ae_lvl (legal range: 1 to depth-1 )"
        severity warning;
    end if;
   
    if ( (push_af_lvl < 1) OR (push_af_lvl > depth-1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter push_af_lvl (legal range: 1 to depth-1 )"
        severity warning;
    end if;
   
    if ( (pop_ae_lvl < 1) OR (pop_ae_lvl > depth-1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pop_ae_lvl (legal range: 1 to depth-1 )"
        severity warning;
    end if;
   
    if ( (pop_af_lvl < 1) OR (pop_af_lvl > depth-1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pop_af_lvl (legal range: 1 to depth-1 )"
        severity warning;
    end if;
   
    if ( (push_sync < 1) OR (push_sync > 3 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter push_sync (legal range: 1 to 3 )"
        severity warning;
    end if;
   
    if ( (pop_sync < 1) OR (pop_sync > 3 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pop_sync (legal range: 1 to 3 )"
        severity warning;
    end if;
   
    if ( (err_mode < 0) OR (err_mode > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter err_mode (legal range: 0 to 1 )"
        severity warning;
    end if;
   
    if ( (rst_mode < 0) OR (rst_mode > 3 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 3 )"
        severity warning;
    end if;
   
    if ( (byte_order < 0) OR (byte_order > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter byte_order (legal range: 0 to 1 )"
        severity warning;
    end if;

   
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

    U1 : DW_asymfifoctl_s2_sf
	generic map (
		    data_in_width => data_in_width,
		    data_out_width => data_out_width,
		    depth => depth,
		    push_ae_lvl => push_ae_lvl,
		    push_af_lvl => push_af_lvl,
		    pop_ae_lvl => pop_ae_lvl,
		    pop_af_lvl => pop_af_lvl,
		    err_mode => err_mode,
		    push_sync => push_sync,
		    pop_sync => pop_sync,
		    rst_mode => ctl_rst_mode,
		    byte_order => byte_order
		    )
	
	port map   (
		    clk_push => clk_push,
		    clk_pop => clk_pop,
		    rst_n => rst_n,
		    push_req_n => push_req_n,
		    flush_n => flush_n,
		    pop_req_n => pop_req_n,
		    data_in => data_in,
		    rd_data => rd_data,
		    we_n => we_n,
		    push_empty => push_empty,
		    push_ae => push_ae,
		    push_hf => push_hf,
		    push_af => push_af,
		    push_full => push_full,
		    ram_full => ram_full,
		    part_wd => part_wd,
		    push_error => push_error,
		    pop_empty => pop_empty,
		    pop_ae => pop_ae,
		    pop_hf => pop_hf,
		    pop_af => pop_af,
		    pop_full => pop_full,
		    pop_error => pop_error,
		    wr_data => wr_data,
		    wr_addr => wr_addr,
		    rd_addr => rd_addr,
		    data_out => data_out
		    );
    mem_rst_n <= rst_n when (rst_mode < 2) else '1';
	    U2 : DW_ram_r_w_s_dff
		generic map (
			    data_width => ram_width,
			    depth => effective_depth,
			    rst_mode => mem_rst_mode
			    )
		
		port map    (
			    clk => clk_push,
			    rst_n => mem_rst_n,
			    cs_n => tie_low,
			    wr_n => we_n,
			    rd_addr => rd_addr,
			    wr_addr => wr_addr,
			    data_in => wr_data,
			    data_out => rd_data
			    );
	
    tie_low <= '0';
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw03, dw06;

configuration DW_asymfifo_s2_sf_cfg_sim of DW_asymfifo_s2_sf is
 for sim
    for U1 : DW_asymfifoctl_s2_sf use configuration dw03.DW_asymfifoctl_s2_sf_cfg_sim; end for;
	    for U2 : DW_ram_r_w_s_dff use configuration dw06.DW_ram_r_w_s_dff_cfg_sim; end for;
 end for; -- sim
end DW_asymfifo_s2_sf_cfg_sim;
-- pragma translate_on
